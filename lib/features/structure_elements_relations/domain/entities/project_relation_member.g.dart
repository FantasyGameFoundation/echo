// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_relation_member.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectRelationMemberCollection on Isar {
  IsarCollection<ProjectRelationMember> get projectRelationMembers =>
      this.collection();
}

const ProjectRelationMemberSchema = CollectionSchema(
  name: r'ProjectRelationMember',
  id: -6975627491966972793,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'kind': PropertySchema(
      id: 1,
      name: r'kind',
      type: IsarType.string,
    ),
    r'linkedElementId': PropertySchema(
      id: 2,
      name: r'linkedElementId',
      type: IsarType.string,
    ),
    r'linkedPhotoPath': PropertySchema(
      id: 3,
      name: r'linkedPhotoPath',
      type: IsarType.string,
    ),
    r'linkedSourceElementId': PropertySchema(
      id: 4,
      name: r'linkedSourceElementId',
      type: IsarType.string,
    ),
    r'memberSortOrder': PropertySchema(
      id: 5,
      name: r'memberSortOrder',
      type: IsarType.long,
    ),
    r'owningGroupId': PropertySchema(
      id: 6,
      name: r'owningGroupId',
      type: IsarType.string,
    ),
    r'owningProjectId': PropertySchema(
      id: 7,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'relationMemberId': PropertySchema(
      id: 8,
      name: r'relationMemberId',
      type: IsarType.string,
    )
  },
  estimateSize: _projectRelationMemberEstimateSize,
  serialize: _projectRelationMemberSerialize,
  deserialize: _projectRelationMemberDeserialize,
  deserializeProp: _projectRelationMemberDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'relationMemberId': IndexSchema(
      id: -8566488008395290873,
      name: r'relationMemberId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'relationMemberId',
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
    r'owningGroupId': IndexSchema(
      id: -8493923256088727600,
      name: r'owningGroupId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'owningGroupId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _projectRelationMemberGetId,
  getLinks: _projectRelationMemberGetLinks,
  attach: _projectRelationMemberAttach,
  version: '3.1.0+1',
);

int _projectRelationMemberEstimateSize(
  ProjectRelationMember object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.linkedElementId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedPhotoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedSourceElementId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.owningGroupId.length * 3;
  bytesCount += 3 + object.owningProjectId.length * 3;
  bytesCount += 3 + object.relationMemberId.length * 3;
  return bytesCount;
}

void _projectRelationMemberSerialize(
  ProjectRelationMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.kind);
  writer.writeString(offsets[2], object.linkedElementId);
  writer.writeString(offsets[3], object.linkedPhotoPath);
  writer.writeString(offsets[4], object.linkedSourceElementId);
  writer.writeLong(offsets[5], object.memberSortOrder);
  writer.writeString(offsets[6], object.owningGroupId);
  writer.writeString(offsets[7], object.owningProjectId);
  writer.writeString(offsets[8], object.relationMemberId);
}

ProjectRelationMember _projectRelationMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectRelationMember();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.isarId = id;
  object.kind = reader.readString(offsets[1]);
  object.linkedElementId = reader.readStringOrNull(offsets[2]);
  object.linkedPhotoPath = reader.readStringOrNull(offsets[3]);
  object.linkedSourceElementId = reader.readStringOrNull(offsets[4]);
  object.memberSortOrder = reader.readLong(offsets[5]);
  object.owningGroupId = reader.readString(offsets[6]);
  object.owningProjectId = reader.readString(offsets[7]);
  object.relationMemberId = reader.readString(offsets[8]);
  return object;
}

P _projectRelationMemberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectRelationMemberGetId(ProjectRelationMember object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _projectRelationMemberGetLinks(
    ProjectRelationMember object) {
  return [];
}

void _projectRelationMemberAttach(
    IsarCollection<dynamic> col, Id id, ProjectRelationMember object) {
  object.isarId = id;
}

extension ProjectRelationMemberByIndex
    on IsarCollection<ProjectRelationMember> {
  Future<ProjectRelationMember?> getByRelationMemberId(
      String relationMemberId) {
    return getByIndex(r'relationMemberId', [relationMemberId]);
  }

  ProjectRelationMember? getByRelationMemberIdSync(String relationMemberId) {
    return getByIndexSync(r'relationMemberId', [relationMemberId]);
  }

  Future<bool> deleteByRelationMemberId(String relationMemberId) {
    return deleteByIndex(r'relationMemberId', [relationMemberId]);
  }

  bool deleteByRelationMemberIdSync(String relationMemberId) {
    return deleteByIndexSync(r'relationMemberId', [relationMemberId]);
  }

  Future<List<ProjectRelationMember?>> getAllByRelationMemberId(
      List<String> relationMemberIdValues) {
    final values = relationMemberIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'relationMemberId', values);
  }

  List<ProjectRelationMember?> getAllByRelationMemberIdSync(
      List<String> relationMemberIdValues) {
    final values = relationMemberIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'relationMemberId', values);
  }

  Future<int> deleteAllByRelationMemberId(List<String> relationMemberIdValues) {
    final values = relationMemberIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'relationMemberId', values);
  }

  int deleteAllByRelationMemberIdSync(List<String> relationMemberIdValues) {
    final values = relationMemberIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'relationMemberId', values);
  }

  Future<Id> putByRelationMemberId(ProjectRelationMember object) {
    return putByIndex(r'relationMemberId', object);
  }

  Id putByRelationMemberIdSync(ProjectRelationMember object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'relationMemberId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRelationMemberId(
      List<ProjectRelationMember> objects) {
    return putAllByIndex(r'relationMemberId', objects);
  }

  List<Id> putAllByRelationMemberIdSync(List<ProjectRelationMember> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'relationMemberId', objects,
        saveLinks: saveLinks);
  }
}

extension ProjectRelationMemberQueryWhereSort
    on QueryBuilder<ProjectRelationMember, ProjectRelationMember, QWhere> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectRelationMemberQueryWhere on QueryBuilder<ProjectRelationMember,
    ProjectRelationMember, QWhereClause> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      relationMemberIdEqualTo(String relationMemberId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'relationMemberId',
        value: [relationMemberId],
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      relationMemberIdNotEqualTo(String relationMemberId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationMemberId',
              lower: [],
              upper: [relationMemberId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationMemberId',
              lower: [relationMemberId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationMemberId',
              lower: [relationMemberId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationMemberId',
              lower: [],
              upper: [relationMemberId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      owningProjectIdEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'owningProjectId',
        value: [owningProjectId],
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      owningGroupIdEqualTo(String owningGroupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'owningGroupId',
        value: [owningGroupId],
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterWhereClause>
      owningGroupIdNotEqualTo(String owningGroupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningGroupId',
              lower: [],
              upper: [owningGroupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningGroupId',
              lower: [owningGroupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningGroupId',
              lower: [owningGroupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningGroupId',
              lower: [],
              upper: [owningGroupId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProjectRelationMemberQueryFilter on QueryBuilder<
    ProjectRelationMember, ProjectRelationMember, QFilterCondition> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedElementId',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedElementId',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedElementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedElementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedElementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedElementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedElementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedPhotoPath',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedPhotoPath',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedPhotoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedPhotoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedPhotoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedPhotoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedPhotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedPhotoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedPhotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedSourceElementId',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedSourceElementId',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedSourceElementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedSourceElementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedSourceElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      linkedSourceElementIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedSourceElementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedSourceElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> linkedSourceElementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedSourceElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> memberSortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberSortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> memberSortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberSortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> memberSortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberSortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> memberSortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberSortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'owningGroupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      owningGroupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'owningGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      owningGroupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'owningGroupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningGroupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'owningGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
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

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> owningProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationMemberId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      relationMemberIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationMemberId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
          QAfterFilterCondition>
      relationMemberIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationMemberId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationMemberId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember,
      QAfterFilterCondition> relationMemberIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationMemberId',
        value: '',
      ));
    });
  }
}

extension ProjectRelationMemberQueryObject on QueryBuilder<
    ProjectRelationMember, ProjectRelationMember, QFilterCondition> {}

extension ProjectRelationMemberQueryLinks on QueryBuilder<ProjectRelationMember,
    ProjectRelationMember, QFilterCondition> {}

extension ProjectRelationMemberQuerySortBy
    on QueryBuilder<ProjectRelationMember, ProjectRelationMember, QSortBy> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedElementId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedElementId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPhotoPath', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedSourceElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedSourceElementId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByLinkedSourceElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedSourceElementId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByMemberSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberSortOrder', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByMemberSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberSortOrder', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByOwningGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningGroupId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByOwningGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningGroupId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByRelationMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationMemberId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      sortByRelationMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationMemberId', Sort.desc);
    });
  }
}

extension ProjectRelationMemberQuerySortThenBy
    on QueryBuilder<ProjectRelationMember, ProjectRelationMember, QSortThenBy> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedElementId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedElementId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPhotoPath', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedSourceElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedSourceElementId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByLinkedSourceElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedSourceElementId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByMemberSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberSortOrder', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByMemberSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberSortOrder', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByOwningGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningGroupId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByOwningGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningGroupId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByRelationMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationMemberId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QAfterSortBy>
      thenByRelationMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationMemberId', Sort.desc);
    });
  }
}

extension ProjectRelationMemberQueryWhereDistinct
    on QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct> {
  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByLinkedElementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedElementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByLinkedPhotoPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedPhotoPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByLinkedSourceElementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedSourceElementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByMemberSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberSortOrder');
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByOwningGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'owningGroupId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByOwningProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'owningProjectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationMember, ProjectRelationMember, QDistinct>
      distinctByRelationMemberId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationMemberId',
          caseSensitive: caseSensitive);
    });
  }
}

extension ProjectRelationMemberQueryProperty on QueryBuilder<
    ProjectRelationMember, ProjectRelationMember, QQueryProperty> {
  QueryBuilder<ProjectRelationMember, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProjectRelationMember, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationMember, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<ProjectRelationMember, String?, QQueryOperations>
      linkedElementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedElementId');
    });
  }

  QueryBuilder<ProjectRelationMember, String?, QQueryOperations>
      linkedPhotoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedPhotoPath');
    });
  }

  QueryBuilder<ProjectRelationMember, String?, QQueryOperations>
      linkedSourceElementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedSourceElementId');
    });
  }

  QueryBuilder<ProjectRelationMember, int, QQueryOperations>
      memberSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberSortOrder');
    });
  }

  QueryBuilder<ProjectRelationMember, String, QQueryOperations>
      owningGroupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningGroupId');
    });
  }

  QueryBuilder<ProjectRelationMember, String, QQueryOperations>
      owningProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningProjectId');
    });
  }

  QueryBuilder<ProjectRelationMember, String, QQueryOperations>
      relationMemberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationMemberId');
    });
  }
}
