class TimelinePhotoTarget {
  const TimelinePhotoTarget({required this.recordId, required this.photoPath});

  final String recordId;
  final String photoPath;
}

enum TimelineItemType { photo, note }

class TimelineItem {
  const TimelineItem({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.content,
    this.location,
    this.images = const <String>[],
    this.photoTarget,
  });

  final String id;
  final DateTime createdAt;
  final TimelineItemType type;
  final String content;
  final String? location;
  final List<String> images;
  final TimelinePhotoTarget? photoTarget;

  bool get isPhoto => type == TimelineItemType.photo;
}
