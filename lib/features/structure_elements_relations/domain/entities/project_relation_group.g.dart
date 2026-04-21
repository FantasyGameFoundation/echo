// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_relation_group.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectRelationGroupCollection on Isar {
  IsarCollection<ProjectRelationGroup> get projectRelationGroups =>
      this.collection();
}

const ProjectRelationGroupSchema = CollectionSchema(
  name: r'ProjectRelationGroup',
  id: -8024090222762274609,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'linkedRelationTypeId': PropertySchema(
      id: 2,
      name: r'linkedRelationTypeId',
      type: IsarType.string,
    ),
    r'owningProjectId': PropertySchema(
      id: 3,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'relationGroupId': PropertySchema(
      id: 4,
      name: r'relationGroupId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _projectRelationGroupEstimateSize,
  serialize: _projectRelationGroupSerialize,
  deserialize: _projectRelationGroupDeserialize,
  deserializeProp: _projectRelationGroupDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'relationGroupId': IndexSchema(
      id: -562102214946134275,
      name: r'relationGroupId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'relationGroupId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'owningProjectId': IndexSchema(
      id: 8853439974620037944,
      name: r'owningProjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'owningProjectId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'linkedRelationTypeId': IndexSchema(
      id: 4892077112604102697,
      name: r'linkedRelationTypeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedRelationTypeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _projectRelationGroupGetId,
  getLinks: _projectRelationGroupGetLinks,
  attach: _projectRelationGroupAttach,
  version: '3.1.0+1',
);

int _projectRelationGroupEstimateSize(
  ProjectRelationGroup object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.linkedRelationTypeId.length * 3;
  bytesCount += 3 + object.owningProjectId.length * 3;
  bytesCount += 3 + object.relationGroupId.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _projectRelationGroupSerialize(
  ProjectRelationGroup object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.linkedRelationTypeId);
  writer.writeString(offsets[3], object.owningProjectId);
  writer.writeString(offsets[4], object.relationGroupId);
  writer.writeString(offsets[5], object.title);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

ProjectRelationGroup _projectRelationGroupDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectRelationGroup();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.isarId = id;
  object.linkedRelationTypeId = reader.readString(offsets[2]);
  object.owningProjectId = reader.readString(offsets[3]);
  object.relationGroupId = reader.readString(offsets[4]);
  object.title = reader.readStringOrNull(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _projectRelationGroupDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectRelationGroupGetId(ProjectRelationGroup object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _projectRelationGroupGetLinks(
    ProjectRelationGroup object) {
  return [];
}

void _projectRelationGroupAttach(
    IsarCollection<dynamic> col, Id id, ProjectRelationGroup object) {
  object.isarId = id;
}

extension ProjectRelationGroupByIndex on IsarCollection<ProjectRelationGroup> {
  Future<ProjectRelationGroup?> getByRelationGroupId(String relationGroupId) {
    return getByIndex(r'relationGroupId', [relationGroupId]);
  }

  ProjectRelationGroup? getByRelationGroupIdSync(String relationGroupId) {
    return getByIndexSync(r'relationGroupId', [relationGroupId]);
  }

  Future<bool> deleteByRelationGroupId(String relationGroupId) {
    return deleteByIndex(r'relationGroupId', [relationGroupId]);
  }

  bool deleteByRelationGroupIdSync(String relationGroupId) {
    return deleteByIndexSync(r'relationGroupId', [relationGroupId]);
  }

  Future<List<ProjectRelationGroup?>> getAllByRelationGroupId(
      List<String> relationGroupIdValues) {
    final values = relationGroupIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'relationGroupId', values);
  }

  List<ProjectRelationGroup?> getAllByRelationGroupIdSync(
      List<String> relationGroupIdValues) {
    final values = relationGroupIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'relationGroupId', values);
  }

  Future<int> deleteAllByRelationGroupId(List<String> relationGroupIdValues) {
    final values = relationGroupIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'relationGroupId', values);
  }

  int deleteAllByRelationGroupIdSync(List<String> relationGroupIdValues) {
    final values = relationGroupIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'relationGroupId', values);
  }

  Future<Id> putByRelationGroupId(ProjectRelationGroup object) {
    return putByIndex(r'relationGroupId', object);
  }

  Id putByRelationGroupIdSync(ProjectRelationGroup object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'relationGroupId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRelationGroupId(List<ProjectRelationGroup> objects) {
    return putAllByIndex(r'relationGroupId', objects);
  }

  List<Id> putAllByRelationGroupIdSync(List<ProjectRelationGroup> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'relationGroupId', objects, saveLinks: saveLinks);
  }
}

extension ProjectRelationGroupQueryWhereSort
    on QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QWhere> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectRelationGroupQueryWhere
    on QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QWhereClause> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      relationGroupIdEqualTo(String relationGroupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'relationGroupId',
        value: [relationGroupId],
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      relationGroupIdNotEqualTo(String relationGroupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationGroupId',
              lower: [],
              upper: [relationGroupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationGroupId',
              lower: [relationGroupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationGroupId',
              lower: [relationGroupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationGroupId',
              lower: [],
              upper: [relationGroupId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      owningProjectIdEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'owningProjectId',
        value: [owningProjectId],
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      owningProjectIdNotEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [],
              upper: [owningProjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [owningProjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [owningProjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [],
              upper: [owningProjectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      linkedRelationTypeIdEqualTo(String linkedRelationTypeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedRelationTypeId',
        value: [linkedRelationTypeId],
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterWhereClause>
      linkedRelationTypeIdNotEqualTo(String linkedRelationTypeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedRelationTypeId',
              lower: [],
              upper: [linkedRelationTypeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedRelationTypeId',
              lower: [linkedRelationTypeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedRelationTypeId',
              lower: [linkedRelationTypeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedRelationTypeId',
              lower: [],
              upper: [linkedRelationTypeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProjectRelationGroupQueryFilter on QueryBuilder<ProjectRelationGroup,
    ProjectRelationGroup, QFilterCondition> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedRelationTypeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      linkedRelationTypeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedRelationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      linkedRelationTypeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedRelationTypeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedRelationTypeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> linkedRelationTypeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedRelationTypeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'owningProjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      owningProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      owningProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'owningProjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> owningProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationGroupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      relationGroupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      relationGroupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationGroupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> relationGroupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectRelationGroupQueryObject on QueryBuilder<ProjectRelationGroup,
    ProjectRelationGroup, QFilterCondition> {}

extension ProjectRelationGroupQueryLinks on QueryBuilder<ProjectRelationGroup,
    ProjectRelationGroup, QFilterCondition> {}

extension ProjectRelationGroupQuerySortBy
    on QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QSortBy> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByLinkedRelationTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRelationTypeId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByLinkedRelationTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRelationTypeId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByRelationGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationGroupId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByRelationGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationGroupId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectRelationGroupQuerySortThenBy
    on QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QSortThenBy> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByLinkedRelationTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRelationTypeId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByLinkedRelationTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRelationTypeId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByRelationGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationGroupId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByRelationGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationGroupId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectRelationGroupQueryWhereDistinct
    on QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct> {
  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByLinkedRelationTypeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedRelationTypeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByOwningProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'owningProjectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByRelationGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationGroupId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationGroup, ProjectRelationGroup, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProjectRelationGroupQueryProperty on QueryBuilder<
    ProjectRelationGroup, ProjectRelationGroup, QQueryProperty> {
  QueryBuilder<ProjectRelationGroup, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProjectRelationGroup, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationGroup, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ProjectRelationGroup, String, QQueryOperations>
      linkedRelationTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedRelationTypeId');
    });
  }

  QueryBuilder<ProjectRelationGroup, String, QQueryOperations>
      owningProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningProjectId');
    });
  }

  QueryBuilder<ProjectRelationGroup, String, QQueryOperations>
      relationGroupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationGroupId');
    });
  }

  QueryBuilder<ProjectRelationGroup, String?, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ProjectRelationGroup, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
