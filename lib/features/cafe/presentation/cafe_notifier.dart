import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/cafe_item.dart';

final cafeItemsProvider = FutureProvider<List<CafeItem>>((ref) async {
  return await DatabaseService.instance.cafeItems.where().findAll();
});
