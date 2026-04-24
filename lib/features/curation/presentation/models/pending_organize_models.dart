import 'package:echo/shared/models/content_preview_item.dart';

class PendingOrganizePageData {
  const PendingOrganizePageData({
    this.entries = const <PendingOrganizeEntryData>[],
    this.chapters = const <PendingOrganizeChapterOption>[],
    this.elements = const <PendingOrganizeElementOption>[],
    this.relationTypes = const <PendingOrganizeRelationTypeOption>[],
  });

  final List<PendingOrganizeEntryData> entries;
  final List<PendingOrganizeChapterOption> chapters;
  final List<PendingOrganizeElementOption> elements;
  final List<PendingOrganizeRelationTypeOption> relationTypes;
}

enum PendingOrganizeEntryType { photo }

class PendingOrganizeEntryData {
  const PendingOrganizeEntryData.photo({
    required this.entryId,
    required this.imageSource,
    required this.photoPath,
    this.sourceElementId,
    this.sourceChapterId,
    this.sourceRecordId,
    this.title = '',
    this.description = '',
    this.sourceRelationGroupIds = const <String>[],
  }) : type = PendingOrganizeEntryType.photo;

  final String entryId;
  final PendingOrganizeEntryType type;
  final String? imageSource;
  final String? photoPath;
  final String? sourceElementId;
  final String? sourceChapterId;
  final String? sourceRecordId;
  final String title;
  final String description;
  final List<String> sourceRelationGroupIds;
}

class PendingOrganizeChapterOption {
  const PendingOrganizeChapterOption({
    required this.label,
    required this.sortOrder,
    this.chapterId,
    this.coverPreviewItem,
  });

  final String? chapterId;
  final String label;
  final int sortOrder;
  final ContentPreviewItem? coverPreviewItem;
}

class PendingOrganizeElementOption {
  const PendingOrganizeElementOption({
    required this.elementId,
    required this.title,
    required this.description,
    required this.chapterId,
    required this.chapterLabel,
    required this.sortOrder,
    this.previewItems = const <ContentPreviewItem>[],
  });

  final String elementId;
  final String title;
  final String description;
  final String? chapterId;
  final String chapterLabel;
  final int sortOrder;
  final List<ContentPreviewItem> previewItems;
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
    required this.previewItems,
  });

  final String groupId;
  final String relationTypeId;
  final String title;
  final List<ContentPreviewItem> previewItems;
}

class PendingOrganizeSaveRequest {
  const PendingOrganizeSaveRequest.photo({
    required this.entryId,
    required this.photoPath,
    this.sourceElementId,
    this.sourceRecordId,
    required this.targetChapterId,
    required this.targetElementId,
    required this.relationGroupIds,
  }) : type = PendingOrganizeEntryType.photo;

  final String entryId;
  final PendingOrganizeEntryType type;
  final String? photoPath;
  final String? sourceElementId;
  final String? sourceRecordId;
  final String? targetChapterId;
  final String? targetElementId;
  final List<String> relationGroupIds;
}
