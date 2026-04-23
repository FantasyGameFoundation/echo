import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:flutter/material.dart';

class TextCardSummaryTile extends StatelessWidget {
  const TextCardSummaryTile({
    super.key,
    required this.card,
    required this.keyPrefix,
  });

  final TextCard card;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            key: ValueKey('$keyPrefix-title-${card.textCardId}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.body,
            key: ValueKey('$keyPrefix-body-${card.textCardId}'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black.withValues(alpha: 0.64),
            ),
          ),
        ],
      ),
    );
  }
}
