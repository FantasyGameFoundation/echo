import 'package:echo/features/project/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Project> createProject({
    required String title,
    required String themeStatement,
    String? description,
    String? coverImagePath,
  });

  Future<Project?> getCurrentProject();

  Future<List<Project>> listProjects();

  Future<void> setCurrentProject(String projectId);

  Future<Project?> updateProject({
    required String projectId,
    required String title,
    required String themeStatement,
    String? coverImagePath,
  });

  Future<Project?> archiveProject(String projectId);

  Future<void> deleteProject(String projectId);
}
