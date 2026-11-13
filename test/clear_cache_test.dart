import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/services/local_data_service.dart';

void main() {
  test('clearCache removes files and folders but keeps the directory', () async {
    final cache = await Directory.systemTemp.createTemp('cache_test_');
    final keep = await Directory.systemTemp.createTemp('keep_test_');
    addTearDown(() async {
      for (final d in [cache, keep]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });
    await File('${cache.path}/study-cafe-data.json').writeAsString('{}');
    await File('${cache.path}/studycafe_1.png').writeAsBytes([1, 2, 3]);
    final nested = await Directory('${cache.path}/plugin/sub').create(recursive: true);
    await File('${nested.path}/x.bin').writeAsBytes([9]);
    await File('${keep.path}/settings.db').writeAsString('keep me');

    final removed = await LocalDataService.clearCache(dirs: [cache]);

    expect(removed, 3);
    expect(await cache.exists(), isTrue);
    expect(cache.listSync(), isEmpty);
    // A directory that is not passed in is never touched.
    expect(File('${keep.path}/settings.db').existsSync(), isTrue);
  });

  test('clearCache on a missing directory does not throw', () async {
    final missing = Directory('${Directory.systemTemp.path}/does_not_exist_xyz');
    expect(await LocalDataService.clearCache(dirs: [missing]), 0);
  });
}
