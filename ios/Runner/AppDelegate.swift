import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let storageDirectoryChannelName = "echo/platform/storage_directory"
  private let projectBundleTransferChannelName = "echo/platform/project_bundle_transfer"
  private weak var registeredFlutterViewController: UIViewController?
  private lazy var projectBundleTransferCoordinator = ProjectBundleTransferCoordinator {
    [weak self] in
    self?.registeredTopViewController() ??
      self?.sceneTopViewController() ??
      self?.topViewController()
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let pluginKey = "EchoProjectBundleTransferHost"
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: pluginKey) {
      registeredFlutterViewController = registrar.viewController
      registerPlatformChannels(binaryMessenger: registrar.messenger())
      return
    }
    registerPlatformChannels(binaryMessenger: engineBridge.applicationRegistrar.messenger())
  }

  private func registerPlatformChannels(binaryMessenger: FlutterBinaryMessenger) {
    let storageChannel = FlutterMethodChannel(
      name: storageDirectoryChannelName,
      binaryMessenger: binaryMessenger
    )
    storageChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getAppStorageDirectory" else {
        result(FlutterMethodNotImplemented)
        return
      }

      result(self?.applicationSupportDirectoryPath())
    }

    let projectBundleChannel = FlutterMethodChannel(
      name: projectBundleTransferChannelName,
      binaryMessenger: binaryMessenger
    )
    projectBundleChannel.setMethodCallHandler { [weak self] call, result in
      self?.projectBundleTransferCoordinator.handle(call: call, result: result)
    }
  }

  private func applicationSupportDirectoryPath() -> String? {
    let directory = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first
    if let directory {
      try? FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )
    }
    return directory?.path
  }

  private func topViewController(from controller: UIViewController? = nil) -> UIViewController? {
    let rootController = controller ?? activeRootViewController()

    if let navigationController = rootController as? UINavigationController {
      return topViewController(from: navigationController.visibleViewController)
    }
    if let tabBarController = rootController as? UITabBarController {
      return topViewController(from: tabBarController.selectedViewController)
    }
    if let presentedViewController = rootController?.presentedViewController {
      return topViewController(from: presentedViewController)
    }
    return rootController
  }

  private func sceneTopViewController() -> UIViewController? {
    if let rootViewController = SceneDelegate.activeSceneDelegate?.window?.rootViewController {
      return topViewController(from: rootViewController)
    }
    return nil
  }

  private func registeredTopViewController() -> UIViewController? {
    if let registeredFlutterViewController {
      return topViewController(from: registeredFlutterViewController)
    }
    return nil
  }

  private func activeRootViewController() -> UIViewController? {
    if let rootViewController = window?.rootViewController {
      return rootViewController
    }

    let activeScenes = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }

    for scene in activeScenes {
      if let keyWindow = scene.windows.first(where: \.isKeyWindow),
         let rootViewController = keyWindow.rootViewController {
        return rootViewController
      }
    }

    for scene in activeScenes {
      if let rootViewController = scene.windows
        .first(where: { !$0.isHidden && $0.alpha > 0 && $0.windowLevel == .normal })?
        .rootViewController {
        return rootViewController
      }
    }

    return nil
  }
}

private final class ProjectBundleTransferCoordinator: NSObject, UIDocumentPickerDelegate {
  private enum PendingOperation {
    case export(sourceDirectoryURL: URL, suggestedBundleName: String)
    case importSelection
  }

  private let presentingViewControllerProvider: () -> UIViewController?
  private let fileManager = FileManager.default
  private var pendingOperation: PendingOperation?
  private var pendingResult: FlutterResult?
  private var stagedExportURL: URL?

  init(presentingViewControllerProvider: @escaping () -> UIViewController?) {
    self.presentingViewControllerProvider = presentingViewControllerProvider
    super.init()
  }

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(
        FlutterError(
          code: "busy",
          message: "Another project bundle transfer is already active.",
          details: nil
        )
      )
      return
    }

    switch call.method {
    case "exportBundleDirectory":
      guard
        let arguments = call.arguments as? [String: Any],
        let bundleDirectoryPath = arguments["bundleDirectoryPath"] as? String,
        let suggestedBundleName = arguments["suggestedBundleName"] as? String
      else {
        result(
          FlutterError(
            code: "invalidSelection",
            message: "Export bundle arguments are missing.",
            details: nil
          )
        )
        return
      }

      let sourceDirectoryURL = URL(fileURLWithPath: bundleDirectoryPath, isDirectory: true)
      guard fileManager.fileExists(atPath: sourceDirectoryURL.path) else {
        result(
          FlutterError(
            code: "invalidSelection",
            message: "The source bundle directory does not exist.",
            details: bundleDirectoryPath
          )
        )
        return
      }

      presentDocumentPicker(
        operation: .export(
          sourceDirectoryURL: sourceDirectoryURL,
          suggestedBundleName: suggestedBundleName
        ),
        result: result
      )
    case "pickImportBundleDirectory":
      presentDocumentPicker(operation: .importSelection, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func presentDocumentPicker(
    operation: PendingOperation,
    result: @escaping FlutterResult
  ) {
    pendingOperation = operation
    pendingResult = result
    attemptPresentDocumentPicker(retryCount: 6)
  }

  private func attemptPresentDocumentPicker(retryCount: Int) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }

      guard let presentingViewController = self.presentingViewControllerProvider() else {
        NSLog("[EchoBundle] document picker host unavailable, retries left: \(retryCount)")
        if retryCount > 0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.attemptPresentDocumentPicker(retryCount: retryCount - 1)
          }
          return
        }
        self.finish(
          withError: FlutterError(
            code: "unavailable",
            message: "Unable to present the document picker.",
            details: nil
          )
        )
        return
      }

      guard let operation = self.pendingOperation else {
        self.finish(
          withError: FlutterError(
            code: "unavailable",
            message: "Document picker operation is no longer available.",
            details: nil
          )
        )
        return
      }

      do {
        let picker = try self.buildPicker(for: operation)
        picker.delegate = self
        if case .importSelection = operation {
          picker.allowsMultipleSelection = false
        }
        NSLog("[EchoBundle] presenting document picker from \(type(of: presentingViewController))")
        presentingViewController.present(picker, animated: true)
      } catch let error as ProjectBundleTransferNativeError {
        self.finish(withError: error.flutterError)
      } catch {
        self.finish(
          withError: FlutterError(
            code: "ioFailure",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }

  private func buildPicker(for operation: PendingOperation) throws -> UIDocumentPickerViewController {
    switch operation {
    case let .export(sourceDirectoryURL, suggestedBundleName):
      let stagedExportURL = try prepareStagedExportDirectory(
        sourceDirectoryURL: sourceDirectoryURL,
        suggestedBundleName: suggestedBundleName
      )
      self.stagedExportURL = stagedExportURL

      if #available(iOS 14.0, *) {
        return UIDocumentPickerViewController(
          forExporting: [stagedExportURL],
          asCopy: true
        )
      }
      return UIDocumentPickerViewController(url: stagedExportURL, in: .exportToService)
    case .importSelection:
      if #available(iOS 14.0, *) {
        return UIDocumentPickerViewController(
          forOpeningContentTypes: [UTType.folder],
          asCopy: false
        )
      }
      return UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    cleanupStagedExportDirectory()
    completeAfterPickerDismissal {
      self.finish(with: nil)
    }
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    guard let selectedURL = urls.first, let operation = pendingOperation else {
      finish(
        withError: FlutterError(
          code: "invalidSelection",
          message: "The selected bundle directory is unavailable.",
          details: nil
        )
      )
      return
    }

    do {
      let payload = try perform(operation: operation, with: selectedURL)
      cleanupStagedExportDirectory()
      completeAfterPickerDismissal {
        self.finish(with: payload)
      }
    } catch let error as ProjectBundleTransferNativeError {
      cleanupStagedExportDirectory()
      completeAfterPickerDismissal {
        self.finish(withError: error.flutterError)
      }
    } catch {
      cleanupStagedExportDirectory()
      completeAfterPickerDismissal {
        self.finish(
          withError: FlutterError(
            code: "ioFailure",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }

  private func completeAfterPickerDismissal(_ completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      completion()
    }
  }

  private func perform(
    operation: PendingOperation,
    with selectedURL: URL
  ) throws -> [String: Any] {
    switch operation {
    case .export:
      return [
        "displayPath": selectedURL.path,
        "copyablePath": selectedURL.path,
      ]
    case .importSelection:
      guard selectedURL.startAccessingSecurityScopedResource() else {
        throw ProjectBundleTransferNativeError(
          code: "permissionDenied",
          message: "The selected bundle directory is not accessible.",
          details: selectedURL.path
        )
      }
      defer {
        selectedURL.stopAccessingSecurityScopedResource()
      }
      let importedDirectoryURL = try copyImportedDirectoryToTemporaryLocation(
        from: selectedURL
      )
      return [
        "bundleDirectoryPath": importedDirectoryURL.path,
        "cleanupDirectoryPath": importedDirectoryURL.path,
        "displayPath": selectedURL.path,
      ]
    }
  }

  private func prepareStagedExportDirectory(
    sourceDirectoryURL: URL,
    suggestedBundleName: String
  ) throws -> URL {
    cleanupStagedExportDirectory()

    let normalizedBundleName = sanitizeBundleName(suggestedBundleName)
    let baseDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(
      "echo-export-\(UUID().uuidString)",
      isDirectory: true
    )
    try fileManager.createDirectory(
      at: baseDirectoryURL,
      withIntermediateDirectories: true
    )
    let stagedExportURL = baseDirectoryURL.appendingPathComponent(
      normalizedBundleName,
      isDirectory: true
    )
    try fileManager.copyItem(at: sourceDirectoryURL, to: stagedExportURL)
    return stagedExportURL
  }

  private func copyImportedDirectoryToTemporaryLocation(from selectedURL: URL) throws -> URL {
    let targetURL = fileManager.temporaryDirectory.appendingPathComponent(
      "echo-import-\(UUID().uuidString)",
      isDirectory: true
    )
    let coordinator = NSFileCoordinator(filePresenter: nil)
    var coordinationError: NSError?
    var operationError: Error?

    coordinator.coordinate(
      readingItemAt: selectedURL,
      options: [],
      error: &coordinationError
    ) { coordinatedSelectedURL in
      do {
        if self.fileManager.fileExists(atPath: targetURL.path) {
          try self.fileManager.removeItem(at: targetURL)
        }
        try self.fileManager.copyItem(at: coordinatedSelectedURL, to: targetURL)
      } catch {
        operationError = error
      }
    }

    if let coordinationError {
      throw coordinationError
    }
    if let operationError {
      throw operationError
    }
    return targetURL
  }

  private func sanitizeBundleName(_ value: String) -> String {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      return "Echo-Export"
    }

    let invalidCharacterSet = CharacterSet(charactersIn: "\\/:*?\"<>|")
    let sanitized = trimmed.unicodeScalars.map { scalar -> String in
      invalidCharacterSet.contains(scalar) ? " " : String(scalar)
    }.joined()
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    return sanitized.isEmpty ? "Echo-Export" : sanitized
  }

  private func finish(with payload: Any?) {
    let result = pendingResult
    pendingOperation = nil
    pendingResult = nil
    cleanupStagedExportDirectory()
    result?(payload)
  }

  private func finish(withError error: FlutterError) {
    let result = pendingResult
    pendingOperation = nil
    pendingResult = nil
    cleanupStagedExportDirectory()
    result?(error)
  }

  private func cleanupStagedExportDirectory() {
    guard let stagedExportURL else {
      return
    }
    let baseDirectoryURL = stagedExportURL.deletingLastPathComponent()
    if fileManager.fileExists(atPath: baseDirectoryURL.path) {
      try? fileManager.removeItem(at: baseDirectoryURL)
    }
    self.stagedExportURL = nil
  }
}

private struct ProjectBundleTransferNativeError: Error {
  let code: String
  let message: String
  let details: Any?

  var flutterError: FlutterError {
    FlutterError(code: code, message: message, details: details)
  }
}
