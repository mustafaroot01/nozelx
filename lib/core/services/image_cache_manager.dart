import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager extends CacheManager {
  static const key = 'appImageCache';
  static final AppImageCacheManager _instance = AppImageCacheManager._();
  factory AppImageCacheManager() => _instance;

  AppImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  // مسح كاش صورة معينة
  static Future<void> evict(String url) async {
    await _instance.removeFile(url);
  }

  // مسح كاش كامل
  static Future<void> clearAll() async {
    await _instance.emptyCache();
  }
}
