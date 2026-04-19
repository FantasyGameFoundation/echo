import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/app/shell/app_shell_page.dart';
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

class EchoApp extends StatelessWidget {
  const EchoApp({
    super.key,
    this.projectRepository,
    this.structureChapterRepository,
    this.narrativeElementRepository,
    this.projectRelationRepository,
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
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

  final ProjectRepository? projectRepository;
  final StructureChapterRepository? structureChapterRepository;
  final NarrativeElementRepository? narrativeElementRepository;
  final ProjectRelationRepository? projectRelationRepository;
  final PickProjectCoverImage? narrativeElementPhotoPicker;
  final ImportNarrativePhoto? narrativeElementPhotoImporter;

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
        narrativeElementPhotoPicker: narrativeElementPhotoPicker,
        narrativeElementPhotoImporter: narrativeElementPhotoImporter,
      ),
    );
  }
}
