import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:isar/isar.dart';

Future<Isar> openProjectIsar({
  String name = 'echo_projects',
  String? directoryPath,
}) async {
  final resolvedDirectory = directoryPath ?? await getAppStorageDirectoryPath();

  return Isar.open(
    <CollectionSchema<dynamic>>[ProjectSchema, ProjectSessionSchema],
    directory: resolvedDirectory,
    name: name,
    inspector: false,
  );
}
