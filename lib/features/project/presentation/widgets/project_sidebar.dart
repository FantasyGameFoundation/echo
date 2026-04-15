import 'package:flutter/material.dart';

class ProjectSidebar extends StatelessWidget {
  const ProjectSidebar({
    super.key,
    required this.onNewProject,
  });

  final VoidCallback onNewProject;

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
            child: const Text(
              '项目中心',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSectionTitle('活 跃 项 目'),
          _buildNavItem(title: '赤水河沿岸寻访', isSelected: true),
          _buildNavItem(title: '建筑的沉默'),
          const SizedBox(height: 32),
          _buildSectionTitle('已 归 档 项 目'),
          _buildNavItem(title: '无名系列 01'),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: onNewProject,
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
