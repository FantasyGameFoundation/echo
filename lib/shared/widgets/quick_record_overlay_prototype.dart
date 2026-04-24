import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class QuickRecordOverlayPrototype extends StatefulWidget {
  const QuickRecordOverlayPrototype({
    super.key,
    required this.onClose,
    required this.onSaveRecord,
    this.onPickGalleryPhotos,
    this.onPickCapturedPhoto,
    this.onImportPhoto,
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

  @override
  State<QuickRecordOverlayPrototype> createState() =>
      _QuickRecordOverlayPrototypeState();
}

class _QuickRecordOverlayPrototypeState
    extends State<QuickRecordOverlayPrototype> {
  late final TextEditingController _textController;
  CaptureMode _mode = CaptureMode.record;
  List<String> _mountedPhotos = const <String>[];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()..addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    super.dispose();
  }

  bool get _hasText => _textController.text.trim().isNotEmpty;

  bool get _canSave => switch (_mode) {
    CaptureMode.portfolio => !_isSaving && _mountedPhotos.isNotEmpty,
    CaptureMode.record => !_isSaving && (_hasText || _mountedPhotos.isNotEmpty),
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
      setState(() {
        _mountedPhotos = [..._mountedPhotos, ...sourcePaths];
      });
      return;
    }

    final importedPhotos = <String>[];
    try {
      for (final sourcePath in sourcePaths) {
        importedPhotos.add(await importer(sourcePath));
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showPassiveHint('导入照片失败');
      return;
    }

    if (!mounted || importedPhotos.isEmpty) {
      return;
    }
    setState(() {
      _mountedPhotos = [..._mountedPhotos, ...importedPhotos];
    });
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSaveRecord(
        mode: _mode,
        rawText: _textController.text,
        photoPaths: _mountedPhotos,
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
    if (index < 0 || index >= _mountedPhotos.length) {
      return;
    }
    setState(() {
      _mountedPhotos = List<String>.from(_mountedPhotos)..removeAt(index);
    });
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
          if (_mountedPhotos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    key: const ValueKey('quickRecordPhotoStrip'),
                    scrollDirection: Axis.horizontal,
                    itemCount: _mountedPhotos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _buildMountedPhotoTile(
                        photoPath: _mountedPhotos[index],
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
            onTap: _canSave ? _save : null,
            child: Container(
              height: 64,
              color: _canSave
                  ? const Color(0xFF5A5A5A)
                  : const Color(0xFF9C9C9C),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSaving ? '保 存 中' : '保 存 记 录',
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
    required String photoPath,
    required int index,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          key: ValueKey('quickRecordPhotoTile-$index'),
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
              narrativeThumbnailProvider(photoPath),
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
