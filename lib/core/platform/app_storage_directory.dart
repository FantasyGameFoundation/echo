import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _storageDirectoryChannel = MethodChannel(
  'echo/platform/storage_directory',
);

Future<String> getAppStorageDirectoryPath() async {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    throw UnsupportedError(
      'App storage directory is only configured for Android and iOS.',
    );
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
