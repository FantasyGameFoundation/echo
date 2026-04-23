import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/services/extract_text_card_from_record.dart';
import 'package:echo/features/capture/domain/services/save_capture_record.dart';
import 'package:echo/features/capture/infrastructure/repositories/local_capture_record_repository.dart';
import 'package:echo/features/content_cards/infrastructure/repositories/local_text_card_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_narrative_element_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  test(
    'save capture record in record-only mode persists only one record',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-save-capture-record-only',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_save_capture_record_only',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final saveCaptureRecord = SaveCaptureRecord(openIsar: openIsar);
      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final narrativeRepository = LocalNarrativeElementRepository(
        openIsar: openIsar,
      );

      final result = await saveCaptureRecord.execute(
        const SaveCaptureRequest(
          projectId: 'project-a',
          mode: CaptureMode.recordOnly,
          rawText: '只记原始内容',
          photoPaths: <String>['/tmp/source-a.jpg'],
        ),
      );

      expect(result.recordId, isNotEmpty);
      expect(result.photoCardElementId, isNull);
      expect(result.textCardId, isNull);
      expect(
        await captureRepository.listRecordsForProject('project-a'),
        hasLength(1),
      );
      expect(
        await textCardRepository.listTextCardsForProject('project-a'),
        isEmpty,
      );
      expect(
        await narrativeRepository.listElementsForProject('project-a'),
        isEmpty,
      );

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'save capture record persists text-only and creates a text card in text mode',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-save-capture-text',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_save_capture_text',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final saveCaptureRecord = SaveCaptureRecord(openIsar: openIsar);
      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final narrativeRepository = LocalNarrativeElementRepository(
        openIsar: openIsar,
      );

      final result = await saveCaptureRecord.execute(
        const SaveCaptureRequest(
          projectId: 'project-a',
          mode: CaptureMode.text,
          rawText: '第一行标题\n第二行正文',
          photoPaths: <String>[],
        ),
      );

      final records = await captureRepository.listRecordsForProject(
        'project-a',
      );
      final textCards = await textCardRepository.listTextCardsForProject(
        'project-a',
      );
      final elements = await narrativeRepository.listElementsForProject(
        'project-a',
      );

      expect(result.recordId, isNotEmpty);
      expect(result.photoCardElementId, isNull);
      expect(result.textCardId, isNotNull);
      expect(records.single.rawText, '第一行标题\n第二行正文');
      expect(textCards.single.title, '第一行标题');
      expect(textCards.single.body, '第一行标题\n第二行正文');
      expect(textCards.single.sourceCaptureRecordId, records.single.recordId);
      expect(textCards.single.owningChapterId, isNull);
      expect(elements, isEmpty);

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'save capture record persists photo-only and keeps photos pending in the capture record',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-save-capture-photo',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_save_capture_photo',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final saveCaptureRecord = SaveCaptureRecord(openIsar: openIsar);
      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final narrativeRepository = LocalNarrativeElementRepository(
        openIsar: openIsar,
      );

      final result = await saveCaptureRecord.execute(
        const SaveCaptureRequest(
          projectId: 'project-a',
          mode: CaptureMode.photo,
          rawText: '',
          photoPaths: <String>['/tmp/photo-a.jpg', '/tmp/photo-b.jpg'],
        ),
      );

      final records = await captureRepository.listRecordsForProject(
        'project-a',
      );
      final textCards = await textCardRepository.listTextCardsForProject(
        'project-a',
      );
      final elements = await narrativeRepository.listElementsForProject(
        'project-a',
      );

      expect(result.recordId, isNotEmpty);
      expect(result.photoCardElementId, isNull);
      expect(result.textCardId, isNull);
      expect(records.single.photoPaths, <String>[
        '/tmp/photo-a.jpg',
        '/tmp/photo-b.jpg',
      ]);
      expect(records.single.unorganizedPhotoPaths, <String>[
        '/tmp/photo-a.jpg',
        '/tmp/photo-b.jpg',
      ]);
      expect(elements, isEmpty);
      expect(textCards, isEmpty);

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'save capture record in all mode persists record plus text card and keeps photos pending',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-save-capture-all',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_save_capture_all',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final saveCaptureRecord = SaveCaptureRecord(openIsar: openIsar);
      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final narrativeRepository = LocalNarrativeElementRepository(
        openIsar: openIsar,
      );

      final result = await saveCaptureRecord.execute(
        const SaveCaptureRequest(
          projectId: 'project-a',
          mode: CaptureMode.all,
          rawText: '混合标题\n混合正文',
          photoPaths: <String>['/tmp/photo-a.jpg'],
        ),
      );

      final records = await captureRepository.listRecordsForProject(
        'project-a',
      );
      final textCards = await textCardRepository.listTextCardsForProject(
        'project-a',
      );
      final elements = await narrativeRepository.listElementsForProject(
        'project-a',
      );

      expect(result.photoCardElementId, isNull);
      expect(result.textCardId, isNotNull);
      expect(records, hasLength(1));
      expect(textCards, hasLength(1));
      expect(elements, isEmpty);
      expect(textCards.single.title, '混合标题');
      expect(records.single.unorganizedPhotoPaths, <String>[
        '/tmp/photo-a.jpg',
      ]);

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'save capture record rolls back all persisted rows on failure',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-save-capture-rollback',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_save_capture_rollback',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final saveCaptureRecord = SaveCaptureRecord(openIsar: openIsar)
        ..debugBeforeDerivedRows = () async {
          throw StateError('forced-failure');
        };
      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final narrativeRepository = LocalNarrativeElementRepository(
        openIsar: openIsar,
      );

      await expectLater(
        saveCaptureRecord.execute(
          const SaveCaptureRequest(
            projectId: 'project-a',
            mode: CaptureMode.all,
            rawText: '会失败',
            photoPaths: <String>['/tmp/photo-a.jpg'],
          ),
        ),
        throwsStateError,
      );

      expect(
        await captureRepository.listRecordsForProject('project-a'),
        isEmpty,
      );
      expect(
        await textCardRepository.listTextCardsForProject('project-a'),
        isEmpty,
      );
      expect(
        await narrativeRepository.listElementsForProject('project-a'),
        isEmpty,
      );

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'extract text card from one record supports repeated extraction',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-extract-text-card',
      );
      final sharedIsarFuture = openProjectIsar(
        name: 'echo_extract_text_card',
        directoryPath: directory.path,
      );
      Future<Isar> openIsar() => sharedIsarFuture;

      final captureRepository = LocalCaptureRecordRepository(
        openIsar: openIsar,
      );
      final textCardRepository = LocalTextCardRepository(openIsar: openIsar);
      final extractor = ExtractTextCardFromRecord(
        captureRecordRepository: captureRepository,
        textCardRepository: textCardRepository,
      );

      final record = await captureRepository.createRecord(
        projectId: 'project-a',
        mode: CaptureMode.recordOnly.storageValue,
        rawText: '原始标题\n原始正文',
        photoPaths: const <String>[],
      );

      final cardA = await extractor.extractTextCard(recordId: record.recordId);
      final cardB = await extractor.extractTextCard(
        recordId: record.recordId,
        titleOverride: '第二张卡片',
        bodyOverride: '第二张卡片\n新的正文',
      );

      final cards = await textCardRepository.listTextCardsForProject(
        'project-a',
      );
      final refreshedRecord = await captureRepository.getRecordById(
        record.recordId,
      );

      expect(cardA.textCardId, isNot(cardB.textCardId));
      expect(cards.length, 2);
      expect(cards.first.sourceCaptureRecordId, record.recordId);
      expect(cards.last.sourceCaptureRecordId, record.recordId);
      expect(refreshedRecord?.rawText, '原始标题\n原始正文');

      await (await sharedIsarFuture).close();
      await directory.delete(recursive: true);
    },
  );
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
