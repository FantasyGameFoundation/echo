import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@collection
class Project {
  Project();

  Project.create({
    String? id,
    required String projectTitle,
    required String projectThemeStatement,
    String? projectDescription,
    String? projectCoverImagePath,
    String projectStage = 'draft',
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : projectId = id ?? const Uuid().v4(),
       title = projectTitle,
       themeStatement = projectThemeStatement,
       description = projectDescription,
       coverImagePath = projectCoverImagePath,
       stage = projectStage,
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String projectId;

  late String title;
  late String themeStatement;
  String? description;
  String? coverImagePath;
  late String stage;
  late DateTime createdAt;
  late DateTime updatedAt;
}
