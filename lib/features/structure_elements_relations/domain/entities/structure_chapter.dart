import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'structure_chapter.g.dart';

@collection
class StructureChapter {
  StructureChapter();

  StructureChapter.create({
    String? id,
    required String projectId,
    required String chapterTitle,
    String? chapterDescription,
    String chapterStatus = '进行',
    int chapterElementCount = 0,
    int chapterSortOrder = 0,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : chapterId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       title = chapterTitle,
       description = chapterDescription,
       statusLabel = chapterStatus,
       elementCount = chapterElementCount,
       sortOrder = chapterSortOrder,
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String chapterId;

  @Index()
  late String owningProjectId;

  late String title;
  String? description;
  late String statusLabel;
  late int elementCount;
  late int sortOrder;
  late DateTime createdAt;
  late DateTime updatedAt;
}
