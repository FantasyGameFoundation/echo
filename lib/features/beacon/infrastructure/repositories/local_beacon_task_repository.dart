import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/beacon/domain/repositories/beacon_task_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:isar/isar.dart';

class LocalBeaconTaskRepository implements BeaconTaskRepository {
  LocalBeaconTaskRepository({Future<Isar> Function()? openIsar})
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
  Future<List<BeaconTask>> listTasksForProject(String projectId) async {
    final database = await _database();
    final tasks = await database.beaconTasks
        .filter()
        .owningProjectIdEqualTo(projectId.trim())
        .findAll();
    tasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  @override
  Future<BeaconTask> createTask({
    required String projectId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final task = BeaconTask.create(
      projectId: projectId.trim(),
      taskTitle: title.trim(),
      taskDescription: description.trim(),
      linkedElementIds: _normalizeElementIds(linkedElementIds),
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.beaconTasks.put(task);
    });
    return task;
  }

  @override
  Future<BeaconTask?> updateTask({
    required String taskId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    final database = await _database();
    final task = await database.beaconTasks
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
    if (task == null) {
      return null;
    }

    task.title = title.trim();
    task.description = description.trim();
    task.linkedElementIds = _normalizeElementIds(linkedElementIds);
    task.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.beaconTasks.put(task);
    });
    return task;
  }

  @override
  Future<BeaconTask?> archiveTask(String taskId) async {
    final database = await _database();
    final task = await database.beaconTasks
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
    if (task == null) {
      return null;
    }
    task.statusValue = BeaconTaskStatus.archived;
    task.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.beaconTasks.put(task);
    });
    return task;
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    final database = await _database();
    final task = await database.beaconTasks
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
    if (task == null) {
      return false;
    }

    await database.writeTxn(() async {
      await database.beaconTasks.delete(task.isarId);
    });
    return true;
  }

  Future<void> close() async {
    final database = await _database();
    await database.close();
    _isarFuture = null;
  }

  List<String> _normalizeElementIds(List<String> linkedElementIds) {
    return linkedElementIds
        .map((elementId) => elementId.trim())
        .where((elementId) => elementId.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
