import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/domain/project_relation_defaults.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:isar/isar.dart';

class LocalProjectRelationRepository implements ProjectRelationRepository {
  LocalProjectRelationRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  Future<void> _ensureDefaultRelationTypes(String projectId) async {
    final database = await _database();
    final existingTypes = await database.projectRelationTypes
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    if (existingTypes.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final defaultTypes = defaultProjectRelationDefinitions
        .map(
          (definition) => ProjectRelationType.create(
            projectId: projectId,
            relationName: definition.name,
            relationDescription: definition.description,
            relationSortOrder: definition.sortOrder,
            createdTimestamp: now,
            updatedTimestamp: now,
          ),
        )
        .toList();

    await database.writeTxn(() async {
      await database.projectRelationTypes.putAll(defaultTypes);
    });
  }

  @override
  Future<List<ProjectRelationType>> listRelationTypesForProject(
    String projectId,
  ) async {
    await _ensureDefaultRelationTypes(projectId);
    final database = await _database();
    final relationTypes = await database.projectRelationTypes
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    relationTypes.sort(
      (left, right) => left.sortOrder.compareTo(right.sortOrder),
    );
    return relationTypes;
  }

  @override
  Future<ProjectRelationType> createRelationType({
    required String projectId,
    required String name,
    required String description,
  }) async {
    await _ensureDefaultRelationTypes(projectId);
    final database = await _database();
    final existingTypes = await database.projectRelationTypes
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    final nextSortOrder = existingTypes.isEmpty
        ? 0
        : existingTypes
                  .map((relationType) => relationType.sortOrder)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    final now = DateTime.now();
    final relationType = ProjectRelationType.create(
      projectId: projectId,
      relationName: name,
      relationDescription: description,
      relationSortOrder: nextSortOrder,
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.projectRelationTypes.put(relationType);
    });

    return relationType;
  }

  @override
  Future<List<ProjectRelationGroup>> listRelationGroupsForProject(
    String projectId,
  ) async {
    final database = await _database();
    final relationGroups = await database.projectRelationGroups
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    relationGroups.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
    return relationGroups;
  }

  @override
  Future<List<ProjectRelationMember>> listRelationMembersForProject(
    String projectId,
  ) async {
    final database = await _database();
    final relationMembers = await database.projectRelationMembers
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    relationMembers.sort(
      (left, right) => left.memberSortOrder.compareTo(right.memberSortOrder),
    );
    return relationMembers;
  }

  @override
  Future<ProjectRelationGroup> createRelationGroup({
    required String projectId,
    required String relationTypeId,
    required List<ProjectRelationDraftMember> members,
  }) async {
    if (members.length < 2) {
      throw ArgumentError(
        'A relation group must contain at least two selections.',
      );
    }

    final database = await _database();
    final relationType = await database.projectRelationTypes
        .filter()
        .relationTypeIdEqualTo(relationTypeId)
        .findFirst();
    if (relationType == null) {
      throw StateError('Relation type not found: $relationTypeId');
    }

    final now = DateTime.now();
    final relationGroup = ProjectRelationGroup.create(
      projectId: projectId,
      relationTypeId: relationTypeId,
      createdTimestamp: now,
      updatedTimestamp: now,
    );
    final relationMembers = <ProjectRelationMember>[
      for (var index = 0; index < members.length; index++)
        ProjectRelationMember.create(
          projectId: projectId,
          groupId: relationGroup.relationGroupId,
          targetKind: members[index].kind.name,
          elementId: members[index].elementId,
          photoPath: members[index].photoPath,
          sourceElementId: members[index].sourceElementId,
          sortOrder: index,
          createdTimestamp: now,
        ),
    ];

    await database.writeTxn(() async {
      await database.projectRelationGroups.put(relationGroup);
      await database.projectRelationMembers.putAll(relationMembers);
    });

    return relationGroup;
  }
}
