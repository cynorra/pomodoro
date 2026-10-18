// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementCollection on Isar {
  IsarCollection<Achievement> get achievements => this.collection();
}

const AchievementSchema = CollectionSchema(
  name: r'Achievement',
  id: -1511299366265280024,
  properties: {
    r'achievementId': PropertySchema(
      id: 0,
      name: r'achievementId',
      type: IsarType.string,
    ),
    r'descriptionEn': PropertySchema(
      id: 1,
      name: r'descriptionEn',
      type: IsarType.string,
    ),
    r'descriptionTr': PropertySchema(
      id: 2,
      name: r'descriptionTr',
      type: IsarType.string,
    ),
    r'iconEmoji': PropertySchema(
      id: 3,
      name: r'iconEmoji',
      type: IsarType.string,
    ),
    r'isUnlocked': PropertySchema(
      id: 4,
      name: r'isUnlocked',
      type: IsarType.bool,
    ),
    r'nameEn': PropertySchema(
      id: 5,
      name: r'nameEn',
      type: IsarType.string,
    ),
    r'nameTr': PropertySchema(
      id: 6,
      name: r'nameTr',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 7,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _achievementEstimateSize,
  serialize: _achievementSerialize,
  deserialize: _achievementDeserialize,
  deserializeProp: _achievementDeserializeProp,
  idName: r'id',
  indexes: {
    r'achievementId': IndexSchema(
      id: 547487615361511857,
      name: r'achievementId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'achievementId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _achievementGetId,
  getLinks: _achievementGetLinks,
  attach: _achievementAttach,
  version: '3.1.0+1',
);

int _achievementEstimateSize(
  Achievement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.achievementId.length * 3;
  bytesCount += 3 + object.descriptionEn.length * 3;
  bytesCount += 3 + object.descriptionTr.length * 3;
  bytesCount += 3 + object.iconEmoji.length * 3;
  bytesCount += 3 + object.nameEn.length * 3;
  bytesCount += 3 + object.nameTr.length * 3;
  return bytesCount;
}

void _achievementSerialize(
  Achievement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.achievementId);
  writer.writeString(offsets[1], object.descriptionEn);
  writer.writeString(offsets[2], object.descriptionTr);
  writer.writeString(offsets[3], object.iconEmoji);
  writer.writeBool(offsets[4], object.isUnlocked);
  writer.writeString(offsets[5], object.nameEn);
  writer.writeString(offsets[6], object.nameTr);
  writer.writeDateTime(offsets[7], object.unlockedAt);
}

Achievement _achievementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Achievement(
    achievementId: reader.readString(offsets[0]),
    descriptionEn: reader.readString(offsets[1]),
    descriptionTr: reader.readString(offsets[2]),
    iconEmoji: reader.readString(offsets[3]),
    isUnlocked: reader.readBoolOrNull(offsets[4]) ?? false,
    nameEn: reader.readString(offsets[5]),
    nameTr: reader.readString(offsets[6]),
    unlockedAt: reader.readDateTimeOrNull(offsets[7]),
  );
  object.id = id;
  return object;
}

P _achievementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementGetId(Achievement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _achievementGetLinks(Achievement object) {
  return [];
}

void _achievementAttach(
    IsarCollection<dynamic> col, Id id, Achievement object) {
  object.id = id;
}

extension AchievementByIndex on IsarCollection<Achievement> {
  Future<Achievement?> getByAchievementId(String achievementId) {
    return getByIndex(r'achievementId', [achievementId]);
  }

  Achievement? getByAchievementIdSync(String achievementId) {
    return getByIndexSync(r'achievementId', [achievementId]);
  }

  Future<bool> deleteByAchievementId(String achievementId) {
    return deleteByIndex(r'achievementId', [achievementId]);
  }

  bool deleteByAchievementIdSync(String achievementId) {
    return deleteByIndexSync(r'achievementId', [achievementId]);
  }

  Future<List<Achievement?>> getAllByAchievementId(
      List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'achievementId', values);
  }

  List<Achievement?> getAllByAchievementIdSync(
      List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'achievementId', values);
  }

  Future<int> deleteAllByAchievementId(List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'achievementId', values);
  }

  int deleteAllByAchievementIdSync(List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'achievementId', values);
  }

  Future<Id> putByAchievementId(Achievement object) {
    return putByIndex(r'achievementId', object);
  }

  Id putByAchievementIdSync(Achievement object, {bool saveLinks = true}) {
    return putByIndexSync(r'achievementId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAchievementId(List<Achievement> objects) {
    return putAllByIndex(r'achievementId', objects);
  }

  List<Id> putAllByAchievementIdSync(List<Achievement> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'achievementId', objects, saveLinks: saveLinks);
  }
}

extension AchievementQueryWhereSort
    on QueryBuilder<Achievement, Achievement, QWhere> {
  QueryBuilder<Achievement, Achievement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementQueryWhere
    on QueryBuilder<Achievement, Achievement, QWhereClause> {
  QueryBuilder<Achievement, Achievement, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<Achievement, Achievement, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterWhereClause> idBetween(
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

  QueryBuilder<Achievement, Achievement, QAfterWhereClause>
      achievementIdEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'achievementId',
        value: [achievementId],
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterWhereClause>
      achievementIdNotEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AchievementQueryFilter
    on QueryBuilder<Achievement, Achievement, QFilterCondition> {
  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'achievementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'achievementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      achievementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descriptionEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descriptionEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descriptionEn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descriptionEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descriptionTr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descriptionTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descriptionTr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionTr',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      descriptionTrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descriptionTr',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconEmoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconEmoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      iconEmojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      isUnlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUnlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameEnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameEnMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameEn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameTrGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameTr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameTrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition> nameTrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameTr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameTrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameTr',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      nameTrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameTr',
        value: '',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AchievementQueryObject
    on QueryBuilder<Achievement, Achievement, QFilterCondition> {}

extension AchievementQueryLinks
    on QueryBuilder<Achievement, Achievement, QFilterCondition> {}

extension AchievementQuerySortBy
    on QueryBuilder<Achievement, Achievement, QSortBy> {
  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      sortByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByDescriptionEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionEn', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      sortByDescriptionEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionEn', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByDescriptionTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionTr', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      sortByDescriptionTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionTr', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByIconEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconEmoji', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByIconEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconEmoji', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByNameTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByNameTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementQuerySortThenBy
    on QueryBuilder<Achievement, Achievement, QSortThenBy> {
  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      thenByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByDescriptionEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionEn', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      thenByDescriptionEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionEn', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByDescriptionTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionTr', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy>
      thenByDescriptionTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionTr', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByIconEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconEmoji', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByIconEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconEmoji', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByNameTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByNameTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.desc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<Achievement, Achievement, QAfterSortBy> thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementQueryWhereDistinct
    on QueryBuilder<Achievement, Achievement, QDistinct> {
  QueryBuilder<Achievement, Achievement, QDistinct> distinctByAchievementId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'achievementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByDescriptionEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descriptionEn',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByDescriptionTr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descriptionTr',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByIconEmoji(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconEmoji', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUnlocked');
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByNameEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByNameTr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameTr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Achievement, Achievement, QDistinct> distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension AchievementQueryProperty
    on QueryBuilder<Achievement, Achievement, QQueryProperty> {
  QueryBuilder<Achievement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> achievementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievementId');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> descriptionEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descriptionEn');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> descriptionTrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descriptionTr');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> iconEmojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconEmoji');
    });
  }

  QueryBuilder<Achievement, bool, QQueryOperations> isUnlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUnlocked');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> nameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEn');
    });
  }

  QueryBuilder<Achievement, String, QQueryOperations> nameTrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameTr');
    });
  }

  QueryBuilder<Achievement, DateTime?, QQueryOperations> unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}
