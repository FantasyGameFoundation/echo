import 'dart:async';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:echo/shared/models/photo_processing_registry.dart';
import 'package:echo/shared/models/processing_photo_ref.dart';
import 'package:echo/shared/widgets/developing_photo_tile.dart';
import 'package:flutter/material.dart';

class QuickRecordOverlayPrototype extends StatefulWidget {
  const QuickRecordOverlayPrototype({
    super.key,
    required this.onClose,
    required this.onSaveRecord,
    this.onPickGalleryPhotos,
    this.onPickCapturedPhoto,
    this.onImportPhoto,
    this.photoProcessingRegistry,
    this.photoProcessingContextId = 'quick-record',
  });

  final VoidCallback onClose;
  final Future<void> Function({
    required CaptureMode mode,
    required String rawText,
    required List<String> photoPaths,
  })
  onSaveRecord;
  final PickGalleryImages? onPickGalleryPhotos;
  final PickCapturedPhoto? onPickCapturedPhoto;
  final ImportNarrativePhoto? onImportPhoto;
  final PhotoProcessingRegistry? photoProcessingRegistry;
  final String photoProcessingContextId;

  @override
  State<QuickRecordOverlayPrototype> createState() =>
      _QuickRecordOverlayPrototypeState();
}

class _QuickRecordOverlayPrototypeState
    extends State<QuickRecordOverlayPrototype> {
  late final TextEditingController _textController;
  CaptureMode _mode = CaptureMode.record;
  List<ProcessingPhotoRef> _photoRefs = const <ProcessingPhotoRef>[];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()..addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.photoProcessingRegistry?.removeContext(
      widget.photoProcessingContextId,
    );
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    super.dispose();
  }

  bool get _hasText => _textController.text.trim().isNotEmpty;

  bool get _hasProcessingPhotos => _photoRefs.any((ref) => ref.isProcessing);

  List<String> get _readyPhotoPaths => [
    for (final ref in _photoRefs)
      if (ref.isReady && ref.importedPath != null) ref.importedPath!,
  ];

  bool get _canSave => switch (_mode) {
    CaptureMode.portfolio =>
      !_isSaving && !_hasProcessingPhotos && _readyPhotoPaths.isNotEmpty,
    CaptureMode.record =>
      !_isSaving &&
          !_hasProcessingPhotos &&
          (_hasText || _readyPhotoPaths.isNotEmpty),
  };

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _displayTimestamp {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '${now.year}.$month.$day $hour:$minute:$second';
  }

  Future<void> _pickFromGallery() async {
    final picker = widget.onPickGalleryPhotos;
    if (picker == null || _isSaving) {
      return;
    }
    final sourcePaths = await picker();
    await _mountImportedPhotos(sourcePaths);
  }

  Future<void> _pickFromCamera() async {
    final picker = widget.onPickCapturedPhoto;
    if (picker == null || _isSaving) {
      return;
    }
    final sourcePath = await picker();
    if (sourcePath == null) {
      return;
    }
    await _mountImportedPhotos(<String>[sourcePath]);
  }

  Future<void> _mountImportedPhotos(List<String> sourcePaths) async {
    if (!mounted || sourcePaths.isEmpty) {
      return;
    }

    final importer = widget.onImportPhoto;
    if (importer == null) {
      final readyRefs = [
        for (var index = 0; index < sourcePaths.length; index++)
          ProcessingPhotoRef.ready(
            id: _newPhotoRefId(index),
            sourcePath: sourcePaths[index],
            importedPath: sourcePaths[index],
            contextId: widget.photoProcessingContextId,
          ),
      ];
      setState(() {
        _photoRefs = [..._photoRefs, ...readyRefs];
      });
      return;
    }

    final processingRefs = [
      for (var index = 0; index < sourcePaths.length; index++)
        ProcessingPhotoRef.processing(
          id: _newPhotoRefId(index),
          sourcePath: sourcePaths[index],
          contextId: widget.photoProcessingContextId,
        ),
    ];
    setState(() {
      _photoRefs = [..._photoRefs, ...processingRefs];
    });
    for (final ref in processingRefs) {
      widget.photoProcessingRegistry?.upsert(ref);
      unawaited(_resolvePhotoRef(ref, importer));
    }
  }

  String _newPhotoRefId(int index) {
    return '${widget.photoProcessingContextId}-${DateTime.now().microsecondsSinceEpoch}-$index';
  }

  Future<void> _resolvePhotoRef(
    ProcessingPhotoRef ref,
    ImportNarrativePhoto importer,
  ) async {
    try {
      final importedPath = await importer(ref.sourcePath);
      if (!mounted) {
        widget.photoProcessingRegistry?.remove(ref.id);
        return;
      }
      _replacePhotoRef(
        ref.copyWith(
          status: ProcessingPhotoStatus.ready,
          importedPath: importedPath,
        ),
      );
    } on MediaImportCancelledException {
      if (!mounted) {
        widget.photoProcessingRegistry?.remove(ref.id);
        return;
      }
      _removePhotoRefById(ref.id);
    } catch (_) {
      if (!mounted) {
        widget.photoProcessingRegistry?.remove(ref.id);
        return;
      }
      _replacePhotoRef(
        ref.copyWith(
          status: ProcessingPhotoStatus.failed,
          errorMessage: '导入照片失败',
        ),
      );
      _showPassiveHint('导入照片失败');
    }
  }

  void _replacePhotoRef(ProcessingPhotoRef nextRef) {
    setState(() {
      _photoRefs = [
        for (final ref in _photoRefs)
          if (ref.id == nextRef.id) nextRef else ref,
      ];
    });
    if (nextRef.isProcessing) {
      widget.photoProcessingRegistry?.upsert(nextRef);
    } else {
      widget.photoProcessingRegistry?.remove(nextRef.id);
    }
  }

  Future<void> _save() async {
    if (!_canSave) {
      if (_mode == CaptureMode.portfolio &&
          !_hasProcessingPhotos &&
          _readyPhotoPaths.isEmpty) {
        _showPassiveHint('请先添加照片');
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSaveRecord(
        mode: _mode,
        rawText: _textController.text,
        photoPaths: _readyPhotoPaths,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _removePhotoAt(int index) {
    if (index < 0 || index >= _photoRefs.length) {
      return;
    }
    _removePhotoRefById(_photoRefs[index].id);
  }

  void _removePhotoRefById(String refId) {
    setState(() {
      _photoRefs = [
        for (final ref in _photoRefs)
          if (ref.id != refId) ref,
      ];
    });
    widget.photoProcessingRegistry?.remove(refId);
  }

  void _showPassiveHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 20.0,
              bottom: 20.0,
              right: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModeSelector(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayTimestamp,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                key: const ValueKey('quickRecordTextField'),
                controller: _textController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '在此输入记录内容...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          if (_photoRefs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    key: const ValueKey('quickRecordPhotoStrip'),
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoRefs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _buildMountedPhotoTile(
                        ref: _photoRefs[index],
                        index: index,
                      );
                    },
                  ),
                ),
              ),
            ),
          Container(
            height: 80,
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    key: const ValueKey('quickRecordCameraButton'),
                    onTap: _pickFromCamera,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 24,
                          color: Color(0xFF555555),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '拍摄',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                Expanded(
                  child: InkWell(
                    key: const ValueKey('quickRecordGalleryButton'),
                    onTap: _pickFromGallery,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 24,
                          color: Color(0xFF555555),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '相册',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            key: const ValueKey('quickRecordSaveButton'),
            onTap: _save,
            child: Container(
              height: 62,
              color: _canSave
                  ? const Color(0xFF5A5A5A)
                  : const Color(0xFF9C9C9C),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSaving
                        ? '保 存 中'
                        : _hasProcessingPhotos
                        ? '显 影 中'
                        : '保 存 记 录',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return PopupMenuButton<CaptureMode>(
      key: const ValueKey('quickRecordModeSelector'),
      initialValue: _mode,
      color: const Color(0xFFF5F5F5),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 104),
      onSelected: (mode) {
        if (_mode == mode) {
          return;
        }
        setState(() {
          _mode = mode;
        });
      },
      itemBuilder: (context) {
        return [
          for (final mode in CaptureMode.values)
            PopupMenuItem<CaptureMode>(
              value: mode,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: _modeMenuTextStyle,
                ),
              ),
            ),
        ];
      },
      child: Row(
        children: [
          Text(
            _mode.label,
            key: const ValueKey('quickRecordModeLabel'),
            style: _modeTriggerTextStyle,
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  TextStyle get _modeTriggerTextStyle => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w300,
    letterSpacing: 2.2,
    height: 1.0,
    color: Color(0xFF2F2F2F),
  );

  TextStyle get _modeMenuTextStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.6,
    height: 1.0,
    color: Color(0xFF2F2F2F),
  );

  Widget _buildMountedPhotoTile({
    required ProcessingPhotoRef ref,
    required int index,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!ref.isReady || ref.importedPath == null)
          DevelopingPhotoTile(
            key: ValueKey('quickRecordPhotoTile-$index'),
            width: 72,
            height: 72,
            failed: ref.isFailed,
          )
        else
          TweenAnimationBuilder<double>(
            key: ValueKey('quickRecordPhotoTile-$index'),
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12, width: 0.8),
              ),
              child: Image(
                image: ResizeImage.resizeIfNeeded(
                  200,
                  null,
                  narrativeThumbnailProvider(ref.importedPath!),
                ),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF1F1F3),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.black26,
                      size: 18,
                    ),
                  );
                },
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            key: ValueKey('quickRecordPhotoRemoveButton-$index'),
            onTap: () => _removePhotoAt(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
