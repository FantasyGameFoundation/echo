import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.elementCount,
    required this.customContent,
    this.extraTopRightWidget,
    this.onTap,
  });

  final String chapterNumber;
  final String title;
  final String elementCount;
  final Widget customContent;
  final Widget? extraTopRightWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardBody = Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'C H A P T E R  $chapterNumber',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  letterSpacing: 2.0,
                ),
              ),
              // ignore: use_null_aware_elements
              if (extraTopRightWidget != null) extraTopRightWidget!,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: customContent),
              const SizedBox(width: 16),
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '关联元素',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      elementCount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return cardBody;
    }

    return InkWell(onTap: onTap, child: cardBody);
  }
}
