import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_narrative_element_create_page.dart';
import 'package:flutter/material.dart';

typedef SaveChapter =
    Future<void> Function({
      required String title,
      required String description,
      required int sortOrder,
      required List<NarrativeElementDraft> elements,
    });

class ChapterCreatePage extends StatefulWidget {
  const ChapterCreatePage({
    super.key,
    required this.existingChapters,
    required this.onSave,
  });

  final List<StructureChapter> existingChapters;
  final SaveChapter onSave;

  @override
  State<ChapterCreatePage> createState() => _ChapterCreatePageState();
}

class _ChapterCreatePageState extends State<ChapterCreatePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final List<_ChapterSequenceItem> _chapterItems;
  late final int _initialPendingIndex;
  final List<NarrativeElementDraft> _draftElements = <NarrativeElementDraft>[];
  bool _isSaving = false;

  bool get _hasChanges {
    final currentPendingIndex = _chapterItems.indexWhere(
      (item) => item.isPending,
    );
    return _titleController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _draftElements.isNotEmpty ||
        currentPendingIndex != _initialPendingIndex;
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _chapterItems = <_ChapterSequenceItem>[
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
        isPending: true,
      ),
    ];
    _initialPendingIndex = _chapterItems.indexWhere((item) => item.isPending);
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

  Future<void> _removeElement(NarrativeElementDraft element) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '确 认 移 除',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '将元素 "${element.title}" 从本章节中移除？',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(color: Colors.black),
                          alignment: Alignment.center,
                          child: const Text(
                            '移 除',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '取 消',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _draftElements.remove(element);
      });
    }
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }
    final currentPendingIndex = _chapterItems.indexWhere(
      (item) => item.isPending,
    );
    if (currentPendingIndex < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onSave(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      sortOrder: currentPendingIndex,
      elements: List<NarrativeElementDraft>.from(_draftElements),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
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
              color: Colors.black87,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            '添 加 章 节',
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
            final isPending = item.isPending;
            final displayTitle =
                isPending && _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : item.title;
            final displayDesc =
                isPending && _descController.text.trim().isNotEmpty
                ? _descController.text.trim()
                : item.desc;

            return ReorderableDelayedDragStartListener(
              key: ValueKey(item.id),
              index: index,
              enabled: isPending,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isPending
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.06),
                    width: isPending ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isPending ? 0.06 : 0.02,
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
                              color: isPending
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
                              fontWeight: isPending
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
                              color: isPending
                                  ? Colors.black54
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPending) ...[
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
      for (final element in _draftElements)
        InkWell(
          onLongPress: () => _removeElement(element),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Text(
              element.title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                letterSpacing: 1.0,
              ),
            ),
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
}

class _ChapterSequenceItem {
  const _ChapterSequenceItem({
    required this.id,
    required this.title,
    required this.desc,
    this.isPending = false,
  });

  final String id;
  final String title;
  final String desc;
  final bool isPending;
}
