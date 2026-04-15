import 'dart:io';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:flutter/material.dart';

typedef ImportNarrativePhoto = Future<String> Function(String sourcePath);
typedef SaveNarrativeElement =
    Future<void> Function({
      required String title,
      required String description,
      required String? chapterId,
      required List<String> photoPaths,
    });

Future<String> importNarrativePhotoToApp(String sourcePath) {
  return importMediaFile(
    sourcePath: sourcePath,
    collection: 'narrative_elements',
  );
}

class NarrativeElementCreatePage extends StatefulWidget {
  const NarrativeElementCreatePage({
    super.key,
    required this.chapters,
    required this.onSave,
    PickProjectCoverImage? onPickPhoto,
    ImportNarrativePhoto? onImportPhoto,
  }) : onPickPhoto = onPickPhoto ?? pickProjectCoverImageFromGallery,
       onImportPhoto = onImportPhoto ?? importNarrativePhotoToApp;

  final List<StructureChapter> chapters;
  final SaveNarrativeElement onSave;
  final PickProjectCoverImage onPickPhoto;
  final ImportNarrativePhoto onImportPhoto;

  @override
  State<NarrativeElementCreatePage> createState() =>
      _NarrativeElementCreatePageState();
}

class _NarrativeElementCreatePageState
    extends State<NarrativeElementCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final String? _initialChapterId;
  String? _selectedChapterId;
  final List<String> _mountedPhotos = <String>[];
  bool _isSaving = false;

  bool get _hasChanges {
    return _nameController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _selectedChapterId != _initialChapterId ||
        _mountedPhotos.isNotEmpty;
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _initialChapterId = widget.chapters.isEmpty
        ? null
        : widget.chapters.first.chapterId;
    _selectedChapterId = _initialChapterId;
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

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onSave(
      title: _nameController.text.trim(),
      description: _descController.text.trim(),
      chapterId: _selectedChapterId,
      photoPaths: List<String>.from(_mountedPhotos),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
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
                      _buildSectionLabel('所 属 章 节'),
                      const SizedBox(height: 16),
                      _buildChapterSelector(),
                      const SizedBox(height: 48),
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
                        child: Text(
                          _isSaving ? '保 存 中' : '保 存',
                          style: const TextStyle(
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
              size: 18,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildChapterSelector() {
    if (widget.chapters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          '请先添加章节',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: widget.chapters.map((chapter) {
          final isSelected = _selectedChapterId == chapter.chapterId;
          final chapterLabel =
              'C H A P T E R   ${(chapter.sortOrder + 1).toString().padLeft(2, '0')}';
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedChapterId = chapter.chapterId;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.black12,
                  width: 1,
                ),
              ),
              child: Text(
                chapterLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black87,
                  letterSpacing: 1.0,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      key: const ValueKey('narrativeElementNameField'),
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
      key: const ValueKey('narrativeElementDescriptionField'),
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
