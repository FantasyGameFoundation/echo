import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/shared/models/content_preview_item.dart';
import 'package:echo/shared/widgets/content_preview_card.dart';
import 'package:flutter/material.dart';

class NarrativeListTile extends StatelessWidget {
  const NarrativeListTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.previewItems = const <ContentPreviewItem>[],
    this.onTap,
  });

  final String title;
  final String description;
  final ElementStatus status;
  final List<ContentPreviewItem> previewItems;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade500,
      fontStyle: FontStyle.italic,
      height: 1.4,
    );

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDescription(descriptionStyle),
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

  Widget _buildDescription(TextStyle style) {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isNotEmpty) {
      return Text(
        trimmedDescription,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lineHeight = (style.fontSize ?? 12) * (style.height ?? 1);
    return SizedBox(height: lineHeight * 2);
  }

  Widget _buildAssociatedThumbnails() {
    if (previewItems.isEmpty) {
      return const SizedBox.shrink();
    }

    const thumbSize = 44.0;
    const thinSpacing = 2.0;
    final totalCount = previewItems.length;
    final hasDirectSecondary = totalCount == 2;
    final hasOverflow = totalCount > 2;

    return SizedBox(
      width: totalCount > 1 ? 90 : 44,
      height: thumbSize,
      child: Row(
        children: [
          _buildPreviewTile(
            previewItems.first,
            key: ValueKey(
              'narrativeListTilePreview-${previewItems.first.stableId}',
            ),
            size: thumbSize,
          ),
          if (hasDirectSecondary)
            Padding(
              padding: const EdgeInsets.only(left: thinSpacing),
              child: _buildPreviewTile(
                previewItems[1],
                key: ValueKey(
                  'narrativeListTilePreview-${previewItems[1].stableId}',
                ),
                size: thumbSize,
              ),
            ),
          if (hasOverflow)
            Container(
              key: const ValueKey('narrativeListTilePreview-overflow'),
              width: thumbSize,
              height: thumbSize,
              margin: const EdgeInsets.only(left: thinSpacing),
              child: ContentPreviewOverflowCard(
                item: previewItems[1],
                label: '+${totalCount - 1}',
                width: thumbSize,
                height: thumbSize,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewTile(
    ContentPreviewItem item, {
    required Key key,
    required double size,
  }) {
    return SizedBox(
      key: key,
      width: size,
      height: size,
      child: ContentPreviewCard(
        item: item,
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        textStyle: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.1,
        ),
        maxLines: 3,
      ),
    );
  }
}
