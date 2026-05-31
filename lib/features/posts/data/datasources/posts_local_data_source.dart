import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

abstract interface class PostsLocalDataSource {
  Future<List<PostModel>> getCachedPosts();

  Future<void> cachePosts(List<PostModel> posts);

  Future<bool> hasCachedPosts();
}

class HivePostsLocalDataSource implements PostsLocalDataSource {
  HivePostsLocalDataSource(this._box);

  static const _postsKey = 'posts';
  static const _cachedAtKey = 'cached_at';

  final Box<dynamic> _box;

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final rawPosts = _box.get(_postsKey);
      if (rawPosts is! List || rawPosts.isEmpty) {
        return const [];
      }

      return rawPosts
          .whereType<Map>()
          .map((post) => PostModel.fromJson(Map<String, dynamic>.from(post)))
          .toList(growable: false);
    } on Object catch (error) {
      throw CacheException('Failed to read cached posts: $error');
    }
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      await _box.put(
        _postsKey,
        posts.map((post) => post.toJson()).toList(growable: false),
      );
      await _box.put(_cachedAtKey, DateTime.now().toIso8601String());
    } on Object catch (error) {
      throw CacheException('Failed to cache posts: $error');
    }
  }

  @override
  Future<bool> hasCachedPosts() async {
    final rawPosts = _box.get(_postsKey);
    return rawPosts is List && rawPosts.isNotEmpty;
  }
}
