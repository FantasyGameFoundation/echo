import 'dart:math' as math;

import 'package:echo/features/structure_elements_relations/presentation/widgets/chapter_card.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_list_tile.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/photo_fallback_tile.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/section_tab_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/sticky_chapter_header_delegate.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class StructurePagePrototype extends StatelessWidget {
  const StructurePagePrototype({
    super.key,
    required this.currentTabIndex,
    required this.chapterElements,
    this.projectTitle = '赤水河沿岸寻访',
    required this.onOpenSidebar,
    required this.onTabChanged,
    required this.onBottomTabChanged,
  });

  final int currentTabIndex;
  final List<Map<String, dynamic>> chapterElements;
  final String projectTitle;
  final VoidCallback onOpenSidebar;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

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
                  selectedIndex: currentTabIndex,
                  onTabChanged: onTabChanged,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: currentTabIndex == 0
                  ? _buildChaptersView()
                  : _buildElementsView(),
            ),
            CustomBottomNavBar(
              activeTab: PrototypeTab.structure,
              onChangeTab: onBottomTabChanged,
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
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: onOpenSidebar,
          ),
          Text(
            projectTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 4.0,
              color: Colors.black87,
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
        ChapterCard(
          chapterNumber: '01',
          title: '晨曦之眼：城市边缘的静谧',
          elementCount: '14',
          extraTopRightWidget: _buildStatusIndicator('草稿'),
          customContent: _buildResponsiveChapterPreview(
            imageUrls: const [_stablePhotoA, _stablePhotoB],
            overflowText: '+12',
          ),
        ),
        ChapterCard(
          chapterNumber: '02',
          title: '众神之后：废弃工业区的色彩',
          elementCount: '8',
          isTextOnly: true,
          extraTopRightWidget: _buildStatusIndicator('进行中'),
          customContent: _buildDescriptionText(
            '专注于废弃工厂内部的金属质感与锈迹色彩，捕捉工业遗址在自然侵蚀下的独特美感。',
          ),
        ),
        ChapterCard(
          chapterNumber: '03',
          title: '呼吸感：极简构图与留白艺术',
          elementCount: '3',
          extraTopRightWidget: _buildStatusIndicator('待审核'),
          customContent: _buildResponsiveChapterPreview(
            imageUrls: const [_stablePhotoC, _stablePhotoD],
            overflowText: '+1',
          ),
        ),
        ChapterCard(
          chapterNumber: '04',
          title: '阴影的重量',
          elementCount: '11',
          extraTopRightWidget: _buildStatusIndicator('修订中'),
          customContent: _buildResponsiveChapterPreview(
            imageUrls: const [_stablePhotoE, _stablePhotoA],
            overflowText: '+9',
          ),
        ),
        ChapterCard(
          chapterNumber: '05',
          title: '最后的凝视：记忆中的地标',
          elementCount: '5',
          isTextOnly: true,
          extraTopRightWidget: _buildStatusIndicator('已排版'),
          customContent: _buildDescriptionText(
            '对核心建筑物的最终审视，结合黄昏时刻的暖色调，为整个系列画上句号。',
          ),
        ),
        ChapterCard(
          chapterNumber: '06',
          title: '光影的旋律：结构与节奏',
          elementCount: '10',
          extraTopRightWidget: _buildStatusIndicator('待发布'),
          customContent: _buildResponsiveChapterPreview(
            imageUrls: const [_stablePhotoB, _stablePhotoC],
            overflowText: '+8',
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
              _buildFilterTab('全部', isActive: true),
              const SizedBox(width: 24),
              _buildFilterTab('寻找中 (12)', isActive: false),
              const SizedBox(width: 24),
              _buildFilterTab('已就绪 (5)', isActive: false),
              const Spacer(),
              const Icon(Icons.search, color: Colors.black87, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: CustomScrollView(
            slivers: [
              for (final group in chapterElements) ...[
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

  Widget _buildFilterTab(String title, {required bool isActive}) {
    return Container(
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
    );
  }

  Widget _buildAddElementButton() {
    return Container(
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

  Widget _buildResponsiveChapterPreview({
    required List<String> imageUrls,
    required String overflowText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final boxSize = math.min(80.0, (constraints.maxWidth - (gap * 2)) / 3);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChapterPreviewImage(imageUrls[0], boxSize),
            const SizedBox(width: gap),
            _buildChapterPreviewImage(imageUrls[1], boxSize),
            const SizedBox(width: gap),
            _buildChapterPreviewPlaceholder(overflowText, boxSize),
          ],
        );
      },
    );
  }

  Widget _buildChapterPreviewImage(String url, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        cacheWidth: 240,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return PhotoFallbackTile(size: size);
        },
        errorBuilder: (context, error, stackTrace) =>
            PhotoFallbackTile(size: size),
      ),
    );
  }

  Widget _buildChapterPreviewPlaceholder(String text, double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: size * 0.18),
      ),
    );
  }

  Widget _buildAddChapterButton() {
    return Container(
      height: 80,
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
            '添加新章节',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

const _stablePhotoA =
    'https://picsum.photos/seed/echo-structure-a/400/400?grayscale';
const _stablePhotoB =
    'https://picsum.photos/seed/echo-structure-b/400/400?grayscale';
const _stablePhotoC =
    'https://picsum.photos/seed/echo-structure-c/400/400?grayscale';
const _stablePhotoD =
    'https://picsum.photos/seed/echo-structure-d/400/400?grayscale';
const _stablePhotoE =
    'https://picsum.photos/seed/echo-structure-e/400/400?grayscale';
