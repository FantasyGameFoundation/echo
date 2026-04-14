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

const ColorFilter _greyscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

class PrototypeShellPage extends StatefulWidget {
  const PrototypeShellPage({super.key});

  @override
  State<PrototypeShellPage> createState() => _PrototypeShellPageState();
}

class _PrototypeShellPageState extends State<PrototypeShellPage> {
  PrototypeTab _currentTab = PrototypeTab.structure;
  bool _sidebarOpen = false;
  bool _showAddOverlay = false;
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
    return PopScope(
      canPop: !_showAddOverlay,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAddOverlay) {
          setState(() {
            _showAddOverlay = false;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildCurrentPage(),
            if (_showAddOverlay) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 20,
                right: 20,
                bottom: 80,
                child: QuickRecordOverlayPrototype(
                  onClose: () => setState(() => _showAddOverlay = false),
                  onBottomTabChanged: (_) {},
                ),
              ),
            ],
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
      case PrototypeTab.curation:
        return OrganizePagePrototype(
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
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
    if (tab == PrototypeTab.add) {
      setState(() {
        _showAddOverlay = true;
        _sidebarOpen = false;
      });
      return;
    }

    setState(() {
      _currentTab = tab;
      _sidebarOpen = false;
      _showAddOverlay = false;
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
                  pinned: false,
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
    return Container(
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
    );
  }
}

class OrganizePagePrototype extends StatefulWidget {
  const OrganizePagePrototype({
    super.key,
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
  });

  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  State<OrganizePagePrototype> createState() => _OrganizePagePrototypeState();
}

class _OrganizePagePrototypeState extends State<OrganizePagePrototype> {
  String _selectedChapter = '未归属';
  final Set<String> _selectedElements = {'某种醉态'};
  final Map<String, String?> _selectedRelationPhotos = {
    '呼应': null,
    '对比': null,
    '重复': null,
    '转折': null,
  };
  final Map<String, int> _relationCounts = {
    '呼应': 3,
    '对比': 1,
    '重复': 2,
    '转折': 0,
  };

  final List<String> _previewImages = [
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
    'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?w=800',
    'https://images.unsplash.com/photo-1496307653780-42ee777d4833?w=800',
  ];

  final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  const SizedBox(height: 16),
                  _buildImageCarousel(),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('关联章节'),
                        const SizedBox(height: 16),
                        _buildChapterCardSelector(
                          activeItem: _selectedChapter,
                          onSelected: (val) => setState(() => _selectedChapter = val),
                        ),
                        const SizedBox(height: 40),
                        _buildSectionHeader('关联元素', showSearch: true),
                        const SizedBox(height: 16),
                        _buildTagGroup(
                          items: const [
                            '江边的空酒瓶',
                            '某种醉态',
                            '水面的漂浮物',
                            '迷茫的眼神',
                            '赤红的泥土',
                            '斑驳的树影',
                          ],
                          activeItems: _selectedElements,
                          onToggle: (val) {
                            setState(() {
                              if (_selectedElements.contains(val)) {
                                _selectedElements.remove(val);
                              } else {
                                _selectedElements.add(val);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 40),
                        _buildSectionHeader('关联关系', showSearch: true),
                        const SizedBox(height: 16),
                        _buildRelationActionGroup(
                          items: const ['呼应', '对比', '重复', '转折'],
                          selectedPhotos: _selectedRelationPhotos,
                          relationCounts: _relationCounts,
                          onTapRelation: _openRelationPhotoPicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomBottomNavBar(
              activeTab: PrototypeTab.curation,
              onChangeTab: widget.onBottomTabChanged,
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
            onPressed: widget.onOpenSidebar,
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

  Widget _buildImageCarousel() {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _previewImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.black,
            child: ColorFiltered(
              colorFilter: _greyscaleFilter,
              child: Image.network(
                _previewImages[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSearch = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Colors.black87,
          ),
        ),
        if (showSearch)
          const Icon(Icons.search, color: Colors.black54, size: 20),
      ],
    );
  }

  Widget _buildChapterCardSelector({
    required String activeItem,
    required ValueChanged<String> onSelected,
  }) {
    final chapterItems = <Map<String, String?>>[
      {
        'title': '未归属',
        'image': null,
      },
      {
        'title': '01 / 晨曦之眼',
        'image': _previewImages[0],
      },
      {
        'title': '02 / 众神之后',
        'image': _previewImages[1],
      },
      {
        'title': '03 / 呼吸感',
        'image': _previewImages[2],
      },
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chapterItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = chapterItems[index];
          final title = item['title']!;
          final image = item['image'];
          final isActive = title == activeItem;

          return GestureDetector(
            onTap: () => onSelected(title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 172,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF222222) : Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  _buildChapterCardThumb(image, isActive: isActive),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        letterSpacing: 0.8,
                        height: 1.25,
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

  Widget _buildChapterCardThumb(String? image, {required bool isActive}) {
    if (image == null) {
      return Container(
        width: 52,
        height: 52,
        color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.grey.shade300,
        child: const Icon(Icons.grid_view_rounded, size: 20, color: Colors.white70),
      );
    }

    return SizedBox(
      width: 52,
      height: 52,
      child: ColorFiltered(
        colorFilter: _greyscaleFilter,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTagGroup({
    required List<String> items,
    required Set<String> activeItems,
    required ValueChanged<String> onToggle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            final isActive = activeItems.contains(item);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF222222) : Colors.grey.shade200,
                ),
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRelationActionGroup({
    required List<String> items,
    required Map<String, String?> selectedPhotos,
    required Map<String, int> relationCounts,
    required ValueChanged<String> onTapRelation,
  }) {
    return Column(
      children: items.map((item) {
        final count = relationCounts[item] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onTapRelation(item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    '已关联$count',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openRelationPhotoPicker(String relation) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RelationPhotoPickerPage(
          relation: relation,
          photos: _previewImages,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedRelationPhotos[relation] = selected;
      });
    }
  }
}

class RelationPhotoPickerPage extends StatefulWidget {
  const RelationPhotoPickerPage({
    super.key,
    required this.relation,
    required this.photos,
  });

  final String relation;
  final List<String> photos;

  @override
  State<RelationPhotoPickerPage> createState() => _RelationPhotoPickerPageState();
}

class _RelationPhotoPickerPageState extends State<RelationPhotoPickerPage> {
  String _search = '';
  String _activeFilter = '全部';

  @override
  Widget build(BuildContext context) {
    final photoItems = widget.photos
        .asMap()
        .entries
        .map(
          (entry) => (
            label: '照片 ${entry.key + 1}',
            url: entry.value,
            category: entry.key.isEven ? '场景' : '人物',
          ),
        )
        .where((item) {
          final searchMatch = _search.isEmpty || item.label.contains(_search);
          final filterMatch = _activeFilter == '全部' || item.category == _activeFilter;
          return searchMatch && filterMatch;
        })
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        title: Text('选择${widget.relation}照片'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: '搜索照片',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _PickerFilterChip(
                  label: '全部',
                  selected: _activeFilter == '全部',
                  onTap: () => setState(() => _activeFilter = '全部'),
                ),
                const SizedBox(width: 12),
                _PickerFilterChip(
                  label: '场景',
                  selected: _activeFilter == '场景',
                  onTap: () => setState(() => _activeFilter = '场景'),
                ),
                const SizedBox(width: 12),
                _PickerFilterChip(
                  label: '人物',
                  selected: _activeFilter == '人物',
                  onTap: () => setState(() => _activeFilter = '人物'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: photoItems.length,
                itemBuilder: (context, index) {
                  final item = photoItems[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(item.url),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              item.url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              item.label,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerFilterChip extends StatelessWidget {
  const _PickerFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: selected ? const Color(0xFF222222) : Colors.grey.shade200,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
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
    this.isTextOnly = false,
    this.extraTopRightWidget,
  });

  final String chapterNumber;
  final String title;
  final String elementCount;
  final Widget customContent;
  final bool isTextOnly;
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
          SizedBox(height: isTextOnly ? 18 : 24),
          Row(
            crossAxisAlignment:
                isTextOnly ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: isTextOnly ? 5 : 1,
                child: isTextOnly
                    ? customContent
                    : ClipRect(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: customContent,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: isTextOnly ? 72 : null,
                child: Column(
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
