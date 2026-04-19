import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'project_relation_type.g.dart';

@collection
class ProjectRelationType {
  ProjectRelationType();

  ProjectRelationType.create({
    String? id,
    required String projectId,
    required String relationName,
    required String relationDescription,
    required int relationSortOrder,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : relationTypeId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       name = relationName,
       description = relationDescription,
       sortOrder = relationSortOrder,
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String relationTypeId;

  @Index()
  late String owningProjectId;

  late String name;
  late String description;
  late int sortOrder;
  late DateTime createdAt;
  late DateTime updatedAt;
}
