import 'package:echo/features/beacon/domain/entities/beacon_task.dart';

abstract class BeaconTaskRepository {
  Future<List<BeaconTask>> listTasksForProject(String projectId);

  Future<BeaconTask> createTask({
    required String projectId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  });

  Future<BeaconTask?> updateTask({
    required String taskId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  });

  Future<BeaconTask?> archiveTask(String taskId);

  Future<bool> deleteTask(String taskId);
}
