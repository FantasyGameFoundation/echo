import 'dart:io';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:flutter/material.dart';

typedef ImportDraftNarrativePhoto = Future<String> Function(String sourcePath);

Future<String> importDraftNarrativePhotoToApp(String sourcePath) {
  return importMediaFile(
    sourcePath: sourcePath,
    collection: 'narrative_elements',
  );
}

class ChapterNarrativeElementCreatePage extends StatefulWidget {
  const ChapterNarrativeElementCreatePage({
    super.key,
    PickProjectCoverImage? onPickPhoto,
    ImportDraftNarrativePhoto? onImportPhoto,
  }) : onPickPhoto = onPickPhoto ?? pickProjectCoverImageFromGallery,
       onImportPhoto = onImportPhoto ?? importDraftNarrativePhotoToApp;

  final PickProjectCoverImage onPickPhoto;
  final ImportDraftNarrativePhoto onImportPhoto;

  @override
  State<ChapterNarrativeElementCreatePage> createState() =>
      _ChapterNarrativeElementCreatePageState();
}

class _ChapterNarrativeElementCreatePageState
    extends State<ChapterNarrativeElementCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final List<String> _mountedPhotos = <String>[];

  bool get _hasChanges {
    return _nameController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _mountedPhotos.isNotEmpty;
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
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
    final photoPath = await widget.onPickPhoto();
    if (!mounted || photoPath == null) {
      return;
    }

    try {
      final storedPath = await widget.onImportPhoto(photoPath);
      if (!mounted) {
        return;
      }
      setState(() {
        _mountedPhotos.add(storedPath);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showImportFailedHint();
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _mountedPhotos.removeAt(index);
    });
  }

  void _save() {
    if (!_canSave) {
      return;
    }

    Navigator.of(context).pop(
      NarrativeElementDraft(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        photoPaths: List<String>.from(_mountedPhotos),
      ),
    );
  }

  void _showImportFailedHint() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '照片导入失败，请重试',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            color: Colors.grey.shade700,
          ),
        ),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        margin: const EdgeInsets.only(left: 88, right: 88, bottom: 96),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
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
              child: Center(
                child: IgnorePointer(
                  ignoring: !_hasChanges || !_canSave,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    opacity: _hasChanges ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
          const Text(
            '叙 事 元 素',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 48),
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
      for (int i = 0; i < _mountedPhotos.length; i++)
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
              clipBehavior: Clip.hardEdge,
              child: Image.file(
                File(_mountedPhotos[i]),
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
