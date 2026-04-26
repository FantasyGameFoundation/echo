import 'dart:ui';

import 'package:flutter/material.dart';

class RestrainedActionButton extends StatelessWidget {
  const RestrainedActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.add,
    this.margin = EdgeInsets.zero,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        width: double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.68),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.018),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.black.withValues(alpha: 0.46),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
