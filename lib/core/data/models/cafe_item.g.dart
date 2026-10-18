// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafe_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCafeItemCollection on Isar {
  IsarCollection<CafeItem> get cafeItems => this.collection();
}

const CafeItemSchema = CollectionSchema(
  name: r'CafeItem',
  id: -7680054088552900546,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.long,
    ),
    r'iconCode': PropertySchema(
      id: 1,
      name: r'iconCode',
      type: IsarType.string,
    ),
    r'isOwned': PropertySchema(
      id: 2,
      name: r'isOwned',
      type: IsarType.bool,
    ),
    r'itemId': PropertySchema(
      id: 3,
      name: r'itemId',
      type: IsarType.string,
    ),
    r'nameEn': PropertySchema(
      id: 4,
      name: r'nameEn',
      type: IsarType.string,
    ),
    r'nameTr': PropertySchema(
      id: 5,
      name: r'nameTr',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 6,
      name: r'quantity',
      type: IsarType.long,
    )
  },
  estimateSize: _cafeItemEstimateSize,
  serialize: _cafeItemSerialize,
  deserialize: _cafeItemDeserialize,
  deserializeProp: _cafeItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cafeItemGetId,
  getLinks: _cafeItemGetLinks,
  attach: _cafeItemAttach,
  version: '3.3.0',
);

int _cafeItemEstimateSize(
  CafeItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.iconCode.length * 3;
  bytesCount += 3 + object.itemId.length * 3;
  bytesCount += 3 + object.nameEn.length * 3;
  bytesCount += 3 + object.nameTr.length * 3;
  return bytesCount;
}

void _cafeItemSerialize(
  CafeItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cost);
  writer.writeString(offsets[1], object.iconCode);
  writer.writeBool(offsets[2], object.isOwned);
  writer.writeString(offsets[3], object.itemId);
  writer.writeString(offsets[4], object.nameEn);
  writer.writeString(offsets[5], object.nameTr);
  writer.writeLong(offsets[6], object.quantity);
}

CafeItem _cafeItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CafeItem(
    cost: reader.readLong(offsets[0]),
    iconCode: reader.readString(offsets[1]),
    isOwned: reader.readBoolOrNull(offsets[2]) ?? false,
    itemId: reader.readString(offsets[3]),
    nameEn: reader.readString(offsets[4]),
    nameTr: reader.readString(offsets[5]),
    quantity: reader.readLongOrNull(offsets[6]) ?? 0,
  );
  object.id = id;
  return object;
}

P _cafeItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cafeItemGetId(CafeItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cafeItemGetLinks(CafeItem object) {
  return [];
}

void _cafeItemAttach(IsarCollection<dynamic> col, Id id, CafeItem object) {
  object.id = id;
}

extension CafeItemByIndex on IsarCollection<CafeItem> {
  Future<CafeItem?> getByItemId(String itemId) {
    return getByIndex(r'itemId', [itemId]);
  }

  CafeItem? getByItemIdSync(String itemId) {
    return getByIndexSync(r'itemId', [itemId]);
  }

  Future<bool> deleteByItemId(String itemId) {
    return deleteByIndex(r'itemId', [itemId]);
  }

  bool deleteByItemIdSync(String itemId) {
    return deleteByIndexSync(r'itemId', [itemId]);
  }

  Future<List<CafeItem?>> getAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itemId', values);
  }

  List<CafeItem?> getAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itemId', values);
  }

  Future<int> deleteAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itemId', values);
  }

  int deleteAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itemId', values);
  }

  Future<Id> putByItemId(CafeItem object) {
    return putByIndex(r'itemId', object);
  }

  Id putByItemIdSync(CafeItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'itemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItemId(List<CafeItem> objects) {
    return putAllByIndex(r'itemId', objects);
  }

  List<Id> putAllByItemIdSync(List<CafeItem> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'itemId', objects, saveLinks: saveLinks);
  }
}

extension CafeItemQueryWhereSort on QueryBuilder<CafeItem, CafeItem, QWhere> {
  QueryBuilder<CafeItem, CafeItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CafeItemQueryWhere on QueryBuilder<CafeItem, CafeItem, QWhereClause> {
  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> itemIdEqualTo(
      String itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterWhereClause> itemIdNotEqualTo(
      String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CafeItemQueryFilter
    on QueryBuilder<CafeItem, CafeItem, QFilterCondition> {
  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> costEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> costGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> costLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> costBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> iconCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> isOwnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOwned',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnEqualTo(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnGreaterThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnLessThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnBetween(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnStartsWith(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnEndsWith(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnContains(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnMatches(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrEqualTo(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrGreaterThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrLessThan(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrBetween(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrStartsWith(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrEndsWith(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrContains(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrMatches(
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

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameTr',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> nameTrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameTr',
        value: '',
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> quantityEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CafeItemQueryObject
    on QueryBuilder<CafeItem, CafeItem, QFilterCondition> {}

extension CafeItemQueryLinks
    on QueryBuilder<CafeItem, CafeItem, QFilterCondition> {}

extension CafeItemQuerySortBy on QueryBuilder<CafeItem, CafeItem, QSortBy> {
  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByIsOwned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOwned', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByIsOwnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOwned', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByNameTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByNameTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension CafeItemQuerySortThenBy
    on QueryBuilder<CafeItem, CafeItem, QSortThenBy> {
  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByIsOwned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOwned', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByIsOwnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOwned', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByNameTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByNameTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTr', Sort.desc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension CafeItemQueryWhereDistinct
    on QueryBuilder<CafeItem, CafeItem, QDistinct> {
  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cost');
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByIconCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByIsOwned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOwned');
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByItemId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByNameEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByNameTr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameTr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CafeItem, CafeItem, QDistinct> distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }
}

extension CafeItemQueryProperty
    on QueryBuilder<CafeItem, CafeItem, QQueryProperty> {
  QueryBuilder<CafeItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CafeItem, int, QQueryOperations> costProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cost');
    });
  }

  QueryBuilder<CafeItem, String, QQueryOperations> iconCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCode');
    });
  }

  QueryBuilder<CafeItem, bool, QQueryOperations> isOwnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOwned');
    });
  }

  QueryBuilder<CafeItem, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<CafeItem, String, QQueryOperations> nameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEn');
    });
  }

  QueryBuilder<CafeItem, String, QQueryOperations> nameTrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameTr');
    });
  }

  QueryBuilder<CafeItem, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }
}
