import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/app/shell/app_shell_page.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/capture/domain/services/save_capture_record.dart';
import 'package:echo/features/capture/infrastructure/repositories/local_capture_record_repository.dart';
import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:echo/features/content_cards/domain/repositories/text_card_repository.dart';
import 'package:echo/features/content_cards/infrastructure/repositories/local_text_card_repository.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

typedef SaveCaptureRecordRunner =
    Future<SaveCaptureResult> Function(SaveCaptureRequest request);

class EchoApp extends StatelessWidget {
  const EchoApp({
    super.key,
    this.projectRepository,
    this.structureChapterRepository,
    this.narrativeElementRepository,
    this.projectRelationRepository,
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
    this.capturePhotoPicker,
    this.saveCaptureRecord,
    this.captureRecordRepository,
    this.textCardRepository,
  });

  static final Future<Isar> _sharedIsarFuture = openProjectIsar();

  static Future<Isar> _sharedOpenIsar() => _sharedIsarFuture;

  static final ProjectRepository _defaultProjectRepository =
      LocalProjectRepository(openIsar: _sharedOpenIsar);
  static final StructureChapterRepository _defaultStructureChapterRepository =
      LocalStructureChapterRepository(openIsar: _sharedOpenIsar);
  static final NarrativeElementRepository _defaultNarrativeElementRepository =
      LocalNarrativeElementRepository(openIsar: _sharedOpenIsar);
  static final ProjectRelationRepository _defaultProjectRelationRepository =
      LocalProjectRelationRepository(openIsar: _sharedOpenIsar);
  static final CaptureRecordRepository _defaultCaptureRecordRepository =
      _buildDefaultCaptureRecordRepository();
  static final TextCardRepository _defaultTextCardRepository =
      _buildDefaultTextCardRepository();
  static final SaveCaptureRecord _defaultSaveCaptureRecord = SaveCaptureRecord(
    openIsar: _sharedOpenIsar,
  );

  static CaptureRecordRepository _buildDefaultCaptureRecordRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopCaptureRecordRepository();
    }
    return LocalCaptureRecordRepository(openIsar: _sharedOpenIsar);
  }

  static TextCardRepository _buildDefaultTextCardRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopTextCardRepository();
    }
    return LocalTextCardRepository(openIsar: _sharedOpenIsar);
  }

  static bool get _isUnderWidgetTestRuntime {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('Test');
  }

  final ProjectRepository? projectRepository;
  final StructureChapterRepository? structureChapterRepository;
  final NarrativeElementRepository? narrativeElementRepository;
  final ProjectRelationRepository? projectRelationRepository;
  final PickGalleryImages? narrativeElementPhotoPicker;
  final ImportNarrativePhoto? narrativeElementPhotoImporter;
  final PickCapturedPhoto? capturePhotoPicker;
  final SaveCaptureRecordRunner? saveCaptureRecord;
  final CaptureRecordRepository? captureRecordRepository;
  final TextCardRepository? textCardRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      theme: AppTheme.light(),
      home: AppShellPage(
        projectRepository: projectRepository ?? _defaultProjectRepository,
        structureChapterRepository:
            structureChapterRepository ?? _defaultStructureChapterRepository,
        narrativeElementRepository:
            narrativeElementRepository ?? _defaultNarrativeElementRepository,
        projectRelationRepository:
            projectRelationRepository ?? _defaultProjectRelationRepository,
        captureRecordRepository:
            captureRecordRepository ?? _defaultCaptureRecordRepository,
        textCardRepository: textCardRepository ?? _defaultTextCardRepository,
        narrativeElementPhotoPicker: narrativeElementPhotoPicker,
        narrativeElementPhotoImporter: narrativeElementPhotoImporter,
        capturePhotoPicker: capturePhotoPicker,
        onSaveCaptureRecord:
            saveCaptureRecord ?? _defaultSaveCaptureRecord.execute,
      ),
    );
  }
}

class _NoopCaptureRecordRepository implements CaptureRecordRepository {
  final List<CaptureRecord> _records = <CaptureRecord>[];

  @override
  Future<CaptureRecord> createRecord({
    required String projectId,
    required String mode,
    String? rawText,
    required List<String> photoPaths,
  }) async {
    final record = CaptureRecord.create(
      projectId: projectId,
      captureMode: mode,
      captureText: rawText,
      capturedPhotoPaths: photoPaths,
      pendingPhotoPaths: photoPaths,
    );
    _records.add(record);
    return record;
  }

  @override
  Future<CaptureRecord?> getRecordById(String recordId) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<CaptureRecord>> listRecordsForProject(String projectId) async {
    return _records
        .where((record) => record.owningProjectId == projectId)
        .toList(growable: false);
  }

  @override
  Future<CaptureRecord?> updatePendingPhotoPaths({
    required String recordId,
    required List<String> pendingPhotoPaths,
  }) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        record.unorganizedPhotoPaths = List<String>.from(pendingPhotoPaths);
        return record;
      }
    }
    return null;
  }
}

class _NoopTextCardRepository implements TextCardRepository {
  final List<TextCard> _cards = <TextCard>[];

  @override
  Future<TextCard> createTextCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String title,
    required String body,
    int? sortOrder,
  }) async {
    final card = TextCard.create(
      projectId: projectId,
      chapterId: chapterId,
      elementId: elementId,
      sourceRecordId: sourceRecordId,
      title: title,
      body: body,
      cardSortOrder: sortOrder ?? _cards.length,
    );
    _cards.add(card);
    return card;
  }

  @override
  Future<TextCard> createCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String rawText,
    int? sortOrder,
  }) {
    return createTextCard(
      projectId: projectId,
      chapterId: chapterId,
      elementId: elementId,
      sourceRecordId: sourceRecordId,
      title: TextCard.deriveTitle(rawText),
      body: TextCard.normalizeBody(rawText),
      sortOrder: sortOrder,
    );
  }

  @override
  Future<TextCard?> getTextCardById(String textCardId) async {
    for (final card in _cards) {
      if (card.textCardId == textCardId) {
        return card;
      }
    }
    return null;
  }

  @override
  Future<TextCard?> getCardById(String textCardId) {
    return getTextCardById(textCardId);
  }

  @override
  Future<List<TextCard>> listTextCardsForProject(String projectId) async {
    return _cards
        .where((card) => card.owningProjectId == projectId)
        .toList(growable: false);
  }

  @override
  Future<List<TextCard>> listCardsForProject(String projectId) {
    return listTextCardsForProject(projectId);
  }

  @override
  Future<List<TextCard>> listTextCardsForSourceRecord(
    String sourceRecordId,
  ) async {
    return _cards
        .where((card) => card.sourceRecordId == sourceRecordId)
        .toList(growable: false);
  }

  @override
  Future<List<TextCard>> listCardsForSourceRecord(String sourceRecordId) {
    return listTextCardsForSourceRecord(sourceRecordId);
  }

  @override
  Future<TextCard?> updateTextCard({
    required String textCardId,
    required String title,
    required String body,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    int? sortOrder,
  }) async {
    for (final card in _cards) {
      if (card.textCardId == textCardId) {
        card.title = title;
        card.body = body;
        card.owningChapterId = chapterId;
        card.owningElementId = elementId;
        card.sourceRecordId = sourceRecordId;
        if (sortOrder != null) {
          card.sortOrder = sortOrder;
        }
        return card;
      }
    }
    return null;
  }
}
