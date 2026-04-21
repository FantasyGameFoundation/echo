import 'dart:io';
import 'dart:ui';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_bottom_action_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ImportNarrativePhoto = Future<String> Function(String sourcePath);
typedef SaveNarrativeElement =
    Future<void> Function({
      required String title,
      required String description,
      required String? chapterId,
      required String status,
      required String? unlockChapterId,
      required List<String> photoPaths,
    });

Future<String> importNarrativePhotoToApp(String sourcePath) {
  return importMediaFile(
    sourcePath: sourcePath,
    collection: 'narrative_elements',
  );
}

class NarrativeElementCreatePage extends StatelessWidget {
  const NarrativeElementCreatePage({
    super.key,
    required this.chapters,
    required this.onSave,
    PickGalleryImages? onPickPhoto,
    ImportNarrativePhoto? onImportPhoto,
  }) : onPickPhoto = onPickPhoto ?? pickGalleryImagesFromGallery,
       onImportPhoto = onImportPhoto ?? importNarrativePhotoToApp;

  final List<StructureChapter> chapters;
  final SaveNarrativeElement onSave;
  final PickGalleryImages onPickPhoto;
  final ImportNarrativePhoto onImportPhoto;

  @override
  Widget build(BuildContext context) {
    return _NarrativeElementEditorPage(
      chapters: chapters,
      pageTitle: '叙 事 元 素',
      editorElement: null,
      allowChapterSelection: true,
      onSave: onSave,
      onPickPhoto: onPickPhoto,
      onImportPhoto: onImportPhoto,
    );
  }
}

class NarrativeElementEditPage extends StatelessWidget {
  const NarrativeElementEditPage({
    super.key,
    required this.chapters,
    required this.element,
    required this.onSave,
    required this.onComplete,
    required this.onDelete,
    this.allowChapterSelection = true,
    PickGalleryImages? onPickPhoto,
    ImportNarrativePhoto? onImportPhoto,
  }) : onPickPhoto = onPickPhoto ?? pickGalleryImagesFromGallery,
       onImportPhoto = onImportPhoto ?? importNarrativePhotoToApp;

  final List<StructureChapter> chapters;
  final NarrativeElement element;
  final SaveNarrativeElement onSave;
  final SaveNarrativeElement onComplete;
  final Future<void> Function() onDelete;
  final bool allowChapterSelection;
  final PickGalleryImages onPickPhoto;
  final ImportNarrativePhoto onImportPhoto;

  @override
  Widget build(BuildContext context) {
    return _NarrativeElementEditorPage(
      chapters: chapters,
      pageTitle: '叙 事 元 素',
      editorElement: element,
      allowChapterSelection: allowChapterSelection,
      onSave: onSave,
      onComplete: onComplete,
      onDelete: onDelete,
      onPickPhoto: onPickPhoto,
      onImportPhoto: onImportPhoto,
    );
  }
}

class _NarrativeElementEditorPage extends StatefulWidget {
  const _NarrativeElementEditorPage({
    required this.chapters,
    required this.pageTitle,
    required this.editorElement,
    required this.allowChapterSelection,
    required this.onSave,
    required this.onPickPhoto,
    required this.onImportPhoto,
    this.onComplete,
    this.onDelete,
  });

  final List<StructureChapter> chapters;
  final String pageTitle;
  final NarrativeElement? editorElement;
  final bool allowChapterSelection;
  final SaveNarrativeElement onSave;
  final SaveNarrativeElement? onComplete;
  final Future<void> Function()? onDelete;
  final PickGalleryImages onPickPhoto;
  final ImportNarrativePhoto onImportPhoto;

  bool get isEditMode => editorElement != null;

  @override
  State<_NarrativeElementEditorPage> createState() =>
      _NarrativeElementEditorPageState();
}

class _NarrativeElementEditorPageState
    extends State<_NarrativeElementEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final String _initialTitle;
  late final String _initialDescription;
  late final String? _initialChapterId;
  late final List<String> _initialPhotoPaths;
  String? _selectedChapterId;
  final List<String> _mountedPhotos = <String>[];
  bool _isSaving = false;
  bool _didUnlockCompletedElement = false;
  bool _didFinishEditing = false;

  String get _currentTitle => _nameController.text.trim();

  String get _currentDescription => _descController.text.trim();

  bool get _isCompletedElement =>
      widget.isEditMode && widget.editorElement?.status == 'ready';

  bool get _isLockedCompletedElement =>
      _isCompletedElement && !_didUnlockCompletedElement;

  String get _currentStatus {
    if (!widget.isEditMode) {
      return 'finding';
    }
    if (_isCompletedElement && _didUnlockCompletedElement) {
      return 'finding';
    }
    return widget.editorElement?.status ?? 'finding';
  }

  bool get _canSave => _currentTitle.isNotEmpty && !_isSaving;

  bool get _hasUnsavedChanges =>
      _currentTitle != _initialTitle ||
      _currentDescription != _initialDescription ||
      _selectedChapterId != _initialChapterId ||
      !listEquals(_mountedPhotos, _initialPhotoPaths) ||
      _didUnlockCompletedElement;

  String? get _unlockChapterId {
    if (!_didUnlockCompletedElement) {
      return null;
    }
    final selectedChapter = _chapterById(_selectedChapterId);
    if (selectedChapter?.statusLabel == '完成') {
      return selectedChapter!.chapterId;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.editorElement?.title.trim() ?? '';
    _initialDescription = widget.editorElement?.description?.trim() ?? '';
    _initialPhotoPaths = List<String>.from(
      widget.editorElement?.photoPaths ?? const <String>[],
    );
    _initialChapterId = widget.allowChapterSelection
        ? widget.editorElement?.owningChapterId ??
              (widget.chapters.isEmpty ? null : widget.chapters.first.chapterId)
        : widget.editorElement?.owningChapterId;
    _selectedChapterId = _initialChapterId;
    _mountedPhotos.addAll(_initialPhotoPaths);
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

  Future<bool> _confirmDiscardUnsavedChanges() async {
    if (_didFinishEditing || _isSaving || !_hasUnsavedChanges) {
      return true;
    }
    return showDiscardUnsavedChangesDialog(context: context);
  }

  Future<void> _handleBackNavigation() async {
    final shouldPop = await _confirmDiscardUnsavedChanges();
    if (!mounted || !shouldPop) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _mountPhoto() async {
    final photoPaths = await widget.onPickPhoto();
    if (!mounted || photoPaths.isEmpty) {
      return;
    }

    final storedPaths = <String>[];
    var hasImportFailure = false;
    for (final photoPath in photoPaths) {
      try {
        final storedPath = await widget.onImportPhoto(photoPath);
        storedPaths.add(storedPath);
      } catch (_) {
        hasImportFailure = true;
      }
    }
    if (!mounted) {
      return;
    }
    if (storedPaths.isNotEmpty) {
      setState(() {
        _mountedPhotos.addAll(storedPaths);
      });
    }
    if (hasImportFailure) {
      _showPassiveHint('照片导入失败，请重试');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _mountedPhotos.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_isLockedCompletedElement) {
      _showPassiveHint('叙事元素已完成，请先点击右上角继续编辑');
      return;
    }
    if (!_canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onSave(
      title: _currentTitle,
      description: _currentDescription,
      chapterId: _selectedChapterId,
      status: _currentStatus,
      unlockChapterId: _unlockChapterId,
      photoPaths: List<String>.from(_mountedPhotos),
    );
    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop();
  }

  Future<void> _completeElement() async {
    if (_isLockedCompletedElement) {
      await _unlockCompletedElement();
      return;
    }
    if (!_canSave || widget.onComplete == null) {
      return;
    }
    if (_mountedPhotos.isEmpty) {
      _showPassiveHint('元素缺少照片，无法完成。');
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onComplete!(
      title: _currentTitle,
      description: _currentDescription,
      chapterId: _selectedChapterId,
      status: 'ready',
      unlockChapterId: null,
      photoPaths: List<String>.from(_mountedPhotos),
    );
    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop();
  }

  Future<void> _unlockCompletedElement() async {
    final selectedChapter = _chapterById(_selectedChapterId);
    if (selectedChapter?.statusLabel == '完成') {
      final confirmed = await _showUnlockConfirmationDialog();
      if (!mounted || !confirmed) {
        return;
      }
      setState(() {
        _didUnlockCompletedElement = true;
      });
      _showPassiveHint('叙事元素及所属章节现可继续编辑');
      return;
    }

    setState(() {
      _didUnlockCompletedElement = true;
    });
    _showPassiveHint('叙事元素现可继续编辑');
  }

  StructureChapter? _chapterById(String? chapterId) {
    if (chapterId == null) {
      return null;
    }
    for (final chapter in widget.chapters) {
      if (chapter.chapterId == chapterId) {
        return chapter;
      }
    }
    return null;
  }

  Future<bool> _showUnlockConfirmationDialog() async {
    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确认继续编辑',
      content: '继续编辑该元素后，所属章节也会恢复为可编辑状态。',
      actionText: '继续编辑',
    );

    return confirmed;
  }

  Future<void> _deleteElement() async {
    if (_isSaving || widget.onDelete == null) {
      return;
    }

    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确 认 删 除',
      content: '删除后，仅当前元素及引用它的关联关系会移除；章节与关系类型会保留，当前页面将返回列表。',
      actionText: '删 除',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onDelete!();
    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop();
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

  Widget _buildBottomActions() {
    final isLocked = _isLockedCompletedElement;
    return EditorBottomActionBar(
      leftLabel: _isSaving ? '保 存 中' : '保 存',
      leftKey: ValueKey(
        isLocked ? 'narrativeLockedSaveButton' : 'narrativeSaveButton',
      ),
      leftTone: EditorBottomActionTone.primary,
      leftEnabled: isLocked || _canSave,
      onLeftTap: _save,
      rightLabel: widget.isEditMode ? '删 除' : null,
      rightKey: widget.isEditMode
          ? const ValueKey('narrativeDeleteButton')
          : null,
      rightEnabled: !_isSaving,
      onRightTap: widget.isEditMode ? _deleteElement : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _didFinishEditing || _isSaving || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmDiscardUnsavedChanges();
        if (!mounted || !shouldPop) {
          return;
        }
        _didFinishEditing = true;
        navigator.pop();
      },
      child: Scaffold(
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
                        if (widget.allowChapterSelection) ...[
                          _buildSectionLabel('所 属 章 节'),
                          const SizedBox(height: 16),
                          _buildChapterSelector(),
                          const SizedBox(height: 48),
                        ],
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
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(child: _buildBottomActions()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final rightActionLabel = _isLockedCompletedElement ? '继续编辑' : '元素完成';
    final rightAction = widget.isEditMode
        ? TextButton(
            key: const ValueKey('narrativeCompleteButton'),
            onPressed: _isSaving ? null : _completeElement,
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
              size: 18,
              color: Colors.black87,
            ),
            onPressed: _handleBackNavigation,
          ),
          Text(
            widget.pageTitle,
            style: const TextStyle(
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
