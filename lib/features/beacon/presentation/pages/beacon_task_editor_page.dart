import 'dart:ui';

import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:echo/shared/models/content_preview_item.dart';
import 'package:echo/shared/widgets/content_preview_card.dart';
import 'package:flutter/material.dart';

class BeaconTaskEditorPage extends StatefulWidget {
  const BeaconTaskEditorPage({
    super.key,
    required this.chapters,
    required this.elements,
    required this.onSave,
    this.task,
    this.onDelete,
    this.onArchive,
    this.onRestore,
  });

  final BeaconTask? task;
  final List<StructureChapter> chapters;
  final List<NarrativeElement> elements;
  final Future<void> Function({
    required String title,
    required String description,
    required List<String> linkedElementIds,
  })
  onSave;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onArchive;
  final Future<bool> Function()? onRestore;

  @override
  State<BeaconTaskEditorPage> createState() => _BeaconTaskEditorPageState();
}

class _BeaconTaskEditorPageState extends State<BeaconTaskEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final Set<String> _selectedElementIds;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isArchiving = false;
  bool _isRestoring = false;

  bool get _isEditMode => widget.task != null;

  bool get _canSave =>
      !_isSaving &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  List<_ChapterElementGroup> get _chapterGroups {
    final orderedChapters = List<StructureChapter>.from(widget.chapters)
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final chapterIndexById = <String, int>{
      for (var index = 0; index < orderedChapters.length; index++)
        orderedChapters[index].chapterId: index,
    };
    final orderedElements = List<NarrativeElement>.from(widget.elements)
      ..sort((left, right) {
        final leftIndex = left.owningChapterId == null
            ? 1 << 20
            : (chapterIndexById[left.owningChapterId] ?? (1 << 20));
        final rightIndex = right.owningChapterId == null
            ? 1 << 20
            : (chapterIndexById[right.owningChapterId] ?? (1 << 20));
        final chapterCompare = leftIndex.compareTo(rightIndex);
        if (chapterCompare != 0) {
          return chapterCompare;
        }
        final sortCompare = left.sortOrder.compareTo(right.sortOrder);
        if (sortCompare != 0) {
          return sortCompare;
        }
        return left.createdAt.compareTo(right.createdAt);
      });

    final groups = <_ChapterElementGroup>[];
    for (final chapter in orderedChapters) {
      final elements = orderedElements
          .where((element) => element.owningChapterId == chapter.chapterId)
          .toList(growable: false);
      if (elements.isEmpty) {
        continue;
      }
      groups.add(
        _ChapterElementGroup(
          heading: _chapterHeading(chapter),
          elements: elements,
        ),
      );
    }

    final unassignedElements = orderedElements
        .where((element) => element.owningChapterId == null)
        .toList(growable: false);
    if (unassignedElements.isNotEmpty) {
      groups.add(
        _ChapterElementGroup(heading: '未 归 章 节', elements: unassignedElements),
      );
    }
    return groups;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '')
      ..addListener(_handleFieldChange);
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    )..addListener(_handleFieldChange);
    _selectedElementIds = Set<String>.from(
      widget.task?.linkedElementIds ?? const <String>[],
    );
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_handleFieldChange)
      ..dispose();
    _descriptionController
      ..removeListener(_handleFieldChange)
      ..dispose();
    super.dispose();
  }

  String _chapterHeading(StructureChapter chapter) {
    final chapterNumber = (chapter.sortOrder + 1).toString().padLeft(2, '0');
    return 'C H A P T E R  $chapterNumber  /  ${chapter.title}';
  }

  void _handleFieldChange() {
    setState(() {});
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }
    setState(() => _isSaving = true);
    await widget.onSave(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      linkedElementIds: _selectedElementIds.toList(growable: false),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.onDelete == null || _isDeleting) {
      return;
    }
    final confirmed = await _showConfirmDialog(
      title: '删除任务',
      content: '删除后，这条外拍任务会从信标页中移除。',
      confirmLabel: '删除',
    );
    if (!confirmed) {
      return;
    }
    setState(() => _isDeleting = true);
    await widget.onDelete!.call();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _archive() async {
    if (widget.onArchive == null ||
        _isArchiving ||
        widget.task?.isArchived == true) {
      return;
    }
    final confirmed = await _showConfirmDialog(
      title: '归档任务',
      content: '归档后，这条任务会从“待执行”移到“已归档”。',
      confirmLabel: '归档',
    );
    if (!confirmed) {
      return;
    }
    setState(() => _isArchiving = true);
    await widget.onArchive!.call();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _restore() async {
    if (widget.onRestore == null ||
        _isRestoring ||
        widget.task?.isArchived != true) {
      return;
    }
    setState(() => _isRestoring = true);
    final restored = await widget.onRestore!.call();
    if (!mounted) {
      return;
    }
    if (!restored) {
      setState(() => _isRestoring = false);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final result = await showEditorConfirmationDialog(
      context: context,
      title: title,
      content: content,
      actionText: confirmLabel,
    );
    return result;
  }

  void _toggleElement(String elementId) {
    setState(() {
      if (_selectedElementIds.contains(elementId)) {
        _selectedElementIds.remove(elementId);
      } else {
        _selectedElementIds.add(elementId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? '编辑任务' : '添加任务';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFF9F9FA), Color(0xFFF3F3F5)],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildTopBar(title),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                    children: [
                      if (_isEditMode) ...[
                        _buildFieldLabel('任务名'),
                        const SizedBox(height: 10),
                      ],
                      _buildTextField(
                        key: const ValueKey('beaconTaskEditorTitleField'),
                        controller: _titleController,
                        maxLines: 1,
                        hintText: '任务名称',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF232323),
                          letterSpacing: 1.0,
                          height: 1.2,
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD3D3D3),
                          letterSpacing: 1.0,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_isEditMode) ...[
                        _buildFieldLabel('任务介绍'),
                        const SizedBox(height: 10),
                      ],
                      _buildTextField(
                        key: const ValueKey('beaconTaskEditorDescriptionField'),
                        controller: _descriptionController,
                        maxLines: 5,
                        hintText: '描述任务目标或现场线索',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8B8B8),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildFieldLabel('关联元素'),
                      const SizedBox(height: 14),
                      _buildElementSelector(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 34,
              left: 24,
              right: 24,
              child: _buildBottomActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 4.0,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey('beaconTaskEditorArchiveButton'),
                onPressed: _archiveAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  widget.task?.isArchived == true ? '恢复' : '归档',
                  style: TextStyle(
                    color: _archiveAction == null
                        ? const Color(0xFFB0B0B0)
                        : Colors.black87,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? get _archiveAction {
    if (!_isEditMode) {
      return null;
    }
    if (widget.task?.isArchived == true) {
      if (_isRestoring || widget.onRestore == null) {
        return null;
      }
      return () {
        _restore();
      };
    }
    if (_isArchiving || widget.onArchive == null) {
      return null;
    }
    return () {
      _archive();
    };
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.2,
        color: Color(0xFF8B8B8B),
      ),
    );
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required int maxLines,
    required String hintText,
    required TextStyle style,
    required TextStyle hintStyle,
  }) {
    return TextField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      style: style,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildElementSelector() {
    if (widget.elements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '当前项目还没有元素可关联。',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (
          var groupIndex = 0;
          groupIndex < _chapterGroups.length;
          groupIndex++
        ) ...[
          if (groupIndex > 0) const SizedBox(height: 18),
          _buildChapterHeading(_chapterGroups[groupIndex].heading),
          const SizedBox(height: 8),
          for (final element in _chapterGroups[groupIndex].elements)
            _buildElementCard(
              element,
              isSelected: _selectedElementIds.contains(element.elementId),
            ),
        ],
      ],
    );
  }

  Widget _buildChapterHeading(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFA6A6A6),
          letterSpacing: 4.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildElementCard(
    NarrativeElement element, {
    required bool isSelected,
  }) {
    final previewItems = _previewItemsForElement(element);
    return InkWell(
      key: ValueKey('beaconTaskEditorElement-${element.elementId}'),
      onTap: () => _toggleElement(element.elementId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (element.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      element.description!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white54
                            : Colors.black.withValues(alpha: 0.44),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildElementThumbs(previewItems),
          ],
        ),
      ),
    );
  }

  List<ContentPreviewItem> _previewItemsForElement(NarrativeElement element) {
    return element.photoPaths
        .where((path) => path.trim().isNotEmpty)
        .map(
          (path) => ContentPreviewItem.photo(
            stableId: '${element.elementId}::$path',
            imageSource: path,
          ),
        )
        .toList(growable: false);
  }

  Widget _buildElementThumbs(List<ContentPreviewItem> previewItems) {
    if (previewItems.isEmpty) {
      return Container(
        width: 44,
        height: 44,
        color: const Color(0xFFF1F1F3),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.black26,
          size: 18,
        ),
      );
    }

    final hasDirectSecondary = previewItems.length == 2;
    final hasOverflow = previewItems.length > 2;
    return SizedBox(
      width: previewItems.length > 1 ? 90 : 44,
      height: 44,
      child: Row(
        children: [
          _buildElementThumb(previewItems.first),
          if (hasDirectSecondary)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: _buildElementThumb(previewItems[1]),
            ),
          if (hasOverflow)
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(left: 2),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(color: Color(0xFFF1F1F3)),
              child: ContentPreviewOverflowCard(
                item: previewItems[1],
                label: '+${previewItems.length - 1}',
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFF1F1F3)),
                textStyle: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.1,
                ),
                maxLines: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElementThumb(ContentPreviewItem item) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ContentPreviewCard(
        item: item,
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Color(0xFFF1F1F3)),
        textStyle: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.1,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isEditMode) ...[
          _buildActionButton(
            key: const ValueKey('beaconTaskEditorDeleteButton'),
            label: '删 除',
            onTap: _delete,
            dark: false,
          ),
          const SizedBox(width: 14),
        ],
        _buildActionButton(
          key: const ValueKey('beaconTaskEditorSaveButton'),
          label: _isSaving ? '保 存 中' : '保 存',
          onTap: _save,
          dark: true,
          enabled: _canSave,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Key key,
    required String label,
    required Future<void> Function() onTap,
    required bool dark,
    bool enabled = true,
  }) {
    final foregroundColor = dark ? Colors.white : const Color(0xFF2E2E2E);
    final backgroundColor = !enabled
        ? const Color(0xFFE7E7EB)
        : (dark ? Colors.black : Colors.white.withValues(alpha: 0.75));
    return GestureDetector(
      key: key,
      onTap: enabled
          ? () {
              onTap();
            }
          : null,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: dark ? 0 : 5, sigmaY: dark ? 0 : 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 4.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterElementGroup {
  const _ChapterElementGroup({required this.heading, required this.elements});

  final String heading;
  final List<NarrativeElement> elements;
}
