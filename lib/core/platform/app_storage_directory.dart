import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _storageDirectoryChannel = MethodChannel(
  'echo/platform/storage_directory',
);

Future<String> getAppStorageDirectoryPath() async {
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    final directory = Directory.systemTemp;
    await directory.create(recursive: true);
    return directory.path;
  }

  final path = await _storageDirectoryChannel.invokeMethod<String>(
    'getAppStorageDirectory',
  );
  if (path == null || path.isEmpty) {
    throw StateError(
      'Platform storage directory channel returned an empty path.',
    );
  }
  final directory = Directory(path);
  await directory.create(recursive: true);
  return path;
}
