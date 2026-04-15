import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.elementCount,
    required this.customContent,
    this.isTextOnly = false,
    this.extraTopRightWidget,
  });

  final String chapterNumber;
  final String title;
  final String elementCount;
  final Widget customContent;
  final bool isTextOnly;
  final Widget? extraTopRightWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(height: isTextOnly ? 18 : 24),
          Row(
            crossAxisAlignment: isTextOnly
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Expanded(flex: isTextOnly ? 5 : 1, child: customContent),
              const SizedBox(width: 16),
              SizedBox(
                width: isTextOnly ? 72 : null,
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
  }
}
