class StructureChapterCardData {
  const StructureChapterCardData({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.elementCount,
    this.previewImageSources = const <String>[],
  });

  final String chapterNumber;
  final String title;
  final String description;
  final String statusLabel;
  final int elementCount;
  final List<String> previewImageSources;
}
