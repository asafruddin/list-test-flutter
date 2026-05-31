import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/posts_result.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_local_data_source.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  const PostsRepositoryImpl({
    required PostsRemoteDataSource remoteDataSource,
    required PostsLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final PostsRemoteDataSource _remoteDataSource;
  final PostsLocalDataSource _localDataSource;

  /// Local-first strategy:
  /// 1. Return cached posts if available.
  /// 2. Cache is empty → fetch remote and cache the result.
  /// 3. Remote fails and local was empty → propagate error.
  @override
  Future<PostsResult> getPosts() async {
    final cachedPosts = await _readCachedPosts();
    if (cachedPosts.isNotEmpty) {
      return PostsResult(posts: cachedPosts, isFromCache: true);
    }

    try {
      final remotePosts = await _remoteDataSource.getPosts();
      await _localDataSource.cachePosts(remotePosts);
      return PostsResult(posts: remotePosts, isFromCache: false);
    } on Object catch (error) {
      throw Failure('Unable to load posts. $error');
    }
  }

  /// Remote-first strategy:
  /// 1. Fetch from remote and cache the result.
  /// 2. Remote fails → fall back to local cache.
  /// 3. Remote fails and local is also empty → propagate error.
  @override
  Future<PostsResult> refreshPosts() async {
    try {
      final remotePosts = await _remoteDataSource.getPosts();
      await _localDataSource.cachePosts(remotePosts);
      return PostsResult(posts: remotePosts, isFromCache: false);
    } on Object catch (error) {
      final cachedPosts = await _readCachedPosts();
      if (cachedPosts.isNotEmpty) {
        return PostsResult(posts: cachedPosts, isFromCache: true);
      }
      throw Failure('Unable to load posts. $error');
    }
  }

  Future<List<Post>> _readCachedPosts() async {
    try {
      return await _localDataSource.getCachedPosts();
    } on Object {
      return const [];
    }
  }
}
