import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'narrative_element.g.dart';

@collection
class NarrativeElement {
  NarrativeElement();

  NarrativeElement.create({
    String? id,
    required String projectId,
    String? chapterId,
    required String elementTitle,
    String? elementDescription,
    String elementStatus = 'finding',
    List<String>? linkedPhotoPaths,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : elementId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       owningChapterId = chapterId,
       title = elementTitle,
       description = elementDescription,
       status = elementStatus,
       photoPaths = linkedPhotoPaths ?? <String>[],
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String elementId;

  @Index()
  late String owningProjectId;

  @Index()
  String? owningChapterId;

  late String title;
  String? description;
  late String status;
  List<String> photoPaths = <String>[];
  late DateTime createdAt;
  late DateTime updatedAt;
}
