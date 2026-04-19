import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';

abstract class ProjectRelationRepository {
  Future<List<ProjectRelationType>> listRelationTypesForProject(
    String projectId,
  );

  Future<ProjectRelationType> createRelationType({
    required String projectId,
    required String name,
    required String description,
  });

  Future<ProjectRelationType> updateRelationType({
    required String relationTypeId,
    required String name,
    required String description,
  });

  Future<List<ProjectRelationGroup>> listRelationGroupsForProject(
    String projectId,
  );

  Future<List<ProjectRelationMember>> listRelationMembersForProject(
    String projectId,
  );

  Future<ProjectRelationGroup> createRelationGroup({
    required String projectId,
    required String relationTypeId,
    required List<ProjectRelationDraftMember> members,
  });
}
