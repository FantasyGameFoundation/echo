import 'package:echo/shared/models/prototype_tab.dart';
import 'package:flutter/material.dart';

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
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
            Icons.show_chart,
            '历程',
            isActive: activeTab == PrototypeTab.timeline,
            onTap: () => onChangeTab(PrototypeTab.timeline),
          ),
          _buildNavItem(
            Icons.bookmark_border,
            '信标',
            isActive: activeTab == PrototypeTab.overview,
            onTap: () => onChangeTab(PrototypeTab.overview),
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
