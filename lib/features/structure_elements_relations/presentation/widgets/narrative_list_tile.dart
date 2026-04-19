import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/photo_fallback_tile.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class NarrativeListTile extends StatelessWidget {
  const NarrativeListTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.images = const <String>[],
    this.onTap,
  });

  final String title;
  final String description;
  final ElementStatus status;
  final List<String> images;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tileBody = Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAssociatedThumbnails(),
          const SizedBox(width: 16),
          if (status == ElementStatus.ready)
            const Icon(Icons.check, color: Colors.black87, size: 20)
          else
            const SizedBox(width: 20, height: 20),
        ],
      ),
    );

    if (onTap == null) {
      return tileBody;
    }

    return InkWell(onTap: onTap, child: tileBody);
  }

  Widget _buildAssociatedThumbnails() {
    if (images.isEmpty) return const SizedBox.shrink();

    const thumbSize = 44.0;
    const thinSpacing = 2.0;
    final hasMore = images.length > 1;
    final previewImage = images.first;

    return SizedBox(
      width: hasMore ? 90 : 44,
      height: thumbSize,
      child: Row(
        children: [
          _buildThumbnail(previewImage, size: thumbSize),
          if (hasMore)
            Container(
              width: thumbSize,
              height: thumbSize,
              margin: const EdgeInsets.only(left: thinSpacing),
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Text(
                '+${images.length - 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String source, {required double size}) {
    final provider = narrativeThumbnailProvider(source);

    return SizedBox(
      width: size,
      height: size,
      child: Image(
        image: ResizeImage.resizeIfNeeded(120, null, provider),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const PhotoFallbackTile(size: 44);
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const PhotoFallbackTile(size: 44),
        ),
      ),
    );
  }
}
