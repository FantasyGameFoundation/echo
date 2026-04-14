import 'dart:ui';

import 'package:flutter/material.dart';

const _stablePhotoA = 'https://picsum.photos/seed/echo-structure-a/400/400?grayscale';
const _stablePhotoB = 'https://picsum.photos/seed/echo-structure-b/400/400?grayscale';
const _stablePhotoC = 'https://picsum.photos/seed/echo-structure-c/400/400?grayscale';
const _stablePhotoD = 'https://picsum.photos/seed/echo-structure-d/400/400?grayscale';
const _stablePhotoE = 'https://picsum.photos/seed/echo-structure-e/400/400?grayscale';

enum PrototypeTab {
  structure,
  curation,
  add,
  overview,
  timeline,
}

class PrototypeShellPage extends StatefulWidget {
  const PrototypeShellPage({super.key});

  @override
  State<PrototypeShellPage> createState() => _PrototypeShellPageState();
}

class _PrototypeShellPageState extends State<PrototypeShellPage> {
  PrototypeTab _currentTab = PrototypeTab.structure;
  bool _sidebarOpen = false;
  int _currentTabIndex = 0;

  final List<Map<String, dynamic>> _chapterElements = [
    {
      'chapter': 'C H A P T E R  0 1  /  晨曦之眼',
      'elements': [
        {
          'title': '江边的空酒瓶',
          'desc': '捕捉清晨薄雾中，人造物与自然边界的冲突。',
          'status': ElementStatus.finding,
          'images': [
            _stablePhotoA,
            _stablePhotoB,
            _stablePhotoC,
            _stablePhotoD,
          ],
        },
        {
          'title': '孤独的电线杆',
          'desc': '黄昏时分，切割天空的几何线条。',
          'status': ElementStatus.finding,
          'images': <String>[],
        },
      ],
    },
    {
      'chapter': 'C H A P T E R  0 2  /  众神之后',
      'elements': [
        {
          'title': '某种醉态',
          'desc': '体现人物与环境的疏离感，而非酒精的狂热。',
          'status': ElementStatus.ready,
          'images': [
            _stablePhotoB,
            _stablePhotoD,
            _stablePhotoE,
          ],
        },
        {
          'title': '斑驳的树影',
          'desc': '工业废墟中唯一的生机暗示。',
          'status': ElementStatus.ready,
          'images': [
            _stablePhotoC,
            _stablePhotoA,
          ],
        },
      ],
    },
    {
      'chapter': 'C H A P T E R  0 3  /  呼吸感',
      'elements': [
        {
          'title': '江边的围网',
          'desc': '被遗弃的秩序感，纠缠的线条暗示束缚。',
          'status': ElementStatus.ready,
          'images': [
            _stablePhotoD,
          ],
        },
        {
          'title': '留白的天空',
          'desc': '大面积低饱和度冷灰，压抑情绪的释放口。',
          'status': ElementStatus.finding,
          'images': <String>[],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentPage(),
          if (_sidebarOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _sidebarOpen = false),
                child: Container(color: Colors.black.withValues(alpha: 0.18)),
              ),
            ),
            const Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: ProjectSidebar(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentTab) {
      case PrototypeTab.structure:
        return StructurePagePrototype(
          currentTabIndex: _currentTabIndex,
          chapterElements: _chapterElements,
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onTabChanged: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.add:
        return QuickRecordOverlayPrototype(
          onClose: () => setState(() => _currentTab = PrototypeTab.structure),
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.curation:
        return PlaceholderPrototypePage(
          title: '整 理',
          icon: Icons.filter_list,
          activeTab: PrototypeTab.curation,
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.overview:
        return PlaceholderPrototypePage(
          title: '概 览',
          icon: Icons.remove_red_eye_outlined,
          activeTab: PrototypeTab.overview,
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.timeline:
        return PlaceholderPrototypePage(
          title: '历 程',
          icon: Icons.show_chart,
          activeTab: PrototypeTab.timeline,
          onBottomTabChanged: _changeTab,
        );
    }
  }

  void _changeTab(PrototypeTab tab) {
    setState(() {
      _currentTab = tab;
      if (tab != PrototypeTab.structure) {
        _sidebarOpen = false;
      }
    });
  }
}

class ProjectSidebar extends StatelessWidget {
  const ProjectSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 64, bottom: 48),
            child: Row(
              children: [
                const Icon(Icons.photo_library, size: 28, color: Colors.black87),
                const SizedBox(width: 12),
                const Text(
                  '项目中心',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          _buildSectionTitle('活 跃 项 目'),
          _buildNavItem(title: '赤水河沿岸寻访', isSelected: true),
          _buildNavItem(title: '建筑的沉默'),
          const SizedBox(height: 32),
          _buildSectionTitle('草 稿 箱'),
          _buildNavItem(title: '无名系列 01'),
          const SizedBox(height: 32),
          _buildSectionTitle('管 理'),
          _buildNavItem(title: '已归档', icon: Icons.archive_outlined),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      '新建项目',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    bool isSelected = false,
    IconData? icon,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDEE3E5) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected ? const Color(0xFF4A4A4A) : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (icon != null)
            Positioned(
              left: 24,
              child: Icon(icon, size: 20, color: const Color(0xFF555555)),
            ),
          Positioned(
            left: icon != null ? 60 : 24,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StructurePagePrototype extends StatelessWidget {
  const StructurePagePrototype({
    super.key,
    required this.currentTabIndex,
    required this.chapterElements,
    required this.onOpenSidebar,
    required this.onTabChanged,
    required this.onBottomTabChanged,
  });

  final int currentTabIndex;
  final List<Map<String, dynamic>> chapterElements;
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
          const Text(
            '赤水河沿岸寻访',
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
          customContent: Row(
            children: [
              _buildNetworkImage(
                _stablePhotoA,
                width: 80,
                height: 80,
              ),
              _buildNetworkImage(
                _stablePhotoB,
                width: 80,
                height: 80,
              ),
              _buildPlaceholderBox('+12'),
            ],
          ),
        ),
        ChapterCard(
          chapterNumber: '02',
          title: '众神之后：废弃工业区的色彩',
          elementCount: '8',
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
          customContent: Row(
            children: [
              _buildNetworkImage(
                _stablePhotoC,
                width: 80,
                height: 80,
              ),
              _buildNetworkImage(
                _stablePhotoD,
                width: 80,
                height: 80,
              ),
              _buildPlaceholderBox('+1'),
            ],
          ),
        ),
        ChapterCard(
          chapterNumber: '04',
          title: '阴影的重量',
          elementCount: '11',
          extraTopRightWidget: _buildStatusIndicator('修订中'),
          customContent: Row(
            children: [
              _buildNetworkImage(
                _stablePhotoE,
                width: 80,
                height: 80,
              ),
              _buildNetworkImage(
                _stablePhotoA,
                width: 80,
                height: 80,
              ),
              _buildPlaceholderBox('+9'),
            ],
          ),
        ),
        ChapterCard(
          chapterNumber: '05',
          title: '最后的凝视：记忆中的地标',
          elementCount: '5',
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
          customContent: Row(
            children: [
              _buildNetworkImage(
                _stablePhotoB,
                width: 80,
                height: 80,
              ),
              _buildNetworkImage(
                _stablePhotoC,
                width: 80,
                height: 80,
              ),
              _buildPlaceholderBox('+8'),
            ],
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
                  pinned: true,
                  delegate: _StickyChapterHeaderDelegate(title: group['chapter']),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = group['elements'][index];
                      return NarrativeListTile(
                        title: item['title'],
                        description: item['desc'],
                        status: item['status'],
                        images: item['images'],
                      );
                    },
                    childCount: group['elements'].length,
                  ),
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
        Text(
          '状态',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
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
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.6,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  Widget _buildNetworkImage(
    String url, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 2),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        cacheWidth: 240,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _PhotoFallbackTile(size: 80);
        },
        errorBuilder: (context, error, stackTrace) =>
            const _PhotoFallbackTile(size: 80),
      ),
    );
  }

  Widget _buildPlaceholderBox(String text) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

class QuickRecordOverlayPrototype extends StatelessWidget {
  const QuickRecordOverlayPrototype({
    super.key,
    required this.onClose,
    required this.onBottomTabChanged,
  });

  final VoidCallback onClose;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Current Project',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GALLERY CURATED / STUDIO V',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            bottom: 80,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      top: 20.0,
                      bottom: 20.0,
                      right: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '上海·静安',
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '2024.05.24 14:32:01',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: onClose,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '在此输入文字速记...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {},
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 24,
                                  color: Color(0xFF555555),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '拍摄',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        Expanded(
                          child: InkWell(
                            onTap: () {},
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 24,
                                  color: Color(0xFF555555),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '相册',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      color: const Color(0xFF5A5A5A),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '保 存 记 录',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 4.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(
              activeTab: PrototypeTab.add,
              onChangeTab: onBottomTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPrototypePage extends StatelessWidget {
  const PlaceholderPrototypePage({
    super.key,
    required this.title,
    required this.icon,
    required this.activeTab,
    required this.onBottomTabChanged,
  });

  final String title;
  final IconData icon;
  final PrototypeTab activeTab;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Icon(icon, size: 56, color: Colors.black26),
              ),
            ),
            CustomBottomNavBar(
              activeTab: activeTab,
              onChangeTab: onBottomTabChanged,
            ),
          ],
        ),
      ),
    );
  }
}

enum ElementStatus { finding, ready }

class NarrativeListTile extends StatelessWidget {
  const NarrativeListTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.images = const <String>[],
  });

  final String title;
  final String description;
  final ElementStatus status;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAssociatedThumbnails(),
          const SizedBox(width: 16),
          if (status == ElementStatus.ready)
            const Icon(Icons.check, color: Colors.black87, size: 20)
          else
            const SizedBox(width: 20, height: 20),
        ],
      ),
    );
  }

  Widget _buildAssociatedThumbnails() {
    if (images.isEmpty) return const SizedBox.shrink();

    const thumbSize = 44.0;
    const thinSpacing = 2.0;
    final hasMore = images.length > 1;
    final previewImage = images.first;

    return SizedBox(
      width: hasMore ? 90 : 44,
      height: thumbSize,
      child: Row(
        children: [
          _buildNetworkThumb(previewImage, size: thumbSize),
          if (hasMore)
            Container(
              width: thumbSize,
              height: thumbSize,
              margin: const EdgeInsets.only(left: thinSpacing),
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Text(
                '+${images.length - 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkThumb(String url, {required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        cacheWidth: 120,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _PhotoFallbackTile(size: 44);
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const _PhotoFallbackTile(size: 44),
        ),
      ),
    );
  }
}

class _PhotoFallbackTile extends StatelessWidget {
  const _PhotoFallbackTile({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFD4D4D4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: size * 0.10,
            right: size * 0.52,
            bottom: size * 0.08,
            child: Container(color: const Color(0xFF6B6B6B)),
          ),
          Positioned(
            left: size * 0.38,
            right: size * 0.20,
            bottom: size * 0.08,
            child: Container(color: const Color(0xFF4F4F4F)),
          ),
          Positioned(
            left: size * 0.62,
            right: size * 0.06,
            bottom: size * 0.08,
            child: Container(color: const Color(0xFF8A8A8A)),
          ),
          Positioned(
            left: size * 0.08,
            right: size * 0.04,
            top: size * 0.12,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            left: size * 0.46,
            top: size * 0.02,
            bottom: size * 0.08,
            child: Transform.rotate(
              angle: -0.65,
              child: Container(
                width: size * 0.02,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyChapterHeaderDelegate({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF7F7F9),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade500,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40.0;

  @override
  double get minExtent => 40.0;

  @override
  bool shouldRebuild(covariant _StickyChapterHeaderDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}

class SectionTabBar extends StatelessWidget {
  const SectionTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTab(0, '章节骨架'),
        const SizedBox(width: 32),
        _buildTab(1, '叙事元素'),
      ],
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF333333) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 1.2,
            color: isSelected ? const Color(0xFF333333) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.elementCount,
    required this.customContent,
    this.extraTopRightWidget,
  });

  final String chapterNumber;
  final String title;
  final String elementCount;
  final Widget customContent;
  final Widget? extraTopRightWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'C H A P T E R  $chapterNumber',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  letterSpacing: 2.0,
                ),
              ),
              if (extraTopRightWidget != null) ...[
                extraTopRightWidget!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ClipRect(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: customContent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '关联元素',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    elementCount,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onChangeTab,
  });

  final PrototypeTab activeTab;
  final ValueChanged<PrototypeTab> onChangeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: activeTab == PrototypeTab.add
            ? const Color(0xFFF7F7F9)
            : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(
            Icons.grid_view_rounded,
            '结构',
            isActive: activeTab == PrototypeTab.structure,
            onTap: () => onChangeTab(PrototypeTab.structure),
          ),
          _buildNavItem(
            Icons.filter_list,
            '整理',
            isActive: activeTab == PrototypeTab.curation,
            onTap: () => onChangeTab(PrototypeTab.curation),
          ),
          InkWell(
            onTap: () => onChangeTab(PrototypeTab.add),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF5A5A5A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          _buildNavItem(
            Icons.remove_red_eye_outlined,
            '概览',
            isActive: activeTab == PrototypeTab.overview,
            onTap: () => onChangeTab(PrototypeTab.overview),
          ),
          _buildNavItem(
            Icons.show_chart,
            '历程',
            isActive: activeTab == PrototypeTab.timeline,
            onTap: () => onChangeTab(PrototypeTab.timeline),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.black87 : Colors.grey.shade400;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
