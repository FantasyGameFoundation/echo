import 'package:echo/features/curation/presentation/models/pending_organize_models.dart';
import 'package:echo/features/curation/presentation/pages/pending_relation_group_selection_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class PendingOrganizePage extends StatefulWidget {
  const PendingOrganizePage({
    super.key,
    required this.data,
    required this.onSavePhoto,
  });

  final PendingOrganizePageData data;
  final Future<PendingOrganizePageData> Function(
    PendingOrganizeSaveRequest request,
  )
  onSavePhoto;

  @override
  State<PendingOrganizePage> createState() => _PendingOrganizePageState();
}

class _PendingOrganizePageState extends State<PendingOrganizePage> {
  late PendingOrganizePageData _data;
  late final PageController _pageController;
  final Map<String, _PendingEntryDraft> _drafts =
      <String, _PendingEntryDraft>{};

  int _currentIndex = 0;
  bool _isSaving = false;
  bool _didFinishEditing = false;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  PendingOrganizeEntryData? get _currentEntry {
    if (_data.entries.isEmpty) {
      return null;
    }
    final safeIndex = _currentIndex.clamp(0, _data.entries.length - 1);
    return _data.entries[safeIndex];
  }

  _PendingEntryDraft _draftFor(PendingOrganizeEntryData entry) {
    return _drafts.putIfAbsent(
      entry.entryId,
      () => _PendingEntryDraft(
        selectedChapterId: entry.sourceChapterId,
        selectedElementId: entry.sourceElementId,
        selectedRelationGroupIds: <String>{...entry.sourceRelationGroupIds},
      ),
    );
  }

  bool _isEntryDirty(PendingOrganizeEntryData entry) {
    final draft = _draftFor(entry);
    if (draft.selectedChapterId != entry.sourceChapterId) {
      return true;
    }
    if (draft.selectedElementId != entry.sourceElementId) {
      return true;
    }

    final initialGroupIds = entry.sourceRelationGroupIds.toSet();
    if (draft.selectedRelationGroupIds.length != initialGroupIds.length) {
      return true;
    }
    for (final groupId in draft.selectedRelationGroupIds) {
      if (!initialGroupIds.contains(groupId)) {
        return true;
      }
    }
    return false;
  }

  bool get _hasUnsavedChanges {
    for (final entry in _data.entries) {
      if (_isEntryDirty(entry)) {
        return true;
      }
    }
    return false;
  }

  bool get _canSaveCurrentEntry {
    final currentEntry = _currentEntry;
    if (currentEntry == null || _isSaving) {
      return false;
    }
    final draft = _draftFor(currentEntry);
    switch (currentEntry.type) {
      case PendingOrganizeEntryType.photo:
        return draft.selectedElementId != null && _isEntryDirty(currentEntry);
      case PendingOrganizeEntryType.text:
        return draft.selectedElementId != null && _isEntryDirty(currentEntry);
    }
  }

  List<PendingOrganizeElementOption> _filteredElements(
    _PendingEntryDraft draft,
  ) {
    final filtered =
        _data.elements
            .where((element) => element.chapterId == draft.selectedChapterId)
            .toList()
          ..sort((left, right) {
            final sortCompare = left.sortOrder.compareTo(right.sortOrder);
            if (sortCompare != 0) {
              return sortCompare;
            }
            return left.title.compareTo(right.title);
          });
    return filtered;
  }

  Future<bool> _confirmDiscardUnsavedChanges() async {
    if (_didFinishEditing || _isSaving || !_hasUnsavedChanges) {
      return true;
    }
    final action = await _showPendingUnsavedChangesDialog();
    if (!mounted) {
      return false;
    }
    switch (action) {
      case _PendingUnsavedAction.saveAll:
        return _saveAllDirtyPhotos();
      case _PendingUnsavedAction.discard:
        return true;
      case _PendingUnsavedAction.cancel:
      case null:
        return false;
    }
  }

  Future<void> _handleBackNavigation() async {
    final shouldPop = await _confirmDiscardUnsavedChanges();
    if (!mounted || !shouldPop) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop();
  }

  void _handlePageChanged(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _selectChapter(String? chapterId) {
    final currentEntry = _currentEntry;
    if (currentEntry == null) {
      return;
    }
    final draft = _draftFor(currentEntry);
    final nextElements = _data.elements
        .where((element) => element.chapterId == chapterId)
        .toList();

    setState(() {
      draft.selectedChapterId = chapterId;
      final selectedElementId = draft.selectedElementId;
      if (selectedElementId != null &&
          !nextElements.any(
            (element) => element.elementId == selectedElementId,
          )) {
        draft.selectedElementId = null;
      }
    });
  }

  void _selectElement(String elementId) {
    final currentEntry = _currentEntry;
    if (currentEntry == null) {
      return;
    }
    final draft = _draftFor(currentEntry);
    final element = _data.elements.firstWhere(
      (item) => item.elementId == elementId,
    );

    setState(() {
      draft.selectedChapterId = element.chapterId;
      draft.selectedElementId = elementId;
    });
  }

  Future<void> _openRelationTypeSelection(
    PendingOrganizeRelationTypeOption relationType,
  ) async {
    final currentEntry = _currentEntry;
    if (currentEntry == null) {
      return;
    }
    final draft = _draftFor(currentEntry);
    final initialGroupIds = draft.selectedRelationGroupIds
        .where(
          (groupId) =>
              relationType.groups.any((group) => group.groupId == groupId),
        )
        .toSet();

    final selectedGroupIds = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => PendingRelationGroupSelectionPage(
          relationType: relationType,
          initialSelectedGroupIds: initialGroupIds,
        ),
      ),
    );

    if (selectedGroupIds == null || !mounted) {
      return;
    }

    setState(() {
      draft.selectedRelationGroupIds.removeWhere(
        (groupId) =>
            relationType.groups.any((group) => group.groupId == groupId),
      );
      draft.selectedRelationGroupIds.addAll(selectedGroupIds);
    });
  }

  Future<void> _saveCurrentEntry() async {
    final currentEntry = _currentEntry;
    if (currentEntry == null) {
      return;
    }
    await _saveEntryById(
      currentEntry.entryId,
      preferredEntryId: currentEntry.entryId,
      manageSavingState: true,
    );
  }

  Future<bool> _saveEntryById(
    String entryId, {
    required String preferredEntryId,
    required bool manageSavingState,
  }) async {
    PendingOrganizeEntryData? entry;
    for (final item in _data.entries) {
      if (item.entryId == entryId) {
        entry = item;
        break;
      }
    }
    if (entry == null) {
      return true;
    }

    final draft = _draftFor(entry);
    if (!_isEntryDirty(entry)) {
      return true;
    }
    if (entry.type == PendingOrganizeEntryType.photo &&
        draft.selectedElementId == null) {
      return true;
    }
    if (entry.type == PendingOrganizeEntryType.text &&
        draft.selectedElementId == null) {
      return true;
    }

    if (manageSavingState) {
      setState(() {
        _isSaving = true;
      });
    }

    final previousIndex = _currentIndex;
    final updatedData = await widget.onSavePhoto(
      entry.type == PendingOrganizeEntryType.photo
          ? PendingOrganizeSaveRequest.photo(
              entryId: entry.entryId,
              photoPath: entry.photoPath!,
              sourceElementId: entry.sourceElementId,
              sourceRecordId: entry.sourceRecordId,
              targetChapterId: draft.selectedChapterId,
              targetElementId: draft.selectedElementId!,
              relationGroupIds: draft.selectedRelationGroupIds.toList(),
            )
          : PendingOrganizeSaveRequest.text(
              entryId: entry.entryId,
              textCardId: entry.textCardId!,
              targetChapterId: draft.selectedChapterId!,
              targetElementId: draft.selectedElementId!,
              relationGroupIds: draft.selectedRelationGroupIds.toList(),
            ),
    );

    if (!mounted) {
      return false;
    }

    setState(() {
      _data = updatedData;
      _drafts.remove(entryId);
      _drafts.removeWhere(
        (draftEntryId, _) =>
            !_data.entries.any((item) => item.entryId == draftEntryId),
      );
      if (manageSavingState) {
        _isSaving = false;
      }
      _currentIndex = _resolvedEntryIndex(
        preferredEntryId: preferredEntryId,
        previousIndex: previousIndex,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients || _data.entries.isEmpty) {
        return;
      }
      _pageController.jumpToPage(_currentIndex);
    });
    return true;
  }

  int _resolvedEntryIndex({
    required String preferredEntryId,
    required int previousIndex,
  }) {
    if (_data.entries.isEmpty) {
      return 0;
    }
    final updatedIndex = _data.entries.indexWhere(
      (entry) => entry.entryId == preferredEntryId,
    );
    if (updatedIndex >= 0) {
      return updatedIndex;
    }
    return previousIndex.clamp(0, _data.entries.length - 1);
  }

  Future<bool> _saveAllDirtyPhotos() async {
    final dirtyEntries = <PendingOrganizeEntryData>[
      for (final entry in _data.entries)
        if (_isEntryDirty(entry)) entry,
    ];
    if (dirtyEntries.isEmpty) {
      return true;
    }

    final currentEntry = _currentEntry;
    final savableEntries = [
      for (final entry in dirtyEntries)
        if ((entry.type == PendingOrganizeEntryType.photo &&
                _draftFor(entry).selectedElementId != null) ||
            (entry.type == PendingOrganizeEntryType.text &&
                _draftFor(entry).selectedChapterId != null))
          entry,
    ];
    if (savableEntries.isEmpty) {
      return true;
    }

    setState(() {
      _isSaving = true;
    });

    final preferredEntryId =
        currentEntry?.entryId ?? savableEntries.first.entryId;
    for (final entry in savableEntries) {
      final saved = await _saveEntryById(
        entry.entryId,
        preferredEntryId: preferredEntryId,
        manageSavingState: false,
      );
      if (!saved || !mounted) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
        return false;
      }
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      _isSaving = false;
    });
    return true;
  }

  Future<_PendingUnsavedAction?> _showPendingUnsavedChangesDialog() {
    return showDialog<_PendingUnsavedAction>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        '未 完 全 保 存',
                        key: ValueKey('pendingUnsavedDialogTitle'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      key: const ValueKey('pendingUnsavedDialogCloseButton'),
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(_PendingUnsavedAction.cancel),
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '×',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '当前仍有待整理内容修改未保存。你可以全部保存后退出，或直接返回并放弃本次未保存修改。',
                  key: const ValueKey('pendingUnsavedDialogContent'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 34),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const ValueKey(
                          'pendingUnsavedDialogSaveAllButton',
                        ),
                        onTap: () => Navigator.of(
                          dialogContext,
                        ).pop(_PendingUnsavedAction.saveAll),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(color: Colors.black),
                          alignment: Alignment.center,
                          child: const Text(
                            '全部保存',
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
                        key: const ValueKey(
                          'pendingUnsavedDialogDiscardButton',
                        ),
                        onTap: () => Navigator.of(
                          dialogContext,
                        ).pop(_PendingUnsavedAction.discard),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '仍然返回',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              letterSpacing: 1.6,
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
        backgroundColor: const Color(0xFFF7F7F9),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _data.entries.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          const SizedBox(height: 16),
                          _buildImageCarousel(),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildCurrentSections(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
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
            onPressed: _handleBackNavigation,
          ),
          const Text(
            '待整理',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.0,
              color: Colors.black87,
            ),
          ),
          TextButton(
            key: const ValueKey('pendingOrganizeSaveButton'),
            onPressed: _canSaveCurrentEntry ? _saveCurrentEntry : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isSaving ? '保存中' : '保存',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _canSaveCurrentEntry ? Colors.black87 : Colors.black26,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          '暂无待整理内容',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.4),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _data.entries.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final entry = _data.entries[index];
              return entry.type == PendingOrganizeEntryType.photo
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: Colors.black,
                      child: Image(
                        key: ValueKey('pendingPhoto-${entry.entryId}'),
                        image: narrativeThumbnailProvider(entry.imageSource!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'PHOTO',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 3.0,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: const Color(0xFF1F1F1F),
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        entry.body ?? '',
                        key: ValueKey('pendingTextCard-${entry.entryId}'),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                    );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_currentIndex + 1} / ${_data.entries.length}',
          key: const ValueKey('pendingOrganizePhotoCounter'),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2.0,
            color: Colors.black.withValues(alpha: 0.42),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSections() {
    final currentEntry = _currentEntry;
    if (currentEntry == null) {
      return const SizedBox.shrink();
    }
    final draft = _draftFor(currentEntry);
    final elements = _filteredElements(draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('关联章节'),
        const SizedBox(height: 14),
        _buildChapterSelector(draft),
        const SizedBox(height: 28),
        _buildSectionHeader('关联元素'),
        const SizedBox(height: 14),
        _buildElementList(elements, draft),
        const SizedBox(height: 28),
        _buildSectionHeader('关联关系'),
        const SizedBox(height: 14),
        _buildRelationTypeList(draft),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChapterSelector(_PendingEntryDraft draft) {
    final chapterOptions = <PendingOrganizeChapterOption>[
      const PendingOrganizeChapterOption(label: '未归属', sortOrder: -1),
      ..._data.chapters,
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chapterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final chapter = chapterOptions[index];
          final isActive = chapter.chapterId == draft.selectedChapterId;
          return GestureDetector(
            key: ValueKey('pendingChapterCard-${chapter.chapterId ?? 'none'}'),
            onTap: () => _selectChapter(chapter.chapterId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 172,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF222222)
                    : Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  _buildChapterThumb(
                    chapter.coverImageSource,
                    isActive: isActive,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chapter.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapterThumb(String? imageSource, {required bool isActive}) {
    final placeholder = Container(
      width: 64,
      height: 72,
      alignment: Alignment.center,
      color: isActive ? Colors.white10 : Colors.white,
      child: Text(
        'CH',
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 2.0,
          color: isActive ? Colors.white60 : Colors.black26,
        ),
      ),
    );

    if (imageSource == null || imageSource.trim().isEmpty) {
      return placeholder;
    }

    return Container(
      width: 64,
      height: 72,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isActive ? Colors.white10 : Colors.white,
      ),
      child: Image(
        image: ResizeImage.resizeIfNeeded(
          180,
          null,
          narrativeThumbnailProvider(imageSource),
        ),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }

  Widget _buildElementList(
    List<PendingOrganizeElementOption> elements,
    _PendingEntryDraft draft,
  ) {
    if (elements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 0.8),
        ),
        child: Text(
          '当前章节下暂无可挂接元素',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withValues(alpha: 0.42),
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final element in elements)
          _buildElementCard(
            element,
            isSelected: draft.selectedElementId == element.elementId,
          ),
      ],
    );
  }

  Widget _buildElementCard(
    PendingOrganizeElementOption element, {
    required bool isSelected,
  }) {
    return InkWell(
      key: ValueKey('pendingElementCard-${element.elementId}'),
      onTap: () => _selectElement(element.elementId),
      child: Container(
        key: ValueKey('pendingElementCardBody-${element.elementId}'),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF222222)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.chapterLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      color: isSelected
                          ? Colors.white54
                          : Colors.black.withValues(alpha: 0.34),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                  if (element.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      element.description,
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
            _buildElementThumbs(element.imageSources),
          ],
        ),
      ),
    );
  }

  Widget _buildElementThumbs(List<String> imageSources) {
    if (imageSources.isEmpty) {
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

    final hasMore = imageSources.length > 1;
    return SizedBox(
      width: hasMore ? 90 : 44,
      height: 44,
      child: Row(
        children: [
          _buildElementThumb(imageSources.first),
          if (hasMore)
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(left: 2),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(color: Color(0xFFF1F1F3)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildElementThumb(imageSources[1]),
                  Container(
                    alignment: Alignment.center,
                    color: Colors.white.withValues(alpha: 0.62),
                    child: Text(
                      '+${imageSources.length - 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElementThumb(String imageSource) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Image(
        image: ResizeImage.resizeIfNeeded(
          120,
          null,
          narrativeThumbnailProvider(imageSource),
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
              size: 16,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRelationTypeList(_PendingEntryDraft draft) {
    return Column(
      children: [
        for (final relationType in _data.relationTypes)
          _buildRelationTypeCard(relationType, draft),
      ],
    );
  }

  Widget _buildRelationTypeCard(
    PendingOrganizeRelationTypeOption relationType,
    _PendingEntryDraft draft,
  ) {
    final selectedCount = draft.selectedRelationGroupIds
        .where(
          (groupId) =>
              relationType.groups.any((group) => group.groupId == groupId),
        )
        .length;

    return InkWell(
      key: ValueKey('pendingRelationTypeCard-${relationType.relationTypeId}'),
      onTap: () => _openRelationTypeSelection(relationType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relationType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedCount > 0
                        ? '已选 $selectedCount 组'
                        : relationType.groups.isEmpty
                        ? '暂无关联组'
                        : '可选 ${relationType.groups.length} 组',
                    key: ValueKey(
                      'pendingRelationTypeCount-${relationType.relationTypeId}',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.42),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingEntryDraft {
  _PendingEntryDraft({
    required this.selectedChapterId,
    required this.selectedElementId,
    required this.selectedRelationGroupIds,
  });

  String? selectedChapterId;
  String? selectedElementId;
  Set<String> selectedRelationGroupIds;
}

enum _PendingUnsavedAction { saveAll, discard, cancel }
