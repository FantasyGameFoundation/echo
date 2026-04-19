import 'dart:ui';

import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_bottom_action_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:flutter/material.dart';

typedef SaveChapter =
    Future<void> Function({
      required String title,
      required String description,
      required int sortOrder,
      required String statusLabel,
      required List<NarrativeElementDraft> elements,
    });

typedef UpdateChapter = SaveChapter;

class ChapterElementEditorResult {
  const ChapterElementEditorResult.updated(this.element)
    : deletedElementId = null;

  const ChapterElementEditorResult.deleted(this.deletedElementId)
    : element = null;

  final NarrativeElement? element;
  final String? deletedElementId;

  bool get wasDeleted => deletedElementId != null;
}

class ChapterCreatePage extends StatelessWidget {
  const ChapterCreatePage({
    super.key,
    required this.existingChapters,
    required this.onSave,
  });

  final List<StructureChapter> existingChapters;
  final SaveChapter onSave;

  @override
  Widget build(BuildContext context) {
    return _ChapterEditorPage(
      existingChapters: existingChapters,
      pageTitle: '添 加 章 节',
      editorChapter: null,
      existingElements: const <NarrativeElement>[],
      onSave: onSave,
    );
  }
}

class ChapterEditPage extends StatelessWidget {
  const ChapterEditPage({
    super.key,
    required this.existingChapters,
    required this.chapter,
    required this.existingElements,
    required this.onSave,
    required this.onComplete,
    required this.onDelete,
    this.onOpenExistingElement,
  });

  final List<StructureChapter> existingChapters;
  final StructureChapter chapter;
  final List<NarrativeElement> existingElements;
  final UpdateChapter onSave;
  final UpdateChapter onComplete;
  final Future<void> Function() onDelete;
  final Future<ChapterElementEditorResult?> Function(NarrativeElement element)?
  onOpenExistingElement;

  @override
  Widget build(BuildContext context) {
    return _ChapterEditorPage(
      existingChapters: existingChapters,
      pageTitle: '编 辑 章 节',
      editorChapter: chapter,
      existingElements: existingElements,
      onSave: onSave,
      onComplete: onComplete,
      onDelete: onDelete,
      onOpenExistingElement: onOpenExistingElement,
    );
  }
}

class _ChapterEditorPage extends StatefulWidget {
  const _ChapterEditorPage({
    required this.existingChapters,
    required this.pageTitle,
    required this.editorChapter,
    required this.existingElements,
    required this.onSave,
    this.onComplete,
    this.onDelete,
    this.onOpenExistingElement,
  });

  final List<StructureChapter> existingChapters;
  final String pageTitle;
  final StructureChapter? editorChapter;
  final List<NarrativeElement> existingElements;
  final UpdateChapter onSave;
  final UpdateChapter? onComplete;
  final Future<void> Function()? onDelete;
  final Future<ChapterElementEditorResult?> Function(NarrativeElement element)?
  onOpenExistingElement;

  bool get isEditMode => editorChapter != null;

  @override
  State<_ChapterEditorPage> createState() => _ChapterEditorPageState();
}

class _ChapterEditorPageState extends State<_ChapterEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final List<_ChapterSequenceItem> _chapterItems;
  late final List<NarrativeElement> _persistedElements;
  final List<NarrativeElementDraft> _draftElements = <NarrativeElementDraft>[];
  bool _isSaving = false;
  bool _didUnlockCompletedChapter = false;

  int get _currentEditableIndex =>
      _chapterItems.indexWhere((item) => item.isEditable);

  String get _currentTitle => _titleController.text.trim();

  String get _currentDescription => _descController.text.trim();

  bool get _isCompletedChapter =>
      widget.isEditMode && widget.editorChapter?.statusLabel == '完成';

  bool get _isLockedCompletedChapter =>
      _isCompletedChapter && !_didUnlockCompletedChapter;

  String get _currentStatusLabel {
    if (!widget.isEditMode) {
      return '进行';
    }
    if (_isCompletedChapter && _didUnlockCompletedChapter) {
      return '进行';
    }
    return widget.editorChapter?.statusLabel ?? '进行';
  }

  bool get _canSave => _currentTitle.isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    final initialTitle = widget.editorChapter?.title.trim() ?? '';
    final initialDescription = widget.editorChapter?.description?.trim() ?? '';
    _persistedElements = List<NarrativeElement>.from(widget.existingElements);
    _titleController = TextEditingController(text: initialTitle);
    _descController = TextEditingController(text: initialDescription);
    _chapterItems = _buildSequenceItems();
    _titleController.addListener(_onChanged);
    _descController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _descController.removeListener(_onChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<_ChapterSequenceItem> _buildSequenceItems() {
    if (!widget.isEditMode) {
      return <_ChapterSequenceItem>[
        for (final chapter in widget.existingChapters)
          _ChapterSequenceItem(
            id: chapter.chapterId,
            title: chapter.title,
            desc: chapter.description?.trim().isNotEmpty == true
                ? chapter.description!
                : '暂无章节说明',
          ),
        const _ChapterSequenceItem(
          id: 'pending',
          title: '拟添加章节',
          desc: '长按拖动排列本章节位置',
          isEditable: true,
        ),
      ];
    }

    return <_ChapterSequenceItem>[
      for (final chapter in widget.existingChapters)
        _ChapterSequenceItem(
          id: chapter.chapterId,
          title: chapter.title,
          desc: chapter.description?.trim().isNotEmpty == true
              ? chapter.description!
              : '暂无章节说明',
          isEditable: chapter.chapterId == widget.editorChapter!.chapterId,
        ),
    ];
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openAddElementPage() async {
    final draft = await Navigator.of(context).push<NarrativeElementDraft>(
      MaterialPageRoute(
        builder: (_) => const ChapterNarrativeElementCreatePage(),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    setState(() {
      _draftElements.add(draft);
    });
  }

  Future<void> _openEditDraftElementPage(
    NarrativeElementDraft element,
    int index,
  ) async {
    final updatedDraft = await Navigator.of(context)
        .push<NarrativeElementDraft>(
          MaterialPageRoute(
            builder: (_) =>
                ChapterNarrativeElementCreatePage(initialDraft: element),
          ),
        );

    if (!mounted || updatedDraft == null) {
      return;
    }

    setState(() {
      _draftElements[index] = updatedDraft;
    });
  }

  Future<void> _openExistingElementPage(NarrativeElement element) async {
    if (widget.onOpenExistingElement == null) {
      return;
    }

    final editorResult = await widget.onOpenExistingElement!(element);
    if (!mounted || editorResult == null) {
      return;
    }

    setState(() {
      if (editorResult.wasDeleted) {
        _persistedElements.removeWhere(
          (current) => current.elementId == editorResult.deletedElementId,
        );
        return;
      }

      final updatedElement = editorResult.element!;
      final targetIndex = _persistedElements.indexWhere(
        (current) => current.elementId == updatedElement.elementId,
      );
      if (targetIndex >= 0) {
        _persistedElements[targetIndex] = updatedElement;
      }
      if (_isCompletedChapter && updatedElement.status != 'ready') {
        _didUnlockCompletedChapter = true;
      }
    });
  }

  Future<void> _removeDraftElement(NarrativeElementDraft element) async {
    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确 认 移 除',
      content: '将元素 "${element.title}" 从本章节中移除？',
      actionText: '移 除',
    );

    if (confirmed && mounted) {
      setState(() {
        _draftElements.remove(element);
      });
    }
  }

  Future<void> _save() async {
    if (_isLockedCompletedChapter) {
      _showPassiveHint('章节已完成无法保存，如需编辑请点击右上角继续编辑');
      return;
    }
    if (!_canSave) {
      return;
    }
    if (_currentEditableIndex < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onSave(
      title: _currentTitle,
      description: _currentDescription,
      sortOrder: _currentEditableIndex,
      statusLabel: _currentStatusLabel,
      elements: List<NarrativeElementDraft>.from(_draftElements),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _completeChapter() async {
    if (_isLockedCompletedChapter) {
      setState(() {
        _didUnlockCompletedChapter = true;
      });
      _showPassiveHint('章节现可继续编辑');
      return;
    }
    if (!_canSave || widget.onComplete == null) {
      return;
    }

    final completionMessage = _completionValidationMessage();
    if (completionMessage != null) {
      _showPassiveHint(completionMessage);
      return;
    }
    if (_currentEditableIndex < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onComplete!(
      title: _currentTitle,
      description: _currentDescription,
      sortOrder: _currentEditableIndex,
      statusLabel: '完成',
      elements: [
        for (final draft in _draftElements)
          NarrativeElementDraft(
            title: draft.title,
            description: draft.description,
            photoPaths: List<String>.from(draft.photoPaths),
            status: 'ready',
          ),
      ],
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _deleteChapter() async {
    if (_isSaving || widget.onDelete == null) {
      return;
    }

    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确 认 删 除',
      content: '删除后，本章节会从结构中移除，章节内元素将保留并转入未分配章节。',
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
    Navigator.of(context).pop();
  }

  String? _completionValidationMessage() {
    final combinedElements = <_CompletionElementState>[
      for (final element in _persistedElements)
        _CompletionElementState(
          title: element.title,
          hasPhoto: element.photoPaths.isNotEmpty,
        ),
      for (final element in _draftElements)
        _CompletionElementState(
          title: element.title,
          hasPhoto: element.photoPaths.isNotEmpty,
        ),
    ];

    if (combinedElements.isEmpty) {
      return '章节缺少元素，无法完成。';
    }

    for (final element in combinedElements) {
      if (!element.hasPhoto) {
        return '仍有叙事元素未关联照片，无法完成章节';
      }
    }

    return null;
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
    final isLocked = _isLockedCompletedChapter;
    return EditorBottomActionBar(
      leftLabel: _isSaving ? '保 存 中' : '保 存',
      leftKey: ValueKey(
        isLocked ? 'chapterLockedSaveButton' : 'chapterSaveButton',
      ),
      leftTone: EditorBottomActionTone.primary,
      leftEnabled: isLocked || _canSave,
      onLeftTap: _save,
      rightLabel: widget.isEditMode ? '删 除' : null,
      rightKey: widget.isEditMode
          ? const ValueKey('chapterDeleteButton')
          : null,
      rightEnabled: !_isSaving,
      onRightTap: widget.isEditMode ? _deleteChapter : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
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
                      _buildTitleInput(),
                      const SizedBox(height: 16),
                      _buildDescInput(),
                      const SizedBox(height: 48),
                      _buildSequenceDragger(),
                      const SizedBox(height: 48),
                      _buildSectionHeader('包 含 元 素'),
                      const SizedBox(height: 16),
                      _buildElementsSection(),
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
    );
  }

  Widget _buildTopBar() {
    final rightActionLabel = _isLockedCompletedChapter ? '继续编辑' : '章节完成';

    final populatedRightAction = widget.isEditMode
        ? TextButton(
            key: const ValueKey('chapterCompleteButton'),
            onPressed: _isSaving ? null : _completeChapter,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(80, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              rightActionLabel,
              style: TextStyle(
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
            onPressed: () => Navigator.of(context).pop(),
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
          populatedRightAction,
        ],
      ),
    );
  }

  Widget _buildSequenceDragger() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('章 节 排 列'),
        const SizedBox(height: 16),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 0,
              child: child,
            );
          },
          itemCount: _chapterItems.length,
          itemBuilder: (context, index) {
            final item = _chapterItems[index];
            final seqStr = (index + 1).toString().padLeft(2, '0');
            final isEditable = item.isEditable;
            final displayTitle =
                isEditable && _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : item.title;
            final displayDesc =
                isEditable && _descController.text.trim().isNotEmpty
                ? _descController.text.trim()
                : item.desc;

            return ReorderableDelayedDragStartListener(
              key: ValueKey(item.id),
              index: index,
              enabled: isEditable,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isEditable
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.06),
                    width: isEditable ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isEditable ? 0.06 : 0.02,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'C H A P T E R   $seqStr',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              color: isEditable
                                  ? Colors.black87
                                  : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 1.0,
                              fontWeight: isEditable
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayDesc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isEditable
                                  ? Colors.black54
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEditable) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.drag_handle,
                        color: Colors.black38,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            setState(() {
              final item = _chapterItems.removeAt(oldIndex);
              _chapterItems.insert(newIndex, item);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      key: const ValueKey('chapterCreateTitleField'),
      controller: _titleController,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 1.0,
      ),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: '章节名称',
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
      key: const ValueKey('chapterCreateDescriptionField'),
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
        hintText: '描述章节核心线索或视觉基调',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildElementsSection() {
    final items = <Widget>[
      for (final element in _persistedElements)
        InkWell(
          onTap: () => _openExistingElementPage(element),
          child: _buildElementTag(
            label: element.title,
            addPhotoWarning: element.photoPaths.isEmpty,
          ),
        ),
      for (var index = 0; index < _draftElements.length; index++)
        InkWell(
          onTap: () => _openEditDraftElementPage(_draftElements[index], index),
          onLongPress: () => _removeDraftElement(_draftElements[index]),
          child: _buildElementTag(
            label: _draftElements[index].title,
            addPhotoWarning: _draftElements[index].photoPaths.isEmpty,
          ),
        ),
      InkWell(
        onTap: _openAddElementPage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                '添加叙事元素',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: items);
  }

  Widget _buildElementTag({
    required String label,
    bool addPhotoWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Text(
        addPhotoWarning ? '$label · 待补照片' : label,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ChapterSequenceItem {
  const _ChapterSequenceItem({
    required this.id,
    required this.title,
    required this.desc,
    this.isEditable = false,
  });

  final String id;
  final String title;
  final String desc;
  final bool isEditable;
}

class _CompletionElementState {
  const _CompletionElementState({required this.title, required this.hasPhoto});

  final String title;
  final bool hasPhoto;
}
