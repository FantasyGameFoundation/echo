import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'project_relation_member.g.dart';

@collection
class ProjectRelationMember {
  ProjectRelationMember();

  ProjectRelationMember.create({
    String? id,
    required String projectId,
    required String groupId,
    required String targetKind,
    String? elementId,
    String? photoPath,
    String? sourceElementId,
    String? textCardId,
    required int sortOrder,
    DateTime? createdTimestamp,
  }) : relationMemberId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       owningGroupId = groupId,
       kind = targetKind,
       linkedElementId = elementId,
       linkedPhotoPath = photoPath,
       linkedSourceElementId = sourceElementId,
       linkedTextCardId = textCardId,
       memberSortOrder = sortOrder,
       createdAt = createdTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String relationMemberId;

  @Index()
  late String owningProjectId;

  @Index()
  late String owningGroupId;

  late String kind;
  String? linkedElementId;
  String? linkedPhotoPath;
  String? linkedSourceElementId;
  String? linkedTextCardId;
  late int memberSortOrder;
  late DateTime createdAt;
}
