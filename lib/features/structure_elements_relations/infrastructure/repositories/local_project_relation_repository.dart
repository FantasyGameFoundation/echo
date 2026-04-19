import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/domain/project_relation_defaults.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:isar/isar.dart';

const _hiddenRelationTypeName = '__echo_hidden_relation_type__';
const _hiddenRelationTypeDescription = '__echo_hidden_relation_type__';

class LocalProjectRelationRepository implements ProjectRelationRepository {
  LocalProjectRelationRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  bool _isHiddenRelationType(ProjectRelationType relationType) {
    return relationType.name == _hiddenRelationTypeName &&
        relationType.description == _hiddenRelationTypeDescription;
  }

  ProjectRelationType _buildHiddenRelationType(String projectId) {
    final now = DateTime.now();
    return ProjectRelationType.create(
      projectId: projectId,
      relationName: _hiddenRelationTypeName,
      relationDescription: _hiddenRelationTypeDescription,
      relationSortOrder: -1,
      createdTimestamp: now,
      updatedTimestamp: now,
    );
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
    return relationTypes
        .where((relationType) => !_isHiddenRelationType(relationType))
        .toList();
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
  Future<ProjectRelationType> updateRelationType({
    required String relationTypeId,
    required String name,
    required String description,
  }) async {
    final database = await _database();
    final relationType = await database.projectRelationTypes
        .filter()
        .relationTypeIdEqualTo(relationTypeId)
        .findFirst();
    if (relationType == null) {
      throw StateError('Relation type not found: $relationTypeId');
    }

    relationType.name = name.trim();
    final trimmedDescription = description.trim();
    relationType.description = trimmedDescription;
    relationType.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.projectRelationTypes.put(relationType);
    });

    return relationType;
  }

  @override
  Future<bool> deleteRelationType(String relationTypeId) async {
    final database = await _database();
    final relationType = await database.projectRelationTypes
        .filter()
        .relationTypeIdEqualTo(relationTypeId)
        .findFirst();
    if (relationType == null) {
      return false;
    }

    final relationGroups = await database.projectRelationGroups
        .filter()
        .linkedRelationTypeIdEqualTo(relationTypeId)
        .findAll();
    final groupIds = relationGroups
        .map((group) => group.relationGroupId)
        .toSet();
    final relationMembers = groupIds.isEmpty
        ? const <ProjectRelationMember>[]
        : (await database.projectRelationMembers
                  .filter()
                  .owningProjectIdEqualTo(relationType.owningProjectId)
                  .findAll())
              .where((member) => groupIds.contains(member.owningGroupId))
              .toList();
    final projectRelationTypes = await database.projectRelationTypes
        .filter()
        .owningProjectIdEqualTo(relationType.owningProjectId)
        .findAll();
    final remainingVisibleTypes = projectRelationTypes.where(
      (current) =>
          current.relationTypeId != relationTypeId &&
          !_isHiddenRelationType(current),
    );
    final hiddenPlaceholder = projectRelationTypes.where(_isHiddenRelationType);
    final shouldPersistHiddenPlaceholder =
        remainingVisibleTypes.isEmpty && hiddenPlaceholder.isEmpty;

    await database.writeTxn(() async {
      if (relationMembers.isNotEmpty) {
        await database.projectRelationMembers.deleteAll(
          relationMembers.map((member) => member.isarId).toList(),
        );
      }
      if (relationGroups.isNotEmpty) {
        await database.projectRelationGroups.deleteAll(
          relationGroups.map((group) => group.isarId).toList(),
        );
      }
      await database.projectRelationTypes.delete(relationType.isarId);
      if (shouldPersistHiddenPlaceholder) {
        await database.projectRelationTypes.put(
          _buildHiddenRelationType(relationType.owningProjectId),
        );
      }
    });

    return true;
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

  @override
  Future<bool> deleteRelationGroup(String relationGroupId) async {
    final database = await _database();
    final relationGroup = await database.projectRelationGroups
        .filter()
        .relationGroupIdEqualTo(relationGroupId)
        .findFirst();
    if (relationGroup == null) {
      return false;
    }

    final relationMembers = await database.projectRelationMembers
        .filter()
        .owningGroupIdEqualTo(relationGroupId)
        .findAll();

    await database.writeTxn(() async {
      if (relationMembers.isNotEmpty) {
        await database.projectRelationMembers.deleteAll(
          relationMembers.map((member) => member.isarId).toList(),
        );
      }
      await database.projectRelationGroups.delete(relationGroup.isarId);
    });

    return true;
  }
}
