import 'package:echo/shared/models/content_preview_item.dart';

class StructureChapterCardData {
  const StructureChapterCardData({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.elementCount,
    this.previewItems = const <ContentPreviewItem>[],
  });

  final String chapterNumber;
  final String title;
  final String description;
  final String statusLabel;
  final int elementCount;
  final List<ContentPreviewItem> previewItems;
}
