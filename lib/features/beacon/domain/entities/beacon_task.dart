import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'beacon_task.g.dart';

enum BeaconTaskStatus { pending, archived }

extension BeaconTaskStatusX on BeaconTaskStatus {
  String get storageValue => switch (this) {
    BeaconTaskStatus.pending => 'pending',
    BeaconTaskStatus.archived => 'archived',
  };

  static BeaconTaskStatus fromStorageValue(String value) {
    return switch (value) {
      'archived' => BeaconTaskStatus.archived,
      _ => BeaconTaskStatus.pending,
    };
  }
}

@collection
class BeaconTask {
  BeaconTask();

  BeaconTask.create({
    String? id,
    required String projectId,
    required String taskTitle,
    required String taskDescription,
    List<String>? linkedElementIds,
    String taskStatus = 'pending',
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : taskId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       title = taskTitle,
       description = taskDescription,
       status = taskStatus,
       linkedElementIds = linkedElementIds ?? <String>[],
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String taskId;

  @Index()
  late String owningProjectId;

  @Index()
  late String status;

  late String title;
  String? description;
  List<String> linkedElementIds = <String>[];
  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  BeaconTaskStatus get statusValue =>
      BeaconTaskStatusX.fromStorageValue(status);

  set statusValue(BeaconTaskStatus value) {
    status = value.storageValue;
  }

  @ignore
  bool get isArchived => statusValue == BeaconTaskStatus.archived;
}
