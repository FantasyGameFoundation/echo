import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _storageDirectoryChannel = MethodChannel(
  'echo/platform/storage_directory',
);

Future<String> getAppStorageDirectoryPath() async {
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    return Directory.systemTemp.path;
  }

  final path = await _storageDirectoryChannel.invokeMethod<String>(
    'getAppStorageDirectory',
  );
  if (path == null || path.isEmpty) {
    throw StateError(
      'Platform storage directory channel returned an empty path.',
    );
  }
  return path;
}
