import 'package:flutter/material.dart';

class PhotoFallbackTile extends StatelessWidget {
  const PhotoFallbackTile({super.key, required this.size});

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
