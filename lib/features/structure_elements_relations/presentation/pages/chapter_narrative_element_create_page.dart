import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/settings/infrastructure/services/local_media_ingest_policy.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/shared/models/processing_photo_ref.dart';
import 'package:echo/shared/widgets/developing_photo_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ImportDraftNarrativePhoto = Future<String> Function(String sourcePath);

Future<String> importDraftNarrativePhotoToApp(String sourcePath) {
  return importMediaFile(
    sourcePath: sourcePath,
    collection: 'narrative_elements',
    policy: LocalMediaIngestPolicy(),
  );
}

class ChapterNarrativeElementCreatePage extends StatefulWidget {
  const ChapterNarrativeElementCreatePage({
    super.key,
    this.initialDraft,
    PickGalleryImages? onPickPhoto,
    ImportDraftNarrativePhoto? onImportPhoto,
  }) : onPickPhoto = onPickPhoto ?? pickGalleryImagesFromGallery,
       onImportPhoto = onImportPhoto ?? importDraftNarrativePhotoToApp;

  final NarrativeElementDraft? initialDraft;
  final PickGalleryImages onPickPhoto;
  final ImportDraftNarrativePhoto onImportPhoto;

  bool get isEditMode => initialDraft != null;

  @override
  State<ChapterNarrativeElementCreatePage> createState() =>
      _ChapterNarrativeElementCreatePageState();
}

class _ChapterNarrativeElementCreatePageState
    extends State<ChapterNarrativeElementCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final String _initialTitle;
  late final String _initialDescription;
  late final List<String> _initialPhotoPaths;
  final List<ProcessingPhotoRef> _photoRefs = <ProcessingPhotoRef>[];
  bool _didUnlockCompletedElement = false;

  String get _currentTitle => _nameController.text.trim();

  String get _currentDescription => _descController.text.trim();

  bool get _isCompletedElement => widget.initialDraft?.status == 'ready';

  bool get _isLockedCompletedElement =>
      widget.isEditMode && _isCompletedElement && !_didUnlockCompletedElement;

  String get _currentStatus {
    if (!widget.isEditMode) {
      return 'finding';
    }
    if (_isCompletedElement && _didUnlockCompletedElement) {
      return 'finding';
    }
    return widget.initialDraft?.status ?? 'finding';
  }

  bool get _hasChanges {
    return _currentTitle != _initialTitle ||
        _currentDescription != _initialDescription ||
        _hasProcessingPhotos ||
        !listEquals(_readyPhotoPaths, _initialPhotoPaths) ||
        _didUnlockCompletedElement;
  }

  bool get _hasProcessingPhotos => _photoRefs.any((ref) => ref.isProcessing);

  List<String> get _readyPhotoPaths => [
    for (final ref in _photoRefs)
      if (ref.isReady && ref.importedPath != null) ref.importedPath!,
  ];

  bool get _canSave => _currentTitle.isNotEmpty && !_hasProcessingPhotos;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.initialDraft?.title.trim() ?? '';
    _initialDescription = widget.initialDraft?.description.trim() ?? '';
    _initialPhotoPaths = List<String>.from(
      widget.initialDraft?.photoPaths ?? const <String>[],
    );
    _photoRefs.addAll([
      for (var index = 0; index < _initialPhotoPaths.length; index++)
        ProcessingPhotoRef.ready(
          id: 'chapter-draft-initial-$index',
          sourcePath: _initialPhotoPaths[index],
          importedPath: _initialPhotoPaths[index],
          contextId: 'chapter-draft-element',
        ),
    ]);
    _nameController = TextEditingController(text: _initialTitle);
    _descController = TextEditingController(text: _initialDescription);
    _nameController.addListener(_onChanged);
    _descController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _descController.removeListener(_onChanged);
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _mountPhoto() async {
    final photoPaths = await widget.onPickPhoto();
    if (!mounted || photoPaths.isEmpty) {
      return;
    }

    final refs = [
      for (var index = 0; index < photoPaths.length; index++)
        ProcessingPhotoRef.processing(
          id: 'chapter-draft-${DateTime.now().microsecondsSinceEpoch}-$index',
          sourcePath: photoPaths[index],
          contextId: 'chapter-draft-element',
        ),
    ];
    setState(() {
      _photoRefs.addAll(refs);
    });
    for (final ref in refs) {
      unawaited(_resolvePhotoRef(ref));
    }
  }

  Future<void> _resolvePhotoRef(ProcessingPhotoRef ref) async {
    try {
      final storedPath = await widget.onImportPhoto(ref.sourcePath);
      if (!mounted) {
        return;
      }
      _replacePhotoRef(
        ref.copyWith(
          status: ProcessingPhotoStatus.ready,
          importedPath: storedPath,
        ),
      );
    } on MediaImportCancelledException {
      if (mounted) {
        _removePhotoRefById(ref.id);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _replacePhotoRef(
        ref.copyWith(
          status: ProcessingPhotoStatus.failed,
          errorMessage: '照片导入失败，请重试',
        ),
      );
      _showPassiveHint('照片导入失败，请重试');
    }
  }

  void _replacePhotoRef(ProcessingPhotoRef nextRef) {
    setState(() {
      for (var index = 0; index < _photoRefs.length; index++) {
        if (_photoRefs[index].id == nextRef.id) {
          _photoRefs[index] = nextRef;
          break;
        }
      }
    });
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _photoRefs.length) {
      return;
    }
    _removePhotoRefById(_photoRefs[index].id);
  }

  void _removePhotoRefById(String refId) {
    setState(() {
      _photoRefs.removeWhere((ref) => ref.id == refId);
    });
  }

  void _save() {
    if (_isLockedCompletedElement) {
      _showPassiveHint('叙事元素已完成无法编辑，请点击右上角继续编辑');
      return;
    }
    if (!_canSave) {
      return;
    }

    Navigator.of(context).pop(
      NarrativeElementDraft(
        title: _currentTitle,
        description: _currentDescription,
        photoPaths: _readyPhotoPaths,
        status: _currentStatus,
      ),
    );
  }

  void _completeElement() {
    if (_isLockedCompletedElement) {
      setState(() {
        _didUnlockCompletedElement = true;
      });
      _showPassiveHint('叙事元素现可继续编辑');
      return;
    }
    if (!_canSave) {
      return;
    }
    if (_readyPhotoPaths.isEmpty) {
      _showPassiveHint('元素缺少照片，无法完成。');
      return;
    }

    Navigator.of(context).pop(
      NarrativeElementDraft(
        title: _currentTitle,
        description: _currentDescription,
        photoPaths: _readyPhotoPaths,
        status: 'ready',
      ),
    );
  }

  void _showPassiveHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(left: 88, right: 88, bottom: 96),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget _buildSaveButton() {
    if (_isLockedCompletedElement) {
      return GestureDetector(
        key: const ValueKey('chapterDraftLockedSaveButton'),
        onTap: _save,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: const BoxDecoration(color: Color(0xFFE2E2E5)),
          child: const Text(
            '保 存',
            style: TextStyle(
              color: Color(0xFF9E9EA4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.0,
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: !_hasChanges || !_canSave,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        opacity: _hasChanges ? 1.0 : 0.0,
        child: GestureDetector(
          key: const ValueKey('chapterDraftElementSaveButton'),
          onTap: _save,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: const BoxDecoration(color: Colors.black),
            child: const Text(
              '保 存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 4.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    children: [
                      _buildNameInput(),
                      const SizedBox(height: 16),
                      _buildDescInput(),
                      const SizedBox(height: 56),
                      _buildSectionLabel('关 联 照 片'),
                      const SizedBox(height: 16),
                      _buildPhotoMounter(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(child: _buildSaveButton()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final rightActionLabel = _isLockedCompletedElement ? '继续编辑' : '元素完成';
    final editorTitle = widget.isEditMode ? '编 辑 叙 事 元 素' : '添 加 叙 事 元 素';
    final rightAction = widget.isEditMode
        ? TextButton(
            key: const ValueKey('chapterDraftCompleteButton'),
            onPressed: _completeElement,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(80, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              rightActionLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
                color: Colors.black87,
              ),
            ),
          )
        : const SizedBox(width: 48);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            editorTitle,
            key: const ValueKey('chapterDraftElementEditorTitle'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.0,
              color: Colors.black87,
            ),
          ),
          rightAction,
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      key: const ValueKey('chapterDraftElementNameField'),
      controller: _nameController,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 1.0,
      ),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: '叙事元素名称',
        hintStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDescInput() {
    return TextField(
      key: const ValueKey('chapterDraftElementDescriptionField'),
      controller: _descController,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.6,
        fontStyle: FontStyle.italic,
      ),
      minLines: 1,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '描述叙事元素',
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade400,
          fontStyle: FontStyle.italic,
          height: 1.6,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPhotoMounter() {
    final mountItems = <Widget>[
      for (int i = 0; i < _photoRefs.length; i++)
        Stack(
          children: [
            if (!_photoRefs[i].isReady || _photoRefs[i].importedPath == null)
              DevelopingPhotoTile(failed: _photoRefs[i].isFailed)
            else
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.045),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    File(_photoRefs[i].importedPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image,
                        color: Colors.black26,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => _removePhoto(i),
                child: Container(
                  width: 24,
                  height: 24,
                  color: Colors.black.withValues(alpha: 0.6),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      InkWell(
        onTap: _mountPhoto,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: const Icon(Icons.add, color: Colors.black54, size: 24),
        ),
      ),
    ];

    return Wrap(spacing: 8.0, runSpacing: 8.0, children: mountItems);
  }
}
