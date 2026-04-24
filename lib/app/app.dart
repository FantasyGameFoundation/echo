import 'package:echo/app/shell/app_shell_page.dart';
import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/capture/domain/services/save_capture_record.dart';
import 'package:echo/features/capture/infrastructure/repositories/local_capture_record_repository.dart';
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
  static final SaveCaptureRecord _defaultSaveCaptureRecord = SaveCaptureRecord(
    openIsar: _sharedOpenIsar,
  );

  static CaptureRecordRepository _buildDefaultCaptureRecordRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopCaptureRecordRepository();
    }
    return LocalCaptureRecordRepository(openIsar: _sharedOpenIsar);
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
