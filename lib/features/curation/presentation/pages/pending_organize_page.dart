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
  final Map<String, _PendingPhotoDraft> _drafts =
      <String, _PendingPhotoDraft>{};

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

  PendingOrganizePhotoData? get _currentPhoto {
    if (_data.photos.isEmpty) {
      return null;
    }
    final safeIndex = _currentIndex.clamp(0, _data.photos.length - 1);
    return _data.photos[safeIndex];
  }

  _PendingPhotoDraft _draftFor(PendingOrganizePhotoData photo) {
    return _drafts.putIfAbsent(
      photo.photoId,
      () => _PendingPhotoDraft(
        selectedChapterId: photo.sourceChapterId,
        selectedElementId: photo.sourceElementId,
        selectedRelationGroupIds: <String>{...photo.sourceRelationGroupIds},
      ),
    );
  }

  bool _isPhotoDirty(PendingOrganizePhotoData photo) {
    final draft = _draftFor(photo);
    if (draft.selectedChapterId != photo.sourceChapterId) {
      return true;
    }
    if (draft.selectedElementId != photo.sourceElementId) {
      return true;
    }

    final initialGroupIds = photo.sourceRelationGroupIds.toSet();
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
    for (final photo in _data.photos) {
      if (_isPhotoDirty(photo)) {
        return true;
      }
    }
    return false;
  }

  bool get _canSaveCurrentPhoto {
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null || _isSaving) {
      return false;
    }
    final draft = _draftFor(currentPhoto);
    return draft.selectedElementId != null && _isPhotoDirty(currentPhoto);
  }

  List<PendingOrganizeElementOption> _filteredElements(
    _PendingPhotoDraft draft,
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
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null) {
      return;
    }
    final draft = _draftFor(currentPhoto);
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
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null) {
      return;
    }
    final draft = _draftFor(currentPhoto);
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
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null) {
      return;
    }
    final draft = _draftFor(currentPhoto);
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

  Future<void> _saveCurrentPhoto() async {
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null) {
      return;
    }
    await _savePhotoById(
      currentPhoto.photoId,
      preferredPhotoId: currentPhoto.photoId,
      manageSavingState: true,
    );
  }

  Future<bool> _savePhotoById(
    String photoId, {
    required String preferredPhotoId,
    required bool manageSavingState,
  }) async {
    PendingOrganizePhotoData? photo;
    for (final item in _data.photos) {
      if (item.photoId == photoId) {
        photo = item;
        break;
      }
    }
    if (photo == null) {
      return true;
    }

    final draft = _draftFor(photo);
    final targetElementId = draft.selectedElementId;
    if (targetElementId == null || !_isPhotoDirty(photo)) {
      return true;
    }

    if (manageSavingState) {
      setState(() {
        _isSaving = true;
      });
    }

    final previousIndex = _currentIndex;
    final updatedData = await widget.onSavePhoto(
      PendingOrganizeSaveRequest(
        photoId: photo.photoId,
        photoPath: photo.photoPath,
        sourceElementId: photo.sourceElementId,
        targetElementId: targetElementId,
        relationGroupIds: draft.selectedRelationGroupIds.toList(),
      ),
    );

    if (!mounted) {
      return false;
    }

    setState(() {
      _data = updatedData;
      _drafts.remove(photoId);
      _drafts.removeWhere(
        (draftPhotoId, _) =>
            !_data.photos.any((item) => item.photoId == draftPhotoId),
      );
      if (manageSavingState) {
        _isSaving = false;
      }
      _currentIndex = _resolvedPhotoIndex(
        preferredPhotoId: preferredPhotoId,
        previousIndex: previousIndex,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients || _data.photos.isEmpty) {
        return;
      }
      _pageController.jumpToPage(_currentIndex);
    });
    return true;
  }

  int _resolvedPhotoIndex({
    required String preferredPhotoId,
    required int previousIndex,
  }) {
    if (_data.photos.isEmpty) {
      return 0;
    }
    final updatedIndex = _data.photos.indexWhere(
      (photo) => photo.photoId == preferredPhotoId,
    );
    if (updatedIndex >= 0) {
      return updatedIndex;
    }
    return previousIndex.clamp(0, _data.photos.length - 1);
  }

  Future<bool> _saveAllDirtyPhotos() async {
    final dirtyPhotos = <PendingOrganizePhotoData>[
      for (final photo in _data.photos)
        if (_isPhotoDirty(photo)) photo,
    ];
    if (dirtyPhotos.isEmpty) {
      return true;
    }

    final currentPhoto = _currentPhoto;
    final savablePhotos = [
      for (final photo in dirtyPhotos)
        if (_draftFor(photo).selectedElementId != null) photo,
    ];
    if (savablePhotos.isEmpty) {
      return true;
    }

    setState(() {
      _isSaving = true;
    });

    final preferredPhotoId =
        currentPhoto?.photoId ?? savablePhotos.first.photoId;
    for (final photo in savablePhotos) {
      final saved = await _savePhotoById(
        photo.photoId,
        preferredPhotoId: preferredPhotoId,
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
                  '当前仍有照片修改未保存。你可以全部保存后退出，或直接返回并放弃本次未保存修改。',
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
                child: _data.photos.isEmpty
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
            onPressed: _canSaveCurrentPhoto ? _saveCurrentPhoto : null,
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
                color: _canSaveCurrentPhoto ? Colors.black87 : Colors.black26,
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
          '暂无待整理照片',
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
            itemCount: _data.photos.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final photo = _data.photos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.black,
                child: Image(
                  key: ValueKey('pendingPhoto-${photo.photoId}'),
                  image: narrativeThumbnailProvider(photo.imageSource),
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
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_currentIndex + 1} / ${_data.photos.length}',
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
    final currentPhoto = _currentPhoto;
    if (currentPhoto == null) {
      return const SizedBox.shrink();
    }
    final draft = _draftFor(currentPhoto);
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

  Widget _buildChapterSelector(_PendingPhotoDraft draft) {
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
    _PendingPhotoDraft draft,
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

  Widget _buildRelationTypeList(_PendingPhotoDraft draft) {
    return Column(
      children: [
        for (final relationType in _data.relationTypes)
          _buildRelationTypeCard(relationType, draft),
      ],
    );
  }

  Widget _buildRelationTypeCard(
    PendingOrganizeRelationTypeOption relationType,
    _PendingPhotoDraft draft,
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

class _PendingPhotoDraft {
  _PendingPhotoDraft({
    required this.selectedChapterId,
    required this.selectedElementId,
    required this.selectedRelationGroupIds,
  });

  String? selectedChapterId;
  String? selectedElementId;
  Set<String> selectedRelationGroupIds;
}

enum _PendingUnsavedAction { saveAll, discard, cancel }
