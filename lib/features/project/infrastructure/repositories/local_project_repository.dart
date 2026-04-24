import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/project_relation_defaults.dart';
import 'package:isar/isar.dart';

class LocalProjectRepository implements ProjectRepository {
  LocalProjectRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar().catchError((error) {
      _isarFuture = null;
      throw error;
    });
  }

  @override
  Future<Project> createProject({
    required String title,
    required String themeStatement,
    String? description,
    String? coverImagePath,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final project = Project.create(
      projectTitle: title.trim(),
      projectThemeStatement: themeStatement.trim(),
      projectDescription: description?.trim(),
      projectCoverImagePath: coverImagePath,
      createdTimestamp: now,
      updatedTimestamp: now,
    );
    final defaultRelationTypes = defaultProjectRelationDefinitions
        .map(
          (definition) => ProjectRelationType.create(
            projectId: project.projectId,
            relationName: definition.name,
            relationDescription: definition.description,
            relationSortOrder: definition.sortOrder,
            createdTimestamp: now,
            updatedTimestamp: now,
          ),
        )
        .toList();

    await database.writeTxn(() async {
      await database.projects.put(project);
      await database.projectRelationTypes.putAll(defaultRelationTypes);
      await database.projectSessions.put(
        ProjectSession()..currentProjectId = project.projectId,
      );
    });

    return project;
  }

  @override
  Future<Project?> getCurrentProject() async {
    final database = await _database();
    final session = await database.projectSessions.get(0);
    final currentProjectId = session?.currentProjectId;
    if (currentProjectId == null) {
      return null;
    }

    return database.projects
        .filter()
        .projectIdEqualTo(currentProjectId)
        .findFirst();
  }

  @override
  Future<List<Project>> listProjects() async {
    final database = await _database();
    final projects = await database.projects.where().findAll();
    projects.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return projects;
  }

  @override
  Future<void> setCurrentProject(String projectId) async {
    final database = await _database();
    final matchingProject = await database.projects
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    if (matchingProject == null) {
      return;
    }

    await database.writeTxn(() async {
      await database.projectSessions.put(
        ProjectSession()..currentProjectId = projectId,
      );
    });
  }

  @override
  Future<Project?> updateProject({
    required String projectId,
    required String title,
    required String themeStatement,
    String? coverImagePath,
  }) async {
    final database = await _database();
    final project = await database.projects
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    if (project == null) {
      return null;
    }

    project.title = title.trim();
    project.themeStatement = themeStatement.trim();
    project.coverImagePath = coverImagePath;
    project.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.projects.put(project);
    });

    return project;
  }

  @override
  Future<Project?> archiveProject(String projectId) async {
    final database = await _database();
    final project = await database.projects
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    if (project == null) {
      return null;
    }

    project.stage = project.stage == 'completed' ? 'draft' : 'completed';
    project.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.projects.put(project);
    });

    return project;
  }

  @override
  Future<void> deleteProject(String projectId) async {
    final database = await _database();
    final project = await database.projects
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    if (project == null) {
      return;
    }

    final session = await database.projectSessions.get(0);

    await database.writeTxn(() async {
      await database.projects.delete(project.isarId);

      if (session?.currentProjectId == projectId) {
        final remainingProjects = await database.projects.where().findAll();
        remainingProjects.sort(
          (left, right) => right.updatedAt.compareTo(left.updatedAt),
        );
        await database.projectSessions.put(
          ProjectSession()
            ..currentProjectId = remainingProjects.isEmpty
                ? null
                : remainingProjects.first.projectId,
        );
      }
    });
  }

  Future<void> close() async {
    final database = await _database();
    await database.close();
    _isarFuture = null;
  }
}
