import 'package:flutter/material.dart';

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
        const SizedBox(width: 32),
        _buildTab(2, '关联关系'),
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
