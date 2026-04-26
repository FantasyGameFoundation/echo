import 'dart:ui';

import 'package:flutter/material.dart';

class DevelopingPhotoTile extends StatelessWidget {
  const DevelopingPhotoTile({
    super.key,
    this.width = 80,
    this.height = 80,
    this.label = '显 影 中',
    this.failed = false,
  });

  final double width;
  final double height;
  final String label;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: const Color(0xFFF7F7F7).withValues(alpha: 0.58),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (failed)
                  const Icon(
                    Icons.error_outline,
                    color: Colors.black26,
                    size: 18,
                  )
                else
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  failed ? '导 入 失 败' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2,
                    color: Colors.black.withValues(alpha: 0.36),
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
