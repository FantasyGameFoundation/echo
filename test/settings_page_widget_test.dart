import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/presentation/pages/settings_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'import skips settings confirmation when bundle has no settings payload',
    (tester) async {
      String? importedPath;
      bool? importedApplySettings;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPlaceholderPage(
            initialSettings: AppSettings.defaults(),
            onUpdateCompressionLevel: (level) async => AppSettings(
              compressionLevel: level,
            ),
            onUpdateExportIncludesSettings: (include) async => AppSettings(
              includeSettingsInExportsByDefault: include,
            ),
            onInspectImportBundle: (_) async =>
                const ImportProjectBundleInspection(
                  hasSettingsPayload: false,
                  oversizedMediaCount: 0,
                ),
            onImportProject: (bundlePath, applySettingsPayload) async {
              importedPath = bundlePath;
              importedApplySettings = applySettingsPayload;
              return AppSettings.defaults();
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '/tmp/bundle-no-settings');
      await tester.tap(find.text('导入为新项目'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('导 入 设 置'), findsNothing);
      expect(importedPath, '/tmp/bundle-no-settings');
      expect(importedApplySettings, isFalse);
    },
  );

  testWidgets(
    'import requires settings confirmation when bundle has settings payload',
    (tester) async {
      bool? importedApplySettings;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPlaceholderPage(
            initialSettings: AppSettings.defaults(),
            onUpdateCompressionLevel: (level) async => AppSettings(
              compressionLevel: level,
            ),
            onUpdateExportIncludesSettings: (include) async => AppSettings(
              includeSettingsInExportsByDefault: include,
            ),
            onInspectImportBundle: (_) async =>
                const ImportProjectBundleInspection(
                  hasSettingsPayload: true,
                  oversizedMediaCount: 0,
                ),
            onImportProject: (_, applySettingsPayload) async {
              importedApplySettings = applySettingsPayload;
              return AppSettings.defaults();
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '/tmp/bundle-with-settings');
      await tester.tap(find.text('导入为新项目'));
      await tester.pumpAndSettle();

      expect(find.text('导 入 设 置'), findsOneWidget);

      await tester.tap(find.text('仅 导 入 项 目'));
      await tester.pumpAndSettle();

      expect(importedApplySettings, isFalse);
    },
  );

  testWidgets(
    'import refreshes visible settings after applying imported settings',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPlaceholderPage(
            initialSettings: AppSettings.defaults(),
            onUpdateCompressionLevel: (level) async => AppSettings(
              compressionLevel: level,
            ),
            onUpdateExportIncludesSettings: (include) async => AppSettings(
              includeSettingsInExportsByDefault: include,
            ),
            onInspectImportBundle: (_) async =>
                const ImportProjectBundleInspection(
                  hasSettingsPayload: true,
                  oversizedMediaCount: 0,
                ),
            onImportProject: (_, __) async => AppSettings(
              compressionLevel: AppMediaCompressionLevel.highQuality,
            ),
          ),
        ),
      );

      expect(_findSelectedCompressionOption('无压缩'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '/tmp/bundle-with-settings');
      await tester.tap(find.text('导入为新项目'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('一 并 应 用'));
      await tester.pumpAndSettle();

      expect(_findSelectedCompressionOption('高质量'), findsOneWidget);
      expect(_findSelectedCompressionOption('无压缩'), findsNothing);
    },
  );

  testWidgets(
    'oversized bundle import can re-check after changing compression setting',
    (tester) async {
      var currentLevel = AppMediaCompressionLevel.standard;
      var importTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPlaceholderPage(
            initialSettings: AppSettings(
              compressionLevel: currentLevel,
            ),
            onUpdateCompressionLevel: (level) async {
              currentLevel = level;
              return AppSettings(compressionLevel: level);
            },
            onUpdateExportIncludesSettings: (include) async => AppSettings(
              compressionLevel: currentLevel,
              includeSettingsInExportsByDefault: include,
            ),
            onInspectImportBundle: (_) async => ImportProjectBundleInspection(
              hasSettingsPayload: false,
              oversizedMediaCount:
                  currentLevel == AppMediaCompressionLevel.standard ? 1 : 0,
            ),
            onImportProject: (_, __) async {
              importTriggered = true;
              return AppSettings(compressionLevel: currentLevel);
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '/tmp/oversized-bundle');
      await tester.tap(find.text('导入为新项目'));
      await tester.pumpAndSettle();

      expect(find.text('导 入 图 片'), findsOneWidget);
      expect(find.text('压 缩 导 入'), findsOneWidget);

      await tester.tap(find.text('无压缩'));
      await tester.pumpAndSettle();

      expect(find.text('继 续 导 入'), findsOneWidget);
      await tester.tap(find.text('继 续 导 入'));
      await tester.pumpAndSettle();

      expect(importTriggered, isTrue);
    },
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
