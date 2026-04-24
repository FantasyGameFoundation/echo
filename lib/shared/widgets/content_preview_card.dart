import 'dart:ui';

import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/photo_fallback_tile.dart';
import 'package:echo/shared/models/content_preview_item.dart';
import 'package:flutter/material.dart';

class ContentPreviewCard extends StatelessWidget {
  const ContentPreviewCard({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    this.decoration = const BoxDecoration(color: Color(0xFFF1F1F3)),
    this.padding = const EdgeInsets.all(4),
    this.textStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      height: 1.15,
    ),
    this.textAlign = TextAlign.left,
    this.maxLines = 3,
    this.resizeWidth = 160,
    this.loadingFallback,
    this.errorFallback,
  });

  final ContentPreviewItem item;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final int maxLines;
  final int resizeWidth;
  final Widget? loadingFallback;
  final Widget? errorFallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: decoration,
      child: _buildPhoto(),
    );
  }

  Widget _buildPhoto() {
    final source = item.imageSource;
    if (source == null || source.trim().isEmpty) {
      return errorFallback ?? PhotoFallbackTile(size: width.clamp(16, 44));
    }

    return Image(
      image: ResizeImage.resizeIfNeeded(
        resizeWidth,
        null,
        narrativeThumbnailProvider(source),
      ),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return loadingFallback ?? PhotoFallbackTile(size: width.clamp(16, 44));
      },
      errorBuilder: (context, error, stackTrace) {
        return errorFallback ?? PhotoFallbackTile(size: width.clamp(16, 44));
      },
    );
  }
}

class ContentPreviewOverflowCard extends StatelessWidget {
  const ContentPreviewOverflowCard({
    super.key,
    required this.item,
    required this.label,
    required this.width,
    required this.height,
    this.decoration = const BoxDecoration(color: Color(0xFFF1F1F3)),
    this.padding = const EdgeInsets.all(4),
    this.textStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      height: 1.15,
    ),
    this.textAlign = TextAlign.left,
    this.maxLines = 3,
    this.resizeWidth = 160,
  });

  final ContentPreviewItem item;
  final String label;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final int maxLines;
  final int resizeWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ContentPreviewCard(
          item: item,
          width: width,
          height: height,
          decoration: decoration,
          padding: padding,
          textStyle: textStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          resizeWidth: resizeWidth,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.52),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
