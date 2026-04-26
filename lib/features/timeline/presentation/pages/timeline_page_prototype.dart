import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:echo/features/timeline/presentation/models/timeline_item.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class TimelinePagePrototype extends StatefulWidget {
  const TimelinePagePrototype({
    super.key,
    this.projectTitle = '',
    this.items = const <TimelineItem>[],
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
    this.onOpenSettings,
    this.onTimelineItemTap,
    this.onTimelineItemLongPress,
  });

  final String projectTitle;
  final List<TimelineItem> items;
  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;
  final Future<void> Function()? onOpenSettings;
  final ValueChanged<TimelineItem>? onTimelineItemTap;
  final ValueChanged<TimelineItem>? onTimelineItemLongPress;

  @override
  State<TimelinePagePrototype> createState() => _TimelinePagePrototypeState();
}

class _TimelinePagePrototypeState extends State<TimelinePagePrototype> {
  static const List<String> _tabs = <String>['全部', '照片', '手记'];

  String _activeTab = _tabs.first;

  List<TimelineItem> get _filteredItems {
    final items = List<TimelineItem>.from(widget.items)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return switch (_activeTab) {
      '照片' =>
        items.where((item) => item.type == TimelineItemType.photo).toList(),
      '手记' =>
        items.where((item) => item.type == TimelineItemType.note).toList(),
      _ => items,
    };
  }

  Map<String, List<TimelineItem>> get _groupedItems {
    final groups = <String, List<TimelineItem>>{};
    for (final item in _filteredItems) {
      final monthKey =
          '${item.createdAt.year}年${item.createdAt.month.toString().padLeft(2, '0')}月';
      groups.putIfAbsent(monthKey, () => <TimelineItem>[]);
      groups[monthKey]!.add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupedItems;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildTabs(),
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
                                delegate: _MonthHeaderDelegate(
                                  monthText: entry.key,
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final isLastInMonth =
                                      index == entry.value.length - 1;
                                  return _buildTimelineTile(
                                    entry.value[index],
                                    isLastInMonth,
                                  );
                                }, childCount: entry.value.length),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeTab: PrototypeTab.timeline,
        onChangeTab: widget.onBottomTabChanged,
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
                style: const TextStyle(
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
            onPressed: () {
              widget.onOpenSettings?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          for (var index = 0; index < _tabs.length; index++) ...[
            _buildTab(_tabs[index]),
            if (index != _tabs.length - 1) const SizedBox(width: 24),
          ],
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

  Widget _buildTimelineTile(TimelineItem item, bool isLastInMonth) {
    final canOpenCuration =
        item.photoTarget != null && widget.onTimelineItemTap != null;
    final card = KeyedSubtree(
      key: ValueKey('timelineItem-${item.id}'),
      child: _buildEventCard(item),
    );
    final canDelete = widget.onTimelineItemLongPress != null;
    final interactiveCard = canOpenCuration || canDelete
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canOpenCuration
                ? () => widget.onTimelineItemTap?.call(item)
                : null,
            onLongPress: canDelete
                ? () => widget.onTimelineItemLongPress?.call(item)
                : null,
            child: card,
          )
        : card;

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
                    '${item.createdAt.month}月${item.createdAt.day}日',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
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
                      color: isLastInMonth
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: interactiveCard),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(TimelineItem item) {
    final contentText = item.content.trim();
    final shouldShowLabel = item.isPhoto;

    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.location != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.location!,
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
          if (shouldShowLabel || contentText.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  if (shouldShowLabel)
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: _TimelineTypeTag(label: '作品'),
                      ),
                    ),
                  if (contentText.isNotEmpty) TextSpan(text: contentText),
                ],
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.8,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (item.images.isNotEmpty) ...[
            if (shouldShowLabel || contentText.isNotEmpty)
              const SizedBox(height: 16),
            SizedBox(
              height: 84,
              child: ListView.separated(
                key: ValueKey('timelineImageStrip-${item.id}'),
                scrollDirection: Axis.horizontal,
                itemCount: item.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final source = item.images[index];
                  return SizedBox(
                    width: 84,
                    height: 84,
                    child: _buildImage(
                      source,
                      height: 84,
                      width: 84,
                      resizeWidth: 240,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(
    String source, {
    required double height,
    double? width,
    required int resizeWidth,
  }) {
    return Image(
      image: ResizeImage.resizeIfNeeded(
        resizeWidth,
        null,
        narrativeThumbnailProvider(source),
      ),
      fit: BoxFit.cover,
      width: width ?? double.infinity,
      height: height,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? double.infinity,
          height: height,
          color: Colors.grey.shade200,
        );
      },
    );
  }
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MonthHeaderDelegate({required this.monthText});

  final String monthText;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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

class _TimelineTypeTag extends StatelessWidget {
  const _TimelineTypeTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('timelineTypeTag-$label'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 0.5),
        color: const Color(0xFFF7F7F9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.4,
          color: Color(0xFF7B7B80),
          height: 1.0,
        ),
      ),
    );
  }
}
