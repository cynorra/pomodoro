import 'package:isar_community/isar.dart';

part 'cafe_item.g.dart';

@collection
class CafeItem {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String itemId;
  
  late String nameTr;
  late String nameEn;
  late int cost;
  late String iconCode;
  late bool isOwned;
  late int quantity;

  CafeItem({
    required this.itemId,
    required this.nameTr,
    required this.nameEn,
    required this.cost,
    required this.iconCode,
    this.isOwned = false,
    this.quantity = 0,
  });
}
