enum ProjectRelationTargetKind { element, photo, textCard }

class ProjectRelationDraftMember {
  const ProjectRelationDraftMember._({
    required this.kind,
    this.elementId,
    this.photoPath,
    this.sourceElementId,
    this.textCardId,
  });

  const ProjectRelationDraftMember.element({required String elementId})
    : this._(kind: ProjectRelationTargetKind.element, elementId: elementId);

  const ProjectRelationDraftMember.photo({
    required String photoPath,
    required String sourceElementId,
  }) : this._(
         kind: ProjectRelationTargetKind.photo,
         photoPath: photoPath,
         sourceElementId: sourceElementId,
       );

  const ProjectRelationDraftMember.textCard({required String textCardId})
    : this._(kind: ProjectRelationTargetKind.textCard, textCardId: textCardId);

  final ProjectRelationTargetKind kind;
  final String? elementId;
  final String? photoPath;
  final String? sourceElementId;
  final String? textCardId;
}
