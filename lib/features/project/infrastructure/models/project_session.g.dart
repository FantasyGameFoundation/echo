// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectSessionCollection on Isar {
  IsarCollection<ProjectSession> get projectSessions => this.collection();
}

const ProjectSessionSchema = CollectionSchema(
  name: r'ProjectSession',
  id: -1256533418106822389,
  properties: {
    r'currentProjectId': PropertySchema(
      id: 0,
      name: r'currentProjectId',
      type: IsarType.string,
    )
  },
  estimateSize: _projectSessionEstimateSize,
  serialize: _projectSessionSerialize,
  deserialize: _projectSessionDeserialize,
  deserializeProp: _projectSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _projectSessionGetId,
  getLinks: _projectSessionGetLinks,
  attach: _projectSessionAttach,
  version: '3.1.0+1',
);

int _projectSessionEstimateSize(
  ProjectSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.currentProjectId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _projectSessionSerialize(
  ProjectSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currentProjectId);
}

ProjectSession _projectSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectSession();
  object.currentProjectId = reader.readStringOrNull(offsets[0]);
  object.id = id;
  return object;
}

P _projectSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectSessionGetId(ProjectSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _projectSessionGetLinks(ProjectSession object) {
  return [];
}

void _projectSessionAttach(
    IsarCollection<dynamic> col, Id id, ProjectSession object) {
  object.id = id;
}

extension ProjectSessionQueryWhereSort
    on QueryBuilder<ProjectSession, ProjectSession, QWhere> {
  QueryBuilder<ProjectSession, ProjectSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectSessionQueryWhere
    on QueryBuilder<ProjectSession, ProjectSession, QWhereClause> {
  QueryBuilder<ProjectSession, ProjectSession, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectSessionQueryFilter
    on QueryBuilder<ProjectSession, ProjectSession, QFilterCondition> {
  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentProjectId',
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentProjectId',
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentProjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentProjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      currentProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectSessionQueryObject
    on QueryBuilder<ProjectSession, ProjectSession, QFilterCondition> {}

extension ProjectSessionQueryLinks
    on QueryBuilder<ProjectSession, ProjectSession, QFilterCondition> {}

extension ProjectSessionQuerySortBy
    on QueryBuilder<ProjectSession, ProjectSession, QSortBy> {
  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy>
      sortByCurrentProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy>
      sortByCurrentProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProjectId', Sort.desc);
    });
  }
}

extension ProjectSessionQuerySortThenBy
    on QueryBuilder<ProjectSession, ProjectSession, QSortThenBy> {
  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy>
      thenByCurrentProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy>
      thenByCurrentProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProjectSession, ProjectSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension ProjectSessionQueryWhereDistinct
    on QueryBuilder<ProjectSession, ProjectSession, QDistinct> {
  QueryBuilder<ProjectSession, ProjectSession, QDistinct>
      distinctByCurrentProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentProjectId',
          caseSensitive: caseSensitive);
    });
  }
}

extension ProjectSessionQueryProperty
    on QueryBuilder<ProjectSession, ProjectSession, QQueryProperty> {
  QueryBuilder<ProjectSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProjectSession, String?, QQueryOperations>
      currentProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentProjectId');
    });
  }
}
