import 'dart:io';

import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

Future<String> importMediaFile({
  required String sourcePath,
  required String collection,
}) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    throw StateError('Media file does not exist: $sourcePath');
  }

  final storageRoot = await getAppStorageDirectoryPath();
  final mediaDirectory = Directory(p.join(storageRoot, 'media', collection));
  await mediaDirectory.create(recursive: true);

  final extension = p.extension(sourcePath);
  final importedPath = p.join(
    mediaDirectory.path,
    '${const Uuid().v4()}$extension',
  );

  final importedFile = await sourceFile.copy(importedPath);
  return importedFile.path;
}

Future<List<String>> importMediaFiles({
  required List<String> sourcePaths,
  required String collection,
}) async {
  final imported = <String>[];
  for (final sourcePath in sourcePaths) {
    imported.add(
      await importMediaFile(sourcePath: sourcePath, collection: collection),
    );
  }
  return imported;
}
