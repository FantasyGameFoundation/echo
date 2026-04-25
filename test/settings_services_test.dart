import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/services/export_project_bundle.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/domain/services/media_ingest_policy.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';
import 'package:echo/features/settings/infrastructure/services/local_export_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_import_project_bundle.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: <Abi, String>{
        Abi.current(): await _resolveIsarLibraryPath(),
      },
    );
  });

  test('local app settings repository persists compression choice', () async {
    final directory = await Directory.systemTemp.createTemp(
      'echo-settings-repo-test',
    );
    final repository = LocalAppSettingsRepository(
      resolveStorageDirectoryPath: () async => directory.path,
    );

    await repository.update(
      compressionLevel: AppMediaCompressionLevel.highQuality,
      includeSettingsInExportsByDefault: true,
    );

    final restoredRepository = LocalAppSettingsRepository(
      resolveStorageDirectoryPath: () async => directory.path,
    );
    final restoredSettings = await restoredRepository.load();

    expect(
      restoredSettings.compressionLevel,
      AppMediaCompressionLevel.highQuality,
    );
    expect(restoredSettings.includeSettingsInExportsByDefault, isTrue);

    await directory.delete(recursive: true);
  });

  test('media importer resizes oversized images when compression is enabled', () async {
    final directory = await Directory.systemTemp.createTemp(
      'echo-media-importer-test',
    );
    final sourceFile = File('${directory.path}/oversized.png');
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 3000, 2000),
      ui.Paint()..color = const ui.Color(0xFF111111),
    );
    final image = await recorder.endRecording().toImage(3000, 2000);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await sourceFile.writeAsBytes(byteData!.buffer.asUint8List());

    final imported = await importMediaFileWithPolicy(
      sourcePath: sourceFile.path,
      collection: 'settings_test_media',
      policy: const _FixedMediaIngestPolicy(
        AppMediaCompressionLevel.standard,
      ),
    );

    final buffer = await ui.ImmutableBuffer.fromFilePath(imported.path);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);

    expect(imported.plan.compressionLevel, AppMediaCompressionLevel.standard);
    expect(descriptor.width, lessThanOrEqualTo(1920));
    expect(descriptor.height, lessThanOrEqualTo(1080));

    descriptor.dispose();
    buffer.dispose();
    await File(imported.path).delete();
    await directory.delete(recursive: true);
  });

  test('export project bundle writes manifest, media, and settings payload', () async {
    final rootDirectory = await Directory.systemTemp.createTemp(
      'echo-export-bundle-test',
    );
    final databaseDirectory = Directory('${rootDirectory.path}/db');
    await databaseDirectory.create(recursive: true);
    final settingsDirectory = Directory('${rootDirectory.path}/settings');
    await settingsDirectory.create(recursive: true);
    final bundleDirectory = Directory('${rootDirectory.path}/bundle');

    final coverFile = await File('${rootDirectory.path}/cover.jpg').writeAsBytes(
      <int>[1, 2, 3, 4],
    );
    final elementPhotoFile = await File(
      '${rootDirectory.path}/element.jpg',
    ).writeAsBytes(<int>[5, 6, 7, 8]);

    Future<Isar> openIsar() => openProjectIsar(
      name: 'echo_export_bundle_test',
      directoryPath: databaseDirectory.path,
    );

    final database = await openIsar();
    await database.writeTxn(() async {
      await database.projects.put(
        Project.create(
          id: 'project-export',
          projectTitle: '雾面高架',
          projectThemeStatement: '追踪高架桥下的灰尘与回声',
          projectCoverImagePath: coverFile.path,
        ),
      );
      await database.structureChapters.put(
        StructureChapter.create(
          id: 'chapter-export',
          projectId: 'project-export',
          chapterTitle: '高架桥下',
        ),
      );
      await database.narrativeElements.put(
        NarrativeElement.create(
          id: 'element-export',
          projectId: 'project-export',
          chapterId: 'chapter-export',
          elementTitle: '桥墩阴影',
          linkedPhotoPaths: <String>[elementPhotoFile.path],
        ),
      );
      await database.captureRecords.put(
        CaptureRecord.create(
          id: 'capture-export',
          projectId: 'project-export',
          captureMode: 'record',
          captureText: '现场潮湿，车辆回响明显。',
          capturedPhotoPaths: <String>[elementPhotoFile.path],
        ),
      );
      await database.beaconTasks.put(
        BeaconTask.create(
          id: 'task-export',
          projectId: 'project-export',
          taskTitle: '寻找桥墩反光',
          taskDescription: '注意桥墩表面的水迹与反射。',
          linkedElementIds: <String>['element-export'],
        ),
      );
      await database.projectSessions.put(
        ProjectSession()..currentProjectId = 'project-export',
      );
    });

    final settingsRepository = LocalAppSettingsRepository(
      resolveStorageDirectoryPath: () async => settingsDirectory.path,
    );
    await settingsRepository.save(
      AppSettings(
        compressionLevel: AppMediaCompressionLevel.standard,
        includeSettingsInExportsByDefault: true,
      ),
    );

    final service = LocalExportProjectBundle(
      openProjectDatabase: openIsar,
      settingsRepository: settingsRepository,
    );

    final result = await service.execute(
      ExportProjectBundleRequest(
        projectId: 'project-export',
        bundleDirectoryPath: bundleDirectory.path,
      ),
    );

    final manifestFile = File(result.manifestPath);
    final settingsFile = File(
      '${bundleDirectory.path}/$projectBundleSettingsFileName',
    );
    final manifest = jsonDecode(await manifestFile.readAsString())
        as Map<String, dynamic>;

    expect(await manifestFile.exists(), isTrue);
    expect(await settingsFile.exists(), isTrue);
    expect(result.includedSettings, isTrue);
    expect(manifest['formatVersion'], projectBundleFormatVersion);
    expect((manifest['mediaEntries'] as List<dynamic>).isNotEmpty, isTrue);
    expect((manifest['project'] as Map<String, dynamic>)['title'], '雾面高架');

    await database.close();
    await rootDirectory.delete(recursive: true);
  });

  test('bundle inspection returns false when exported bundle omits settings', () async {
    final rootDirectory = await Directory.systemTemp.createTemp(
      'echo-export-bundle-no-settings-test',
    );
    final databaseDirectory = Directory('${rootDirectory.path}/db');
    final settingsDirectory = Directory('${rootDirectory.path}/settings');
    final targetDatabaseDirectory = Directory('${rootDirectory.path}/target-db');
    final bundleDirectory = Directory('${rootDirectory.path}/bundle');
    await databaseDirectory.create(recursive: true);
    await settingsDirectory.create(recursive: true);
    await targetDatabaseDirectory.create(recursive: true);

    Future<Isar> openIsar() => openProjectIsar(
      name: 'echo_export_bundle_no_settings_test',
      directoryPath: databaseDirectory.path,
    );
    Future<Isar> openTargetIsar() => openProjectIsar(
      name: 'echo_export_bundle_no_settings_target_test',
      directoryPath: targetDatabaseDirectory.path,
    );

    final database = await openIsar();
    await database.writeTxn(() async {
      await database.projects.put(
        Project.create(
          id: 'project-export-no-settings',
          projectTitle: '静夜空站',
          projectThemeStatement: '记录空站与光带',
        ),
      );
    });

    final settingsRepository = LocalAppSettingsRepository(
      resolveStorageDirectoryPath: () async => settingsDirectory.path,
    );
    await settingsRepository.save(
      AppSettings(
        compressionLevel: AppMediaCompressionLevel.standard,
        includeSettingsInExportsByDefault: true,
      ),
    );

    final exportService = LocalExportProjectBundle(
      openProjectDatabase: openIsar,
      settingsRepository: settingsRepository,
    );
    await exportService.execute(
      ExportProjectBundleRequest(
        projectId: 'project-export-no-settings',
        bundleDirectoryPath: bundleDirectory.path,
        includeSettings: false,
      ),
    );

    final importService = LocalImportProjectBundle(
      openProjectDatabase: openTargetIsar,
      settingsRepository: settingsRepository,
    );

    final inspection = await importService.inspect(bundleDirectory.path);
    expect(inspection.hasSettingsPayload, isFalse);
    expect(inspection.oversizedMediaCount, 0);
    expect(
      await File('${bundleDirectory.path}/$projectBundleSettingsFileName')
          .exists(),
      isFalse,
    );

    await database.close();
    await rootDirectory.delete(recursive: true);
  });

  test(
    'import project bundle creates a new project and can apply imported settings',
    () async {
      final rootDirectory = await Directory.systemTemp.createTemp(
        'echo-import-bundle-test',
      );

      final sourceDatabaseDirectory = Directory('${rootDirectory.path}/source-db');
      final sourceSettingsDirectory = Directory(
        '${rootDirectory.path}/source-settings',
      );
      final bundleDirectory = Directory('${rootDirectory.path}/bundle');
      final targetDatabaseDirectory = Directory('${rootDirectory.path}/target-db');
      final targetSettingsDirectory = Directory(
        '${rootDirectory.path}/target-settings',
      );
      await sourceDatabaseDirectory.create(recursive: true);
      await sourceSettingsDirectory.create(recursive: true);
      await targetDatabaseDirectory.create(recursive: true);
      await targetSettingsDirectory.create(recursive: true);

      final photoFile = await File('${rootDirectory.path}/source-photo.jpg')
          .writeAsBytes(<int>[9, 10, 11, 12]);

      Future<Isar> openSourceIsar() => openProjectIsar(
        name: 'echo_import_bundle_source_test',
        directoryPath: sourceDatabaseDirectory.path,
      );
      Future<Isar> openTargetIsar() => openProjectIsar(
        name: 'echo_import_bundle_target_test',
        directoryPath: targetDatabaseDirectory.path,
      );

      final sourceDatabase = await openSourceIsar();
      await sourceDatabase.writeTxn(() async {
        await sourceDatabase.projects.put(
          Project.create(
            id: 'project-source',
            projectTitle: '雨夜厂区',
            projectThemeStatement: '记录厂区雨夜里高光与蒸汽的关系',
            projectCoverImagePath: photoFile.path,
          ),
        );
        await sourceDatabase.structureChapters.put(
          StructureChapter.create(
            id: 'chapter-source',
            projectId: 'project-source',
            chapterTitle: '雨夜边缘',
          ),
        );
        await sourceDatabase.narrativeElements.put(
          NarrativeElement.create(
            id: 'element-source',
            projectId: 'project-source',
            chapterId: 'chapter-source',
            elementTitle: '路灯蒸汽',
            linkedPhotoPaths: <String>[photoFile.path],
          ),
        );
        await sourceDatabase.captureRecords.put(
          CaptureRecord.create(
            id: 'capture-source',
            projectId: 'project-source',
            captureMode: 'record',
            capturedPhotoPaths: <String>[photoFile.path],
          ),
        );
        await sourceDatabase.projectSessions.put(
          ProjectSession()..currentProjectId = 'project-source',
        );
      });

      final sourceSettingsRepository = LocalAppSettingsRepository(
        resolveStorageDirectoryPath: () async => sourceSettingsDirectory.path,
      );
      await sourceSettingsRepository.save(
        AppSettings(
          compressionLevel: AppMediaCompressionLevel.highQuality,
          includeSettingsInExportsByDefault: true,
        ),
      );

      final exportService = LocalExportProjectBundle(
        openProjectDatabase: openSourceIsar,
        settingsRepository: sourceSettingsRepository,
      );
      await exportService.execute(
        ExportProjectBundleRequest(
          projectId: 'project-source',
          bundleDirectoryPath: bundleDirectory.path,
          includeSettings: true,
        ),
      );

      final targetSettingsRepository = LocalAppSettingsRepository(
        resolveStorageDirectoryPath: () async => targetSettingsDirectory.path,
      );
      await targetSettingsRepository.save(
        AppSettings(
          compressionLevel: AppMediaCompressionLevel.none,
          includeSettingsInExportsByDefault: false,
        ),
      );

      final importService = LocalImportProjectBundle(
        openProjectDatabase: openTargetIsar,
        settingsRepository: targetSettingsRepository,
      );

      final inspection = await importService.inspect(bundleDirectory.path);
      expect(inspection.hasSettingsPayload, isTrue);

      final importResult = await importService.execute(
        ImportProjectBundleRequest(
          bundleDirectoryPath: bundleDirectory.path,
          applyImportedSettings: true,
        ),
      );

      final targetDatabase = await openTargetIsar();
      final importedProjects = await targetDatabase.projects.where().findAll();
      final importedProject = importedProjects.single;
      final importedCaptures = await targetDatabase.captureRecords.where().findAll();
      final restoredSettings = await targetSettingsRepository.load();
      final session = await targetDatabase.projectSessions.get(0);

      expect(importedProject.projectId, isNot('project-source'));
      expect(importedProject.title, '雨夜厂区');
      expect(importResult.hadSettingsPayload, isTrue);
      expect(importResult.appliedImportedSettings, isTrue);
      expect(restoredSettings.compressionLevel, AppMediaCompressionLevel.highQuality);
      expect(session?.currentProjectId, importedProject.projectId);
      expect(importedProject.coverImagePath, isNot(photoFile.path));
      expect(importedProject.coverImagePath, isNotNull);
      expect(importedCaptures.single.rawText, '');

      await sourceDatabase.close();
      await targetDatabase.close();
      await rootDirectory.delete(recursive: true);
    },
  );
}

class _FixedMediaIngestPolicy implements MediaIngestPolicy {
  const _FixedMediaIngestPolicy(this.compressionLevel);

  final AppMediaCompressionLevel compressionLevel;

  @override
  Future<MediaIngestPlan> resolve({
    required String sourcePath,
    required String collection,
  }) async {
    return MediaIngestPlan(
      compressionLevel: compressionLevel,
      preferredMaxShortEdgePx: compressionLevel.preferredMaxShortEdgePx,
      preferredMaxLongEdgePx: compressionLevel.preferredMaxLongEdgePx,
    );
  }
}

Future<String> _resolveIsarLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json');
  final packageConfig =
      jsonDecode(await packageConfigFile.readAsString())
          as Map<String, dynamic>;
  final packages = packageConfig['packages'] as List<dynamic>;

  final isarFlutterLibsPackage = packages
      .cast<Map<String, dynamic>>()
      .firstWhere((package) => package['name'] == 'isar_flutter_libs');
  final packageRoot = Uri.parse(isarFlutterLibsPackage['rootUri'] as String);
  final packageDirectory = packageRoot.isAbsolute
      ? Directory.fromUri(packageRoot)
      : Directory.fromUri(packageConfigFile.parent.uri.resolveUri(packageRoot));

  if (Platform.isMacOS) {
    return '${packageDirectory.path}/macos/libisar.dylib';
  }
  if (Platform.isLinux) {
    return '${packageDirectory.path}/linux/libisar.so';
  }
  if (Platform.isWindows) {
    return '${packageDirectory.path}/windows/isar.dll';
  }

  throw UnsupportedError(
    'Isar core path resolution is not configured for this platform.',
  );
}
