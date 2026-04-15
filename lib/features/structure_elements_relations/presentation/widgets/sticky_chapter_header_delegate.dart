import 'package:flutter/material.dart';

class StickyChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const StickyChapterHeaderDelegate({required this.title});

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
  bool shouldRebuild(covariant StickyChapterHeaderDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}
