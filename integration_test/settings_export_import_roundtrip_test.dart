import 'dart:io';

import 'package:echo/app/app.dart';
import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/core/platform/project_bundle_file_transfer.dart';
import 'package:echo/features/beacon/infrastructure/repositories/local_beacon_task_repository.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/infrastructure/repositories/local_capture_record_repository.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';
import 'package:echo/features/settings/infrastructure/services/local_export_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_import_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_media_ingest_policy.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_structure_chapter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'export then import restores project data and settings on a fresh simulator app instance',
    (tester) async {
      await _setPhoneSurface(binding);
      await _clearRuntimeStorage();

      final rootDirectory = await Directory.systemTemp.createTemp(
        'echo-settings-roundtrip-',
      );
      addTearDown(() async {
        await _clearRuntimeStorage();
        if (await rootDirectory.exists()) {
          await rootDirectory.delete(recursive: true);
        }
      });

      final sourceEnvironment = await _TestAppEnvironment.create(
        rootDirectory: Directory(p.join(rootDirectory.path, 'source')),
        isarName: 'echo_settings_roundtrip_source',
      );
      final targetEnvironment = await _TestAppEnvironment.create(
        rootDirectory: Directory(p.join(rootDirectory.path, 'target')),
        isarName: 'echo_settings_roundtrip_target',
      );
      final transfer = _FakeProjectBundleFileTransfer(
        Directory(p.join(rootDirectory.path, 'exports')),
      );

      addTearDown(sourceEnvironment.dispose);
      addTearDown(targetEnvironment.dispose);

      await sourceEnvironment.seedProjectFixture();
      await sourceEnvironment.settingsRepository.save(
        AppSettings(
          compressionLevel: AppMediaCompressionLevel.highQuality,
          includeSettingsInExportsByDefault: true,
        ),
      );

      await tester.pumpWidget(
        _buildApp(environment: sourceEnvironment, transfer: transfer),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings_outlined).first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('导出当前项目'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('导出当前项目'));
      await tester.pumpAndSettle();

      expect(transfer.latestExportedBundlePath, isNotNull);
      expect(find.text('导出地址'), findsOneWidget);
      expect(
        Directory(transfer.latestExportedBundlePath!).existsSync(),
        isTrue,
      );

      await sourceEnvironment.dispose(deleteRootDirectory: true);
      await _clearRuntimeStorage();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _buildApp(environment: targetEnvironment, transfer: transfer),
      );
      await tester.pumpAndSettle();
      expect(find.text('新 建 项 目'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton.first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('选择导入包'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('选择导入包'));
      await tester.pumpAndSettle();
      expect(find.textContaining('待导入：'), findsOneWidget);
      await tester.tap(find.text('导入为新项目'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('一 并 应 用'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('雨夜厂区'), findsOneWidget);

      final restoredSettings = await targetEnvironment.settingsRepository
          .load();
      expect(
        restoredSettings.compressionLevel,
        AppMediaCompressionLevel.highQuality,
      );
      expect(restoredSettings.includeSettingsInExportsByDefault, isTrue);

      final restoredDatabase = await targetEnvironment.openIsar();
      final importedProjects = await restoredDatabase.projects
          .where()
          .findAll();
      final importedChapters = await restoredDatabase.structureChapters
          .where()
          .findAll();
      final importedElements = await restoredDatabase.narrativeElements
          .where()
          .findAll();
      final importedRelations = await restoredDatabase.projectRelationTypes
          .where()
          .findAll();
      final importedGroups = await restoredDatabase.projectRelationGroups
          .where()
          .findAll();
      final importedMembers = await restoredDatabase.projectRelationMembers
          .where()
          .findAll();
      final importedCaptures = await restoredDatabase.captureRecords
          .where()
          .findAll();
      final importedSession = await restoredDatabase.projectSessions.get(0);

      expect(importedProjects, hasLength(1));
      expect(importedChapters, hasLength(1));
      expect(importedElements, hasLength(1));
      expect(importedRelations, hasLength(1));
      expect(importedGroups, hasLength(1));
      expect(importedMembers, hasLength(1));
      expect(importedCaptures, hasLength(1));

      final importedProject = importedProjects.single;
      final importedElement = importedElements.single;
      final importedMember = importedMembers.single;
      final importedCapture = importedCaptures.single;

      expect(importedProject.projectId, isNot('project-source'));
      expect(importedProject.title, '雨夜厂区');
      expect(importedProject.themeStatement, '记录雨夜金属与反光');
      expect(importedProject.description, '验证导出导入恢复整套项目数据');
      expect(importedProject.coverImagePath, isNotNull);
      expect(File(importedProject.coverImagePath!).existsSync(), isTrue);
      expect(importedElement.title, '桥洞入口');
      expect(importedElement.photoPaths, hasLength(1));
      expect(File(importedElement.photoPaths.single).existsSync(), isTrue);
      expect(importedMember.linkedPhotoPath, isNotNull);
      expect(File(importedMember.linkedPhotoPath!).existsSync(), isTrue);
      expect(importedCapture.rawText, '记录雨后的地面反光');
      expect(importedCapture.photoPaths, hasLength(1));
      expect(File(importedCapture.photoPaths.single).existsSync(), isTrue);
      expect(importedSession?.currentProjectId, importedProject.projectId);

      await _captureScreenshot(
        binding: binding,
        name: 'settings-export-import-roundtrip',
      );
    },
  );
}

EchoApp _buildApp({
  required _TestAppEnvironment environment,
  required ProjectBundleFileTransfer transfer,
}) {
  final settingsRepository = environment.settingsRepository;
  return EchoApp(
    projectRepository: LocalProjectRepository(openIsar: environment.openIsar),
    structureChapterRepository: LocalStructureChapterRepository(
      openIsar: environment.openIsar,
    ),
    narrativeElementRepository: LocalNarrativeElementRepository(
      openIsar: environment.openIsar,
    ),
    projectRelationRepository: LocalProjectRelationRepository(
      openIsar: environment.openIsar,
    ),
    captureRecordRepository: LocalCaptureRecordRepository(
      openIsar: environment.openIsar,
    ),
    beaconTaskRepository: LocalBeaconTaskRepository(
      openIsar: environment.openIsar,
    ),
    appSettingsRepository: settingsRepository,
    exportProjectBundle: LocalExportProjectBundle(
      openProjectDatabase: environment.openIsar,
      settingsRepository: settingsRepository,
    ),
    importProjectBundle: LocalImportProjectBundle(
      openProjectDatabase: environment.openIsar,
      settingsRepository: settingsRepository,
      mediaIngestPolicy: LocalMediaIngestPolicy(
        settingsRepository: settingsRepository,
      ),
    ),
    projectBundleFileTransfer: transfer,
  );
}

Future<void> _setPhoneSurface(
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await binding.setSurfaceSize(const Size(393, 852));
}

Future<void> _captureScreenshot({
  required IntegrationTestWidgetsFlutterBinding binding,
  required String name,
}) async {
  try {
    final screenshotBytes = await binding.takeScreenshot(name);
    final screenshotFile = File('${Directory.systemTemp.path}/$name.png');
    await screenshotFile.writeAsBytes(screenshotBytes, flush: true);
    debugPrint('SCREENSHOT_PATH=${screenshotFile.path}');
  } catch (error) {
    debugPrint('SCREENSHOT_SKIPPED[$name]=$error');
  }
}

Future<void> _clearRuntimeStorage() async {
  final storageDirectory = Directory(await getAppStorageDirectoryPath());
  if (await storageDirectory.exists()) {
    await storageDirectory.delete(recursive: true);
  }
}

class _FakeProjectBundleFileTransfer implements ProjectBundleFileTransfer {
  _FakeProjectBundleFileTransfer(this.exportRootDirectory);

  final Directory exportRootDirectory;
  String? latestExportedBundlePath;

  @override
  Future<ProjectBundleExportReceipt?> exportBundleDirectory({
    required String bundleDirectoryPath,
    required String suggestedBundleName,
  }) async {
    await exportRootDirectory.create(recursive: true);
    final sourceDirectory = Directory(bundleDirectoryPath);
    final targetPath = p.join(exportRootDirectory.path, suggestedBundleName);
    final targetDirectory = Directory(targetPath);

    if (await targetDirectory.exists()) {
      await targetDirectory.delete(recursive: true);
    }
    await _copyDirectory(sourceDirectory, targetDirectory);
    latestExportedBundlePath = targetDirectory.path;

    return ProjectBundleExportReceipt(
      displayPath: targetDirectory.path,
      copyablePath: targetDirectory.path,
    );
  }

  @override
  Future<ProjectBundleImportSelection?> pickImportBundleDirectory() async {
    final bundlePath = latestExportedBundlePath;
    if (bundlePath == null) {
      return null;
    }
    return ProjectBundleImportSelection(
      bundleDirectoryPath: bundlePath,
      displayPath: bundlePath,
    );
  }

  Future<void> _copyDirectory(
    Directory sourceDirectory,
    Directory targetDirectory,
  ) async {
    await targetDirectory.create(recursive: true);
    await for (final entity in sourceDirectory.list(recursive: false)) {
      final name = p.basename(entity.path);
      final targetPath = p.join(targetDirectory.path, name);
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        await entity.copy(targetPath);
      }
    }
  }
}

class _TestAppEnvironment {
  _TestAppEnvironment._({
    required this.rootDirectory,
    required this.databaseDirectory,
    required this.settingsDirectory,
    required this.fixtureDirectory,
    required this.isarName,
    required this.settingsRepository,
  });

  final Directory rootDirectory;
  final Directory databaseDirectory;
  final Directory settingsDirectory;
  final Directory fixtureDirectory;
  final String isarName;
  final LocalAppSettingsRepository settingsRepository;

  Future<Isar>? _isarFuture;

  static Future<_TestAppEnvironment> create({
    required Directory rootDirectory,
    required String isarName,
  }) async {
    await rootDirectory.create(recursive: true);
    final databaseDirectory = Directory(p.join(rootDirectory.path, 'db'));
    final settingsDirectory = Directory(p.join(rootDirectory.path, 'settings'));
    final fixtureDirectory = Directory(p.join(rootDirectory.path, 'fixtures'));
    await databaseDirectory.create(recursive: true);
    await settingsDirectory.create(recursive: true);
    await fixtureDirectory.create(recursive: true);

    return _TestAppEnvironment._(
      rootDirectory: rootDirectory,
      databaseDirectory: databaseDirectory,
      settingsDirectory: settingsDirectory,
      fixtureDirectory: fixtureDirectory,
      isarName: isarName,
      settingsRepository: LocalAppSettingsRepository(
        resolveStorageDirectoryPath: () async => settingsDirectory.path,
      ),
    );
  }

  Future<Isar> openIsar() {
    return _isarFuture ??= openProjectIsar(
      name: isarName,
      directoryPath: databaseDirectory.path,
    );
  }

  Future<void> seedProjectFixture() async {
    final coverPhoto = await File(
      p.join(fixtureDirectory.path, 'cover.png'),
    ).writeAsBytes(_tinyPngBytes, flush: true);
    final elementPhoto = await File(
      p.join(fixtureDirectory.path, 'element.png'),
    ).writeAsBytes(_tinyPngBytes, flush: true);
    final relationPhoto = await File(
      p.join(fixtureDirectory.path, 'relation.png'),
    ).writeAsBytes(_tinyPngBytes, flush: true);

    final database = await openIsar();
    await database.writeTxn(() async {
      await database.projects.put(
        Project.create(
          id: 'project-source',
          projectTitle: '雨夜厂区',
          projectThemeStatement: '记录雨夜金属与反光',
          projectDescription: '验证导出导入恢复整套项目数据',
          projectCoverImagePath: coverPhoto.path,
          projectStage: '进行',
          createdTimestamp: DateTime(2026, 4, 26, 11, 0),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.structureChapters.put(
        StructureChapter.create(
          id: 'chapter-source',
          projectId: 'project-source',
          chapterTitle: '第一章',
          chapterDescription: '雨夜下的桥洞入口',
          chapterStatus: '进行',
          chapterElementCount: 1,
          chapterSortOrder: 0,
          createdTimestamp: DateTime(2026, 4, 26, 11, 5),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.narrativeElements.put(
        NarrativeElement.create(
          id: 'element-source',
          projectId: 'project-source',
          chapterId: 'chapter-source',
          elementTitle: '桥洞入口',
          elementDescription: '主视觉元素，用于验证照片恢复',
          elementStatus: 'finding',
          elementSortOrder: 0,
          linkedPhotoPaths: <String>[elementPhoto.path],
          createdTimestamp: DateTime(2026, 4, 26, 11, 8),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.projectRelationTypes.put(
        ProjectRelationType.create(
          id: 'relation-type-source',
          projectId: 'project-source',
          relationName: '空间关系',
          relationDescription: '验证关系类型与分组恢复',
          relationSortOrder: 0,
          createdTimestamp: DateTime(2026, 4, 26, 11, 10),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.projectRelationGroups.put(
        ProjectRelationGroup.create(
          id: 'relation-group-source',
          projectId: 'project-source',
          relationTypeId: 'relation-type-source',
          relationGroupTitle: '入口到桥身',
          relationGroupDescription: '验证关系分组与描述恢复',
          createdTimestamp: DateTime(2026, 4, 26, 11, 12),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.projectRelationMembers.put(
        ProjectRelationMember.create(
          id: 'relation-member-source',
          projectId: 'project-source',
          groupId: 'relation-group-source',
          targetKind: 'photo',
          elementId: 'element-source',
          photoPath: relationPhoto.path,
          sourceElementId: 'element-source',
          sortOrder: 0,
          createdTimestamp: DateTime(2026, 4, 26, 11, 15),
        ),
      );
      await database.captureRecords.put(
        CaptureRecord.create(
          id: 'capture-source',
          projectId: 'project-source',
          captureMode: 'record',
          captureText: '记录雨后的地面反光',
          capturedPhotoPaths: <String>[elementPhoto.path],
          pendingPhotoPaths: <String>[elementPhoto.path],
          createdTimestamp: DateTime(2026, 4, 26, 11, 18),
          updatedTimestamp: DateTime(2026, 4, 26, 11, 30),
        ),
      );
      await database.projectSessions.put(
        ProjectSession()..currentProjectId = 'project-source',
      );
    });
  }

  Future<void> dispose({bool deleteRootDirectory = false}) async {
    if (_isarFuture != null) {
      final isar = await _isarFuture!;
      if (isar.isOpen) {
        await isar.close();
      }
      _isarFuture = null;
    }

    if (deleteRootDirectory && await rootDirectory.exists()) {
      await rootDirectory.delete(recursive: true);
    }
  }
}

const List<int> _tinyPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
