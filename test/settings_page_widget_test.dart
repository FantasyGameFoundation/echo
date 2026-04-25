import 'dart:async';

import 'package:echo/core/platform/project_bundle_file_transfer.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/presentation/pages/settings_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _demoExportPath = '/Users/demo/Exports/Echo-Test.echo-bundle';

typedef _InspectImportBundle =
    Future<ImportProjectBundleInspection> Function(
      ProjectBundleImportSelection selection,
    );
typedef _ImportProject =
    Future<AppSettings> Function(
      ProjectBundleImportSelection selection,
      bool applySettingsPayload,
    );

void main() {
  testWidgets(
    'import skips settings confirmation when bundle has no settings payload',
    (tester) async {
      _setTallSurface(tester);
      ProjectBundleImportSelection? importedSelection;
      bool? importedApplySettings;
      const selectionDisplayPath = '/tmp/bundle-no-settings';

      await _pumpSettingsPage(
        tester,
        onPickImportBundle: () async => _selection(selectionDisplayPath),
        onInspectImportBundle: (_) async => const ImportProjectBundleInspection(
          hasSettingsPayload: false,
          oversizedMediaCount: 0,
        ),
        onImportProject: (selection, applySettingsPayload) async {
          importedSelection = selection;
          importedApplySettings = applySettingsPayload;
          return AppSettings.defaults();
        },
      );

      await _startImport(tester);

      expect(find.text('导 入 设 置'), findsNothing);
      expect(importedSelection?.bundleDirectoryPath, selectionDisplayPath);
      expect(importedApplySettings, isFalse);
    },
  );

  testWidgets(
    'import requires settings confirmation when bundle has settings payload',
    (tester) async {
      _setTallSurface(tester);
      bool? importedApplySettings;

      await _pumpSettingsPage(
        tester,
        onPickImportBundle: () async => _selection('/tmp/bundle-with-settings'),
        onInspectImportBundle: (_) async => const ImportProjectBundleInspection(
          hasSettingsPayload: true,
          oversizedMediaCount: 0,
        ),
        onImportProject: (_, applySettingsPayload) async {
          importedApplySettings = applySettingsPayload;
          return AppSettings.defaults();
        },
      );

      await _startImport(tester);

      expect(find.text('导 入 设 置'), findsOneWidget);

      await tester.tap(find.text('仅 导 入 项 目'));
      await tester.pumpAndSettle();

      expect(importedApplySettings, isFalse);
    },
  );

  testWidgets(
    'import refreshes visible settings after applying imported settings',
    (tester) async {
      _setTallSurface(tester);
      await _pumpSettingsPage(
        tester,
        onPickImportBundle: () async => _selection('/tmp/bundle-with-settings'),
        onInspectImportBundle: (_) async => const ImportProjectBundleInspection(
          hasSettingsPayload: true,
          oversizedMediaCount: 0,
        ),
        onImportProject: (selection, applySettingsPayload) async =>
            AppSettings(compressionLevel: AppMediaCompressionLevel.highQuality),
      );

      expect(_findSelectedCompressionOption('无压缩'), findsOneWidget);

      await _startImport(tester);
      await tester.tap(find.text('一 并 应 用'));
      await tester.pumpAndSettle();

      expect(_findSelectedCompressionOption('高质量'), findsOneWidget);
      expect(_findSelectedCompressionOption('无压缩'), findsNothing);
    },
  );

  testWidgets(
    'oversized bundle import can re-check after changing compression setting',
    (tester) async {
      _setTallSurface(tester);
      var currentLevel = AppMediaCompressionLevel.standard;
      var importTriggered = false;

      await _pumpSettingsPage(
        tester,
        initialSettings: AppSettings(compressionLevel: currentLevel),
        onUpdateCompressionLevel: (level) async {
          currentLevel = level;
          return AppSettings(compressionLevel: level);
        },
        onUpdateExportIncludesSettings: (include) async => AppSettings(
          compressionLevel: currentLevel,
          includeSettingsInExportsByDefault: include,
        ),
        onPickImportBundle: () async => _selection('/tmp/oversized-bundle'),
        onInspectImportBundle: (_) async => ImportProjectBundleInspection(
          hasSettingsPayload: false,
          oversizedMediaCount: currentLevel == AppMediaCompressionLevel.standard
              ? 1
              : 0,
        ),
        onImportProject: (selection, applySettingsPayload) async {
          importTriggered = true;
          return AppSettings(compressionLevel: currentLevel);
        },
      );

      await _startImport(tester);

      expect(find.text('导 入 图 片'), findsOneWidget);
      expect(find.text('压 缩 导 入'), findsOneWidget);

      await tester.tap(find.text('无压缩').last);
      await tester.pumpAndSettle();

      expect(find.text('继 续 导 入'), findsOneWidget);
      await tester.tap(find.text('继 续 导 入'));
      await tester.pumpAndSettle();

      expect(importTriggered, isTrue);
    },
  );

  testWidgets('export receipt shows path and copy button', (tester) async {
    _setTallSurface(tester);
    await _pumpSettingsPage(
      tester,
      canExportCurrentProject: true,
      onExportProject: (_) async => const ProjectBundleExportReceipt(
        displayPath: _demoExportPath,
        copyablePath: _demoExportPath,
      ),
    );

    await _tapActionButton(tester, '导出当前项目');

    expect(find.text('导出地址'), findsOneWidget);
    expect(find.text(_demoExportPath), findsOneWidget);
    expect(find.text('复制'), findsOneWidget);
  });

  testWidgets('copy button writes export path into clipboard', (tester) async {
    _setTallSurface(tester);
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = Map<String, dynamic>.from(
              call.arguments as Map<dynamic, dynamic>,
            );
            copiedText = arguments['text'] as String?;
            return null;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await _pumpSettingsPage(
      tester,
      canExportCurrentProject: true,
      onExportProject: (_) async => const ProjectBundleExportReceipt(
        displayPath: _demoExportPath,
        copyablePath: _demoExportPath,
      ),
    );

    await _tapActionButton(tester, '导出当前项目');
    await _tapActionButton(tester, '复制');

    expect(copiedText, _demoExportPath);
  });

  testWidgets('import disables leaving settings page while running', (
    tester,
  ) async {
    _setTallSurface(tester);
    final importCompleter = Completer<AppSettings>();

    await _pumpSettingsPage(
      tester,
      onPickImportBundle: () async => _selection('/tmp/slow-import-bundle'),
      onInspectImportBundle: (_) async => const ImportProjectBundleInspection(
        hasSettingsPayload: false,
        oversizedMediaCount: 0,
      ),
      onImportProject: (_, __) => importCompleter.future,
    );

    await _startImport(tester);
    await tester.pump();

    expect(find.text('导入中…'), findsOneWidget);
    final leadingBackButton = tester.widget<IconButton>(
      find.byType(IconButton).first,
    );
    expect(leadingBackButton.onPressed, isNull);

    await tester.tap(find.byType(IconButton).first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('设 置'), findsOneWidget);

    importCompleter.complete(AppSettings.defaults());
    await tester.pumpAndSettle();
  });

  testWidgets('import execution permission error shows file access failure', (
    tester,
  ) async {
    _setTallSurface(tester);
    var importAttempts = 0;

    await _pumpSettingsPage(
      tester,
      onPickImportBundle: () async => _selection('/tmp/retried-import-bundle'),
      onInspectImportBundle: (_) async => const ImportProjectBundleInspection(
        hasSettingsPayload: false,
        oversizedMediaCount: 0,
      ),
      onImportProject: (_, __) async {
        importAttempts += 1;
        if (importAttempts == 1) {
          throw const ProjectBundleFileTransferException(
            ProjectBundleFileTransferErrorCode.permissionDenied,
          );
        }
        return AppSettings.defaults();
      },
    );

    await _startImport(tester);

    expect(importAttempts, 1);
    expect(find.text('导入失败，需要文件存储权限'), findsOneWidget);
  });

  testWidgets('import opens picker without a separate permission preflight', (
    tester,
  ) async {
    _setTallSurface(tester);
    var pickAttempts = 0;

    await _pumpSettingsPage(
      tester,
      onPickImportBundle: () async {
        pickAttempts += 1;
        return _selection('/tmp/permission-first-import-bundle');
      },
    );

    await _tapActionButton(tester, '选择导入包');

    expect(pickAttempts, 1);
  });
}

Future<void> _pumpSettingsPage(
  WidgetTester tester, {
  AppSettings? initialSettings,
  bool canExportCurrentProject = false,
  Future<AppSettings> Function(AppMediaCompressionLevel level)?
  onUpdateCompressionLevel,
  Future<AppSettings> Function(bool include)? onUpdateExportIncludesSettings,
  Future<ProjectBundleImportSelection?> Function()? onPickImportBundle,
  _InspectImportBundle? onInspectImportBundle,
  _ImportProject? onImportProject,
  Future<ProjectBundleExportReceipt?> Function(bool includeSettings)?
  onExportProject,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SettingsPlaceholderPage(
        initialSettings: initialSettings ?? AppSettings.defaults(),
        canExportCurrentProject: canExportCurrentProject,
        onUpdateCompressionLevel:
            onUpdateCompressionLevel ??
            (level) async => AppSettings(compressionLevel: level),
        onUpdateExportIncludesSettings:
            onUpdateExportIncludesSettings ??
            (include) async =>
                AppSettings(includeSettingsInExportsByDefault: include),
        onPickImportBundle: onPickImportBundle,
        onInspectImportBundle: onInspectImportBundle,
        onImportProject: onImportProject,
        onExportProject: onExportProject,
      ),
    ),
  );
}

Finder _findSelectedCompressionOption(String label) {
  return find.byWidgetPredicate((widget) {
    if (widget is! RadioListTile<Object?>) {
      return false;
    }
    final title = widget.title;
    if (title is! Text || title.data != label) {
      return false;
    }
    return widget.groupValue == widget.value;
  });
}

ProjectBundleImportSelection _selection(String path) {
  return ProjectBundleImportSelection(
    bundleDirectoryPath: path,
    displayPath: path,
  );
}

Finder _actionButton(String label) {
  return find
      .ancestor(of: find.text(label), matching: find.byType(InkWell))
      .first;
}

Future<void> _startImport(WidgetTester tester) async {
  await _tapActionButton(tester, '选择导入包');
  await _tapActionButton(tester, '导入为新项目');
}

Future<void> _tapActionButton(WidgetTester tester, String label) async {
  await _scrollToActionButton(tester, label);
  await tester.tap(_actionButton(label));
  await tester.pumpAndSettle();
}

Future<void> _scrollToActionButton(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    120,
    scrollable: find.byType(Scrollable).first,
  );
}

void _setTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
