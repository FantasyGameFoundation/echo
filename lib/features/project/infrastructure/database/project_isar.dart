import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:isar/isar.dart';

final Map<String, Future<Isar>> _openProjectIsars = <String, Future<Isar>>{};

Future<Isar> openProjectIsar({
  String name = 'echo_projects',
  String? directoryPath,
}) async {
  final resolvedDirectory = directoryPath ?? await getAppStorageDirectoryPath();
  final existingInstance = Isar.getInstance(name);
  if (existingInstance != null && existingInstance.isOpen) {
    return existingInstance;
  }

  final cacheKey = '$name::$resolvedDirectory';
  final cachedOpen = _openProjectIsars[cacheKey];
  if (cachedOpen != null) {
    final cachedDatabase = await cachedOpen;
    if (cachedDatabase.isOpen) {
      return cachedDatabase;
    }
    _openProjectIsars.remove(cacheKey);
  }

  final openFuture = Isar.open(
    <CollectionSchema<dynamic>>[
      ProjectSchema,
      ProjectSessionSchema,
      CaptureRecordSchema,
      NarrativeElementSchema,
      TextCardSchema,
      ProjectRelationTypeSchema,
      ProjectRelationGroupSchema,
      ProjectRelationMemberSchema,
      StructureChapterSchema,
    ],
    directory: resolvedDirectory,
    name: name,
    inspector: false,
  );
  _openProjectIsars[cacheKey] = openFuture;

  try {
    final database = await openFuture;
    if (!database.isOpen) {
      _openProjectIsars.remove(cacheKey);
    }
    return database;
  } catch (_) {
    _openProjectIsars.remove(cacheKey);
    rethrow;
  }
}
