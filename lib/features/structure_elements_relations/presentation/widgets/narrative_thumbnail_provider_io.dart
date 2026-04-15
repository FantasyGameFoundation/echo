import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object> narrativeThumbnailProvider(String source) {
  final uri = Uri.tryParse(source);
  final scheme = uri?.scheme.toLowerCase() ?? '';

  if (scheme == 'http' || scheme == 'https') {
    return NetworkImage(source);
  }

  if (scheme == 'file') {
    return FileImage(File.fromUri(uri!));
  }

  return FileImage(File(source));
}
