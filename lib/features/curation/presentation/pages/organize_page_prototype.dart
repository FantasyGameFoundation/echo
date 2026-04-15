import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class OrganizePagePrototype extends StatefulWidget {
  const OrganizePagePrototype({
    super.key,
    this.projectTitle = '',
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
  });

  final String projectTitle;
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
  final Map<String, int> _relationCounts = {'呼应': 3, '对比': 1, '重复': 2, '转折': 0};

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
                          onSelected: (val) =>
                              setState(() => _selectedChapter = val),
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
              colorFilter: greyscaleFilter,
              child: Image.network(_previewImages[index], fit: BoxFit.contain),
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
      {'title': '未归属', 'image': null},
      {'title': '01 / 晨曦之眼', 'image': _previewImages[0]},
      {'title': '02 / 众神之后', 'image': _previewImages[1]},
      {'title': '03 / 呼吸感', 'image': _previewImages[2]},
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
                color: isActive
                    ? const Color(0xFF222222)
                    : Colors.grey.shade200,
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
                        fontWeight: isActive
                            ? FontWeight.w500
                            : FontWeight.normal,
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
        color: isActive
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.grey.shade300,
        child: const Icon(
          Icons.grid_view_rounded,
          size: 20,
          color: Colors.white70,
        ),
      );
    }

    return SizedBox(
      width: 52,
      height: 52,
      child: ColorFiltered(
        colorFilter: greyscaleFilter,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isActive
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.grey.shade300,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF222222)
                      : Colors.grey.shade200,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(color: Colors.grey.shade200),
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
        builder: (_) =>
            RelationPhotoPickerPage(relation: relation, photos: _previewImages),
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
  State<RelationPhotoPickerPage> createState() =>
      _RelationPhotoPickerPageState();
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
          final filterMatch =
              _activeFilter == '全部' || item.category == _activeFilter;
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
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
