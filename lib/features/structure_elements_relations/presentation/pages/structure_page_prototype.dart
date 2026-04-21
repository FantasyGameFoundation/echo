import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_chapter_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_relation_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/chapter_card.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_list_tile.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/relation_card.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/section_tab_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/sticky_chapter_header_delegate.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class StructurePagePrototype extends StatefulWidget {
  const StructurePagePrototype({
    super.key,
    required this.currentTabIndex,
    required this.chapterCards,
    required this.elementGroups,
    required this.relationCards,
    this.projectTitle = '',
    required this.onOpenSidebar,
    required this.onAddChapter,
    this.onOpenChapter,
    required this.onAddElement,
    this.onOpenElement,
    required this.onAddRelation,
    this.onOpenRelation,
    required this.onTabChanged,
    required this.onBottomTabChanged,
  });

  final int currentTabIndex;
  final List<StructureChapterCardData> chapterCards;
  final List<Map<String, dynamic>> elementGroups;
  final List<StructureRelationCardData> relationCards;
  final String projectTitle;
  final VoidCallback onOpenSidebar;
  final VoidCallback onAddChapter;
  final ValueChanged<int>? onOpenChapter;
  final VoidCallback onAddElement;
  final ValueChanged<String>? onOpenElement;
  final VoidCallback onAddRelation;
  final ValueChanged<int>? onOpenRelation;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  State<StructurePagePrototype> createState() => _StructurePagePrototypeState();
}

enum _ElementFilter { all, finding, ready }

class _StructurePagePrototypeState extends State<StructurePagePrototype> {
  _ElementFilter _activeElementFilter = _ElementFilter.all;

  int get _findingElementCount => _countElementsByStatus(ElementStatus.finding);

  int get _readyElementCount => _countElementsByStatus(ElementStatus.ready);

  int _countElementsByStatus(ElementStatus status) {
    var count = 0;
    for (final group in widget.elementGroups) {
      final elements = group['elements'];
      if (elements is! List) {
        continue;
      }
      for (final element in elements) {
        if (element is Map<String, dynamic> && element['status'] == status) {
          count += 1;
        }
      }
    }
    return count;
  }

  List<Map<String, dynamic>> get _visibleElementGroups {
    if (_activeElementFilter == _ElementFilter.all) {
      return widget.elementGroups;
    }

    final targetStatus = switch (_activeElementFilter) {
      _ElementFilter.finding => ElementStatus.finding,
      _ElementFilter.ready => ElementStatus.ready,
      _ElementFilter.all => null,
    };

    if (targetStatus == null) {
      return widget.elementGroups;
    }

    final visibleGroups = <Map<String, dynamic>>[];
    for (final group in widget.elementGroups) {
      final elements = group['elements'];
      if (elements is! List) {
        continue;
      }
      final filteredElements = elements.where((element) {
        return element is Map<String, dynamic> &&
            element['status'] == targetStatus;
      }).toList();
      if (filteredElements.isEmpty) {
        continue;
      }
      visibleGroups.add(<String, dynamic>{
        ...group,
        'elements': filteredElements,
      });
    }
    return visibleGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SectionTabBar(
                  selectedIndex: widget.currentTabIndex,
                  onTabChanged: widget.onTabChanged,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildCurrentSection()),
            CustomBottomNavBar(
              activeTab: PrototypeTab.structure,
              onChangeTab: widget.onBottomTabChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (widget.currentTabIndex) {
      case 0:
        return _buildChaptersView();
      case 1:
        return _buildElementsView();
      case 2:
        return _buildRelationsView();
      default:
        return _buildChaptersView();
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: widget.onOpenSidebar,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                widget.projectTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4.0,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        for (var index = 0; index < widget.chapterCards.length; index++)
          ChapterCard(
            chapterNumber: widget.chapterCards[index].chapterNumber,
            title: widget.chapterCards[index].title,
            elementCount: widget.chapterCards[index].elementCount.toString(),
            onTap: widget.onOpenChapter == null
                ? null
                : () => widget.onOpenChapter!(index),
            extraTopRightWidget: _buildStatusIndicator(
              widget.chapterCards[index].statusLabel,
            ),
            customContent:
                widget.chapterCards[index].previewImageSources.isEmpty
                ? _buildDescriptionText(widget.chapterCards[index].description)
                : _buildChapterPhotoStrip(
                    widget.chapterCards[index].previewImageSources,
                  ),
          ),
        _buildAddChapterButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildElementsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              _buildFilterTab(
                '全部',
                isActive: _activeElementFilter == _ElementFilter.all,
                onTap: () => _setElementFilter(_ElementFilter.all),
              ),
              const SizedBox(width: 24),
              _buildFilterTab(
                '寻找中 ($_findingElementCount)',
                isActive: _activeElementFilter == _ElementFilter.finding,
                onTap: () => _setElementFilter(_ElementFilter.finding),
              ),
              const SizedBox(width: 24),
              _buildFilterTab(
                '已就绪 ($_readyElementCount)',
                isActive: _activeElementFilter == _ElementFilter.ready,
                onTap: () => _setElementFilter(_ElementFilter.ready),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: CustomScrollView(
            slivers: [
              for (final group in _visibleElementGroups) ...[
                SliverPersistentHeader(
                  pinned: false,
                  delegate: StickyChapterHeaderDelegate(
                    title: group['chapter'],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = group['elements'][index];
                    return NarrativeListTile(
                      title: item['title'],
                      description: item['desc'],
                      status: item['status'],
                      images: item['images'],
                      onTap: widget.onOpenElement == null
                          ? null
                          : () => widget.onOpenElement!(item['id'] as String),
                    );
                  }, childCount: group['elements'].length),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: _buildAddElementButton(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationsView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        for (final relation in widget.relationCards)
          RelationCard(
            name: relation.name,
            description: relation.description,
            setCount: relation.setCount,
            onTap: widget.onOpenRelation == null
                ? null
                : () => widget.onOpenRelation!(
                    widget.relationCards.indexOf(relation),
                  ),
          ),
        _buildAddRelationButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  void _setElementFilter(_ElementFilter filter) {
    if (_activeElementFilter == filter) {
      return;
    }
    setState(() {
      _activeElementFilter = filter;
    });
  }

  Widget _buildFilterTab(
    String title, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF333333) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF333333) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildAddElementButton() {
    return InkWell(
      onTap: widget.onAddElement,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              '添加叙事元素',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('状态', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        Text(
          status,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText(String text, {bool isItalic = false}) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.6,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  Widget _buildChapterPhotoStrip(List<String> previewImageSources) {
    final totalCount = previewImageSources.length;
    final visibleImages = totalCount > 2
        ? previewImageSources.take(2).toList()
        : previewImageSources.take(2).toList();
    final overflowCount = totalCount > 2 ? totalCount - 2 : 0;
    final tileCount = visibleImages.length + (overflowCount > 0 ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = tileCount > 0 ? (tileCount - 1) * 2.0 : 0.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 244.0;
        final tileSize = tileCount == 0
            ? 80.0
            : ((availableWidth - totalSpacing) / tileCount).clamp(56.0, 80.0);

        return Row(
          children: [
            for (var index = 0; index < visibleImages.length; index++)
              _buildChapterPreviewImage(
                visibleImages[index],
                size: tileSize,
                addLeftSpacing: index > 0,
              ),
            if (overflowCount > 0)
              _buildChapterOverflowBox(
                '+$overflowCount',
                size: tileSize,
                addLeftSpacing: visibleImages.isNotEmpty,
              ),
          ],
        );
      },
    );
  }

  Widget _buildChapterPreviewImage(
    String source, {
    required double size,
    required bool addLeftSpacing,
  }) {
    return Container(
      key: ValueKey('chapterPreviewImage-$source'),
      width: size,
      height: size,
      margin: EdgeInsets.only(left: addLeftSpacing ? 2 : 0),
      child: Image(
        image: ResizeImage.resizeIfNeeded(
          160,
          null,
          narrativeThumbnailProvider(source),
        ),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey.shade300);
        },
      ),
    );
  }

  Widget _buildChapterOverflowBox(
    String text, {
    required double size,
    required bool addLeftSpacing,
  }) {
    return Container(
      key: ValueKey('chapterPreviewOverflow-$text'),
      width: size,
      height: size,
      margin: EdgeInsets.only(left: addLeftSpacing ? 2 : 0),
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildAddChapterButton() {
    return InkWell(
      onTap: widget.onAddChapter,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              '添加章节',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddRelationButton() {
    return InkWell(
      onTap: widget.onAddRelation,
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 8),
            Text(
              '添加关联关系',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
