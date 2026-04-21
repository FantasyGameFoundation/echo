import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'project_relation_group.g.dart';

@collection
class ProjectRelationGroup {
  ProjectRelationGroup();

  ProjectRelationGroup.create({
    String? id,
    required String projectId,
    required String relationTypeId,
    String? relationGroupTitle,
    String? relationGroupDescription,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : relationGroupId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       linkedRelationTypeId = relationTypeId,
       title = relationGroupTitle,
       description = relationGroupDescription,
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String relationGroupId;

  @Index()
  late String owningProjectId;

  @Index()
  late String linkedRelationTypeId;

  String? title;
  String? description;
  late DateTime createdAt;
  late DateTime updatedAt;
}
