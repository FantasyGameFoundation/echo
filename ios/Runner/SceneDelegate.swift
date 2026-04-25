import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  static weak var activeSceneDelegate: SceneDelegate?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    SceneDelegate.activeSceneDelegate = self
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    SceneDelegate.activeSceneDelegate = self
    super.sceneDidBecomeActive(scene)
  }

  override func sceneWillEnterForeground(_ scene: UIScene) {
    SceneDelegate.activeSceneDelegate = self
    super.sceneWillEnterForeground(scene)
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    if SceneDelegate.activeSceneDelegate === self {
      SceneDelegate.activeSceneDelegate = nil
    }
    super.sceneDidDisconnect(scene)
  }
}
