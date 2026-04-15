import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class TimelinePagePrototype extends StatefulWidget {
  const TimelinePagePrototype({
    super.key,
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
  });

  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  State<TimelinePagePrototype> createState() => _TimelinePagePrototypeState();
}

class _TimelinePagePrototypeState extends State<TimelinePagePrototype> {
  String _activeTab = '全部';

  final List<TimelineEvent> _allEvents = [
    TimelineEvent(
      date: DateTime(2026, 10, 24, 14, 30),
      type: TimelineEventType.photo,
      location: '贵州省 遵义市 习水县',
      content: '发现了一些有趣的钢铁结构，光影对比很强烈。赤水河畔的旧工厂正逐渐被植被吞噬。',
      images: [
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400',
        'https://images.unsplash.com/photo-1496307653780-42ee777d4833?w=400',
      ],
    ),
    TimelineEvent(
      date: DateTime(2026, 10, 22, 11, 15),
      type: TimelineEventType.node,
      content: '',
      highlightText: '元素【废弃的盐道码头】已标记完成',
      images: ['https://images.unsplash.com/photo-1496307653780-42ee777d4833?w=200'],
    ),
    TimelineEvent(
      date: DateTime(2026, 10, 21, 20, 45),
      type: TimelineEventType.note,
      content: '「今天的寻访非常顺利，赤水河的水位比预想的要低一些，正好露出了那些旧时代的盐道遗迹。下次需要带上无人机，从空中俯瞰河道与古道的拓扑关系。」',
    ),
    TimelineEvent(
      date: DateTime(2026, 10, 18, 9, 10),
      type: TimelineEventType.photo,
      location: '贵州省 遵义市 茅台镇',
      content: '清晨的雾气还未散去，空气中弥漫着淡淡的酒糟香气。车间的外墙上爬满了厚厚的苍藓，这种历史感是新建筑无法模拟的。记录下了光线穿透雾气照刷在石阶上的瞬间。',
      images: ['https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800'],
    ),
    TimelineEvent(
      date: DateTime(2026, 10, 15, 16, 40),
      type: TimelineEventType.organize,
      content: '',
      highlightText: '建立关联：【码头遗址】与【第三章：水路文明】',
      images: [
        'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?w=200',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=200',
      ],
    ),
    TimelineEvent(
      date: DateTime(2026, 10, 12, 22, 15),
      type: TimelineEventType.note,
      content: '「整理照片时发现，那些看似无序的碎石滩其实遵循着河流的几何走向。需要对水文地理学做更深入的案头研究。关于『消逝的建筑』这一主题，我想表达的不只是物理的坍塌，更是意义的迁移。」',
      images: ['https://images.unsplash.com/photo-1518131341018-095034639e44?w=400'],
    ),
    TimelineEvent(
      date: DateTime(2026, 9, 28, 14, 00),
      type: TimelineEventType.node,
      content: '',
      highlightText: '章节【第一章：河岸线】框架已搭建完成',
      images: [],
    ),
    TimelineEvent(
      date: DateTime(2026, 9, 25, 10, 30),
      type: TimelineEventType.photo,
      location: '四川省 泸州市 赤水市',
      content: '项目启动。首次跨越省界，从不同的行政视角观察同一条河流。',
      images: ['https://images.unsplash.com/photo-1517581177682-a085bb7ffb15?w=800'],
    ),
  ];

  List<TimelineEvent> get _filteredEvents {
    if (_activeTab == '全部') return _allEvents;
    return _filterEvents(_activeTab);
  }

  List<TimelineEvent> _filterEvents(String tab) {
    switch (tab) {
      case '照片':
        return _allEvents.where((e) => e.type == TimelineEventType.photo).toList();
      case '手记':
        return _allEvents.where((e) => e.type == TimelineEventType.note).toList();
      case '整理':
        return _allEvents.where((e) => e.type == TimelineEventType.organize).toList();
      case '节点':
        return _allEvents.where((e) => e.type == TimelineEventType.node).toList();
      default:
        return _allEvents;
    }
  }

  Map<String, List<TimelineEvent>> get _groupedEvents {
    final groups = <String, List<TimelineEvent>>{};
    for (final event in _filteredEvents) {
      final monthKey = '${event.date.year}年${event.date.month.toString().padLeft(2, '0')}月';
      groups.putIfAbsent(monthKey, () => []);
      groups[monthKey]!.add(event);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupedEvents;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildTabsWithSearch(),
            const SizedBox(height: 16),
            Expanded(
              child: groupedData.isEmpty
                  ? Center(
                      child: Text(
                        '暂无记录',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        for (final entry in groupedData.entries)
                          SliverMainAxisGroup(
                            slivers: [
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _MonthHeaderDelegate(monthText: entry.key),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final isLastInMonth = index == entry.value.length - 1;
                                    return _buildTimelineTile(entry.value[index], isLastInMonth);
                                  },
                                  childCount: entry.value.length,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
            CustomBottomNavBar(
              activeTab: PrototypeTab.timeline,
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

  Widget _buildTabsWithSearch() {
    const tabs = ['全部', '照片', '手记', '整理', '节点'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            _buildTab(tabs[i]),
            if (i != tabs.length - 1) const SizedBox(width: 24),
          ],
          const Spacer(),
          const Icon(Icons.search, color: Colors.black54, size: 18),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.black87 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.black87 : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTile(TimelineEvent event, bool isLastInMonth) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.date.month}月${event.date.day}日',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(width: 1, height: 32, color: Colors.grey.shade300),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: isLastInMonth ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildEventCard(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(TimelineEvent event) {
    final isImageHeavy = event.type == TimelineEventType.photo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.location != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (isImageHeavy && event.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.network(
                event.images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 180, color: Colors.grey.shade200),
              ),
            ),
          if (event.highlightText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(left: BorderSide(color: Colors.grey.shade400, width: 2)),
              ),
              child: Text(
                event.highlightText!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            )
          else
            Text(
              event.content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.8,
                fontStyle: event.type == TimelineEventType.note ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          if (!isImageHeavy && event.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 84,
              child: Row(
                children: event.images.take(2).map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      url,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 84, height: 84, color: Colors.grey.shade200),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum TimelineEventType { photo, note, organize, node }

class TimelineEvent {
  TimelineEvent({
    required this.date,
    required this.type,
    required this.content,
    this.location,
    this.images = const [],
    this.highlightText,
  });

  final DateTime date;
  final TimelineEventType type;
  final String content;
  final String? location;
  final List<String> images;
  final String? highlightText;
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MonthHeaderDelegate({required this.monthText});

  final String monthText;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF7F7F9),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
      child: Text(
        monthText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) {
    return monthText != oldDelegate.monthText;
  }
}
