enum ProjectRelationTargetKind { element, photo }

class ProjectRelationDraftMember {
  const ProjectRelationDraftMember._({
    required this.kind,
    this.elementId,
    this.photoPath,
    this.sourceElementId,
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

  final ProjectRelationTargetKind kind;
  final String? elementId;
  final String? photoPath;
  final String? sourceElementId;
}
