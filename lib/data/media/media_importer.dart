import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/features/settings/domain/services/media_ingest_policy.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImportedMediaFile {
  const ImportedMediaFile({required this.path, required this.plan});

  final String path;
  final MediaIngestPlan plan;
}

class MediaImageBounds {
  const MediaImageBounds({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  int get shortEdge => math.min(width, height);
  int get longEdge => math.max(width, height);
}

class MediaImportCancelledException implements Exception {
  const MediaImportCancelledException();
}

Future<String> importMediaFile({
  required String sourcePath,
  required String collection,
  MediaIngestPolicy? policy,
}) async {
  final imported = await importMediaFileWithPolicy(
    sourcePath: sourcePath,
    collection: collection,
    policy: policy,
  );
  return imported.path;
}

Future<ImportedMediaFile> importMediaFileWithPolicy({
  required String sourcePath,
  required String collection,
  MediaIngestPolicy? policy,
}) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    throw StateError('Media file does not exist: $sourcePath');
  }

  final resolvedPlan = await (policy ?? const PassthroughMediaIngestPolicy())
      .resolve(sourcePath: sourcePath, collection: collection);

  final storageRoot = await getAppStorageDirectoryPath();
  final mediaDirectory = Directory(p.join(storageRoot, 'media', collection));
  await mediaDirectory.create(recursive: true);

  final transformedBytes = await _resizeImageIfNeeded(sourceFile, resolvedPlan);
  if (transformedBytes != null) {
    final importedPath = p.join(
      mediaDirectory.path,
      '${const Uuid().v4()}.png',
    );
    final importedFile = await File(importedPath).writeAsBytes(
      transformedBytes,
      flush: true,
    );
    return ImportedMediaFile(path: importedFile.path, plan: resolvedPlan);
  }

  final importedPath = p.join(
    mediaDirectory.path,
    '${const Uuid().v4()}${p.extension(sourcePath)}',
  );
  final copiedFile = await sourceFile.copy(importedPath);
  return ImportedMediaFile(path: copiedFile.path, plan: resolvedPlan);
}

Future<List<String>> importMediaFiles({
  required List<String> sourcePaths,
  required String collection,
  MediaIngestPolicy? policy,
}) async {
  final imported = await importMediaFilesWithPolicy(
    sourcePaths: sourcePaths,
    collection: collection,
    policy: policy,
  );
  return imported.map((item) => item.path).toList(growable: false);
}

Future<List<ImportedMediaFile>> importMediaFilesWithPolicy({
  required List<String> sourcePaths,
  required String collection,
  MediaIngestPolicy? policy,
}) async {
  final imported = <ImportedMediaFile>[];
  for (final sourcePath in sourcePaths) {
    imported.add(
      await importMediaFileWithPolicy(
        sourcePath: sourcePath,
        collection: collection,
        policy: policy,
      ),
    );
  }
  return imported;
}

Future<MediaImageBounds?> inspectMediaImageBounds(String sourcePath) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  try {
    buffer = await ui.ImmutableBuffer.fromFilePath(sourcePath);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    return MediaImageBounds(
      width: descriptor.width,
      height: descriptor.height,
    );
  } catch (_) {
    return null;
  } finally {
    descriptor?.dispose();
    buffer?.dispose();
  }
}

bool isMediaImageOversizedForPlan(
  MediaImageBounds bounds,
  MediaIngestPlan plan,
) {
  final maxShortEdge = plan.preferredMaxShortEdgePx;
  final maxLongEdge = plan.preferredMaxLongEdgePx;
  if (!plan.appliesCompression ||
      maxShortEdge == null ||
      maxLongEdge == null) {
    return false;
  }
  return bounds.shortEdge > maxShortEdge || bounds.longEdge > maxLongEdge;
}

Future<Uint8List?> _resizeImageIfNeeded(
  File sourceFile,
  MediaIngestPlan plan,
) async {
  final maxShortEdge = plan.preferredMaxShortEdgePx;
  final maxLongEdge = plan.preferredMaxLongEdgePx;
  if (!plan.appliesCompression ||
      maxShortEdge == null ||
      maxLongEdge == null) {
    return null;
  }

  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;

  try {
    buffer = await ui.ImmutableBuffer.fromFilePath(sourceFile.path);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    final width = descriptor.width;
    final height = descriptor.height;
    final shortEdge = math.min(width, height);
    final longEdge = math.max(width, height);

    final scale = math.min(
      1,
      math.min(maxShortEdge / shortEdge, maxLongEdge / longEdge),
    );
    if (scale >= 1) {
      return null;
    }

    codec = await descriptor.instantiateCodec(
      targetWidth: math.max(1, (width * scale).round()),
      targetHeight: math.max(1, (height * scale).round()),
    );
    final frame = await codec.getNextFrame();
    image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (_) {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}
