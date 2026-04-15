import 'dart:io';

import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:flutter/material.dart';

typedef SaveProjectEdits =
    Future<void> Function(
      String title,
      String themeStatement,
      String? coverImagePath,
    );

class ProjectEditPage extends StatefulWidget {
  const ProjectEditPage({
    super.key,
    required this.project,
    required this.onSave,
    PickProjectCoverImage? onPickCoverImage,
  }) : onPickCoverImage = onPickCoverImage ?? pickProjectCoverImageFromGallery;

  final Project project;
  final SaveProjectEdits onSave;
  final PickProjectCoverImage onPickCoverImage;

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _intentController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _intentFocusNode;

  late final String _initialName;
  late final String _initialIntent;
  late final String? _initialCoverImagePath;

  String? _coverImagePath;
  bool _isSaving = false;

  bool get _hasChanges {
    return _nameController.text.trim() != _initialName ||
        _intentController.text.trim() != _initialIntent ||
        _coverImagePath != _initialCoverImagePath;
  }

  @override
  void initState() {
    super.initState();
    _initialName = widget.project.title;
    _initialIntent = widget.project.themeStatement;
    _initialCoverImagePath = widget.project.coverImagePath;
    _coverImagePath = widget.project.coverImagePath;
    _nameController = TextEditingController(text: _initialName);
    _intentController = TextEditingController(text: _initialIntent);
    _nameFocusNode = FocusNode();
    _intentFocusNode = FocusNode();
    _nameController.addListener(_onDataChanged);
    _intentController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onDataChanged);
    _intentController.removeListener(_onDataChanged);
    _nameController.dispose();
    _intentController.dispose();
    _nameFocusNode.dispose();
    _intentFocusNode.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickCoverImage() async {
    final coverImagePath = await widget.onPickCoverImage();
    if (!mounted || coverImagePath == null) {
      return;
    }

    setState(() {
      _coverImagePath = coverImagePath;
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });

    await widget.onSave(
      _nameController.text.trim(),
      _intentController.text.trim(),
      _coverImagePath,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCoverEditor(),
                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNameEditor(),
                              const SizedBox(height: 48),
                              _buildIntentEditor(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                  ignoring: !_hasChanges || _isSaving,
                  child: AnimatedOpacity(
                    opacity: _hasChanges ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: GestureDetector(
                      onTap: _saveChanges,
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
            '编 辑 项 目',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCoverEditor() {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (_coverImagePath != null)
            _buildCoverImage(_coverImagePath!)
          else
            Center(
              child: Text(
                '暂 无 封 面',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  letterSpacing: 4.0,
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String coverImagePath) {
    final isNetworkImage =
        coverImagePath.startsWith('http://') ||
        coverImagePath.startsWith('https://');

    final image = isNetworkImage
        ? Image.network(
            coverImagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(),
          )
        : Image.file(
            File(coverImagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(),
          );

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: image,
    );
  }

  Widget _buildNameEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '项 目 名 称',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('projectEditNameField'),
          controller: _nameController,
          focusNode: _nameFocusNode,
          maxLines: null,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 2.0,
            height: 1.4,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '创 作 意 图',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('projectEditIntentField'),
          controller: _intentController,
          focusNode: _intentFocusNode,
          maxLines: null,
          minLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            hintText: '输入你的创作意图...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}
