import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel _projectBundleFileTransferChannel = MethodChannel(
  'echo/platform/project_bundle_transfer',
);

enum ProjectBundleFileTransferErrorCode {
  permissionDenied,
  unavailable,
  invalidSelection,
  ioFailure,
  busy,
  unknown,
}

class ProjectBundleFileTransferException implements Exception {
  const ProjectBundleFileTransferException(
    this.code, {
    this.message,
    this.details,
  });

  final ProjectBundleFileTransferErrorCode code;
  final String? message;
  final Object? details;

  bool get isPermissionDenied =>
      code == ProjectBundleFileTransferErrorCode.permissionDenied;

  @override
  String toString() {
    return 'ProjectBundleFileTransferException('
        'code: $code, message: $message, details: $details)';
  }
}

class ProjectBundleExportReceipt {
  const ProjectBundleExportReceipt({
    required this.displayPath,
    required this.copyablePath,
  });

  factory ProjectBundleExportReceipt.fromMap(Map<Object?, Object?> map) {
    final displayPath = (map['displayPath'] as String?)?.trim() ?? '';
    final copyablePath =
        (map['copyablePath'] as String?)?.trim().isNotEmpty == true
        ? (map['copyablePath'] as String).trim()
        : displayPath;
    if (displayPath.isEmpty) {
      throw const ProjectBundleFileTransferException(
        ProjectBundleFileTransferErrorCode.invalidSelection,
        message: 'Export result is missing a display path.',
      );
    }
    return ProjectBundleExportReceipt(
      displayPath: displayPath,
      copyablePath: copyablePath,
    );
  }

  final String displayPath;
  final String copyablePath;
}

class ProjectBundleImportSelection {
  ProjectBundleImportSelection({
    required this.bundleDirectoryPath,
    required this.displayPath,
    this.cleanupDirectoryPath,
    Future<void> Function()? onDispose,
  }) : _onDispose = onDispose;

  final String bundleDirectoryPath;
  final String displayPath;
  final String? cleanupDirectoryPath;
  final Future<void> Function()? _onDispose;

  Future<void> dispose() async {
    await _onDispose?.call();
  }
}

abstract class ProjectBundleFileTransfer {
  Future<ProjectBundleExportReceipt?> exportBundleDirectory({
    required String bundleDirectoryPath,
    required String suggestedBundleName,
  });

  Future<ProjectBundleImportSelection?> pickImportBundleDirectory();
}

class PlatformProjectBundleFileTransfer implements ProjectBundleFileTransfer {
  const PlatformProjectBundleFileTransfer();

  @override
  Future<ProjectBundleExportReceipt?> exportBundleDirectory({
    required String bundleDirectoryPath,
    required String suggestedBundleName,
  }) async {
    if (!_isSupported) {
      return null;
    }

    try {
      final result = await _projectBundleFileTransferChannel
          .invokeMethod<Map<Object?, Object?>>(
            'exportBundleDirectory',
            <String, Object?>{
              'bundleDirectoryPath': bundleDirectoryPath,
              'suggestedBundleName': suggestedBundleName,
            },
          );
      if (result == null) {
        return null;
      }
      return ProjectBundleExportReceipt.fromMap(result);
    } on PlatformException catch (error) {
      throw _toTransferException(error);
    }
  }

  @override
  Future<ProjectBundleImportSelection?> pickImportBundleDirectory() async {
    if (!_isSupported) {
      return null;
    }

    try {
      final result = await _projectBundleFileTransferChannel
          .invokeMethod<Map<Object?, Object?>>('pickImportBundleDirectory');
      if (result == null) {
        return null;
      }

      final bundleDirectoryPath =
          (result['bundleDirectoryPath'] as String?)?.trim() ?? '';
      final displayPath = (result['displayPath'] as String?)?.trim() ?? '';
      final cleanupDirectoryPath = (result['cleanupDirectoryPath'] as String?)
          ?.trim();
      if (bundleDirectoryPath.isEmpty || displayPath.isEmpty) {
        throw const ProjectBundleFileTransferException(
          ProjectBundleFileTransferErrorCode.invalidSelection,
          message: 'Import result is missing a bundle path or display path.',
        );
      }

      return ProjectBundleImportSelection(
        bundleDirectoryPath: bundleDirectoryPath,
        displayPath: displayPath,
        cleanupDirectoryPath: cleanupDirectoryPath,
        onDispose: () => _deleteTemporaryBundleDirectory(
          cleanupDirectoryPath?.isNotEmpty == true
              ? cleanupDirectoryPath!
              : bundleDirectoryPath,
        ),
      );
    } on PlatformException catch (error) {
      throw _toTransferException(error);
    }
  }

  bool get _isSupported {
    if (kIsWeb) {
      return false;
    }
    return Platform.isIOS || Platform.isAndroid;
  }

  ProjectBundleFileTransferException _toTransferException(
    PlatformException error,
  ) {
    final normalizedCode = switch (error.code) {
      'permissionDenied' => ProjectBundleFileTransferErrorCode.permissionDenied,
      'unavailable' => ProjectBundleFileTransferErrorCode.unavailable,
      'invalidSelection' => ProjectBundleFileTransferErrorCode.invalidSelection,
      'ioFailure' => ProjectBundleFileTransferErrorCode.ioFailure,
      'busy' => ProjectBundleFileTransferErrorCode.busy,
      _ => ProjectBundleFileTransferErrorCode.unknown,
    };
    return ProjectBundleFileTransferException(
      normalizedCode,
      message: error.message,
      details: error.details,
    );
  }

  Future<void> _deleteTemporaryBundleDirectory(
    String bundleDirectoryPath,
  ) async {
    final bundleDirectory = Directory(bundleDirectoryPath);
    if (await bundleDirectory.exists()) {
      await bundleDirectory.delete(recursive: true);
    }
  }
}
