import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

abstract interface class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class DioPostsRemoteDataSource implements PostsRemoteDataSource {
  const DioPostsRemoteDataSource({
    required Dio dio,
    required CacheOptions cacheOptions,
  }) : _dio = dio,
       _cacheOptions = cacheOptions;

  final Dio _dio;
  final CacheOptions _cacheOptions;

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.postsPath,
        options: _cacheOptions
            .copyWith(policy: CachePolicy.refresh)
            .toOptions(),
      );
      final data = response.data;

      if (data == null) {
        throw const ServerException('Posts response was empty.');
      }

      return data
          .whereType<Map>()
          .map((post) => PostModel.fromJson(Map<String, dynamic>.from(post)))
          .toList(growable: false);
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw ServerException('Failed to fetch posts: ${error.message}');
    } on Object catch (error) {
      throw ServerException('Failed to parse posts: $error');
    }
  }
}
