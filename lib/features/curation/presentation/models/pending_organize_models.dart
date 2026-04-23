class PendingOrganizePageData {
  const PendingOrganizePageData({
    this.photos = const <PendingOrganizePhotoData>[],
    this.chapters = const <PendingOrganizeChapterOption>[],
    this.elements = const <PendingOrganizeElementOption>[],
    this.relationTypes = const <PendingOrganizeRelationTypeOption>[],
  });

  final List<PendingOrganizePhotoData> photos;
  final List<PendingOrganizeChapterOption> chapters;
  final List<PendingOrganizeElementOption> elements;
  final List<PendingOrganizeRelationTypeOption> relationTypes;
}

class PendingOrganizePhotoData {
  const PendingOrganizePhotoData({
    required this.photoId,
    required this.imageSource,
    required this.photoPath,
    required this.sourceElementId,
    required this.sourceChapterId,
    required this.sourceRelationGroupIds,
  });

  final String photoId;
  final String imageSource;
  final String photoPath;
  final String sourceElementId;
  final String? sourceChapterId;
  final List<String> sourceRelationGroupIds;
}

class PendingOrganizeChapterOption {
  const PendingOrganizeChapterOption({
    required this.label,
    required this.sortOrder,
    this.chapterId,
    this.coverImageSource,
  });

  final String? chapterId;
  final String label;
  final int sortOrder;
  final String? coverImageSource;
}

class PendingOrganizeElementOption {
  const PendingOrganizeElementOption({
    required this.elementId,
    required this.title,
    required this.description,
    required this.chapterId,
    required this.chapterLabel,
    required this.sortOrder,
    this.imageSources = const <String>[],
  });

  final String elementId;
  final String title;
  final String description;
  final String? chapterId;
  final String chapterLabel;
  final int sortOrder;
  final List<String> imageSources;
}

class PendingOrganizeRelationTypeOption {
  const PendingOrganizeRelationTypeOption({
    required this.relationTypeId,
    required this.name,
    required this.groups,
  });

  final String relationTypeId;
  final String name;
  final List<PendingOrganizeRelationGroupOption> groups;
}

class PendingOrganizeRelationGroupOption {
  const PendingOrganizeRelationGroupOption({
    required this.groupId,
    required this.relationTypeId,
    required this.title,
    required this.imageSources,
  });

  final String groupId;
  final String relationTypeId;
  final String title;
  final List<String> imageSources;
}

class PendingOrganizeSaveRequest {
  const PendingOrganizeSaveRequest({
    required this.photoId,
    required this.photoPath,
    required this.sourceElementId,
    required this.targetElementId,
    required this.relationGroupIds,
  });

  final String photoId;
  final String photoPath;
  final String sourceElementId;
  final String targetElementId;
  final List<String> relationGroupIds;
}
