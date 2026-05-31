import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../core/network/dio_client.dart';
import '../core/storage/hive_boxes.dart';
import '../features/posts/data/datasources/posts_local_data_source.dart';
import '../features/posts/data/datasources/posts_remote_data_source.dart';
import '../features/posts/data/repositories/posts_repository_impl.dart';
import '../features/posts/domain/repositories/posts_repository.dart';
import '../features/settings/data/theme_local_data_source.dart';
import 'app_flavor.dart';

class AppDependencies {
  const AppDependencies({
    required this.dio,
    required this.cacheStore,
    required this.postsRepository,
    required this.themeLocalDataSource,
  });

  final Dio dio;
  final CacheStore cacheStore;
  final PostsRepository postsRepository;
  final ThemeLocalDataSource themeLocalDataSource;

  static Future<AppDependencies> initialize(
    AppFlavorConfig flavorConfig,
  ) async {
    await Hive.initFlutter();

    final postsBox = await Hive.openBox<dynamic>(HiveBoxes.posts);
    final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);
    final cacheStore = await _createCacheStore();
    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: const [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
    );
    final dio = DioClient.create(cacheOptions, baseUrl: flavorConfig.baseUrl);
    final localDataSource = HivePostsLocalDataSource(postsBox);
    final remoteDataSource = DioPostsRemoteDataSource(
      dio: dio,
      cacheOptions: cacheOptions,
    );

    return AppDependencies(
      dio: dio,
      cacheStore: cacheStore,
      postsRepository: PostsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      ),
      themeLocalDataSource: ThemeLocalDataSource(settingsBox),
    );
  }

  static Future<CacheStore> _createCacheStore() async {
    if (kIsWeb) {
      return HiveCacheStore(null);
    }

    final cacheDirectory = await getApplicationCacheDirectory();
    return HiveCacheStore(cacheDirectory.path);
  }

  Future<void> dispose() async {
    dio.close();
    await cacheStore.close();
  }
}
