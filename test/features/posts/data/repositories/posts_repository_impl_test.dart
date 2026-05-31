import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_list_test/core/errors/exceptions.dart';
import 'package:showcase_list_test/features/posts/data/datasources/posts_local_data_source.dart';
import 'package:showcase_list_test/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:showcase_list_test/features/posts/data/models/post_model.dart';
import 'package:showcase_list_test/features/posts/data/repositories/posts_repository_impl.dart';

void main() {
  group('PostsRepositoryImpl', () {
    late FakePostsRemoteDataSource remoteDataSource;
    late FakePostsLocalDataSource localDataSource;
    late PostsRepositoryImpl repository;

    const cachedPosts = [
      PostModel(userId: 1, id: 1, title: 'Cached', body: 'Cached body'),
    ];
    const remotePosts = [
      PostModel(userId: 2, id: 2, title: 'Remote', body: 'Remote body'),
    ];

    setUp(() {
      remoteDataSource = FakePostsRemoteDataSource(remotePosts);
      localDataSource = FakePostsLocalDataSource();
      repository = PostsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );
    });

    test(
      'returns Hive posts without remote refetch when cache exists',
      () async {
        localDataSource.cachedPosts = cachedPosts;

        final result = await repository.getPosts();

        expect(result.posts, cachedPosts);
        expect(result.isFromCache, isTrue);
        expect(remoteDataSource.callCount, 0);
      },
    );

    test('fetches remote and saves Hive when local cache is empty', () async {
      final result = await repository.getPosts();

      expect(result.posts, remotePosts);
      expect(result.isFromCache, isFalse);
      expect(remoteDataSource.callCount, 1);
      expect(localDataSource.cachedPosts, remotePosts);
    });

    test('falls back to Hive when remote fails', () async {
      localDataSource.cachedPosts = cachedPosts;
      remoteDataSource.shouldThrow = true;

      final result = await repository.refreshPosts();

      expect(result.posts, cachedPosts);
      expect(result.isFromCache, isTrue);
      expect(remoteDataSource.callCount, 1);
    });

    test('force refresh calls remote and updates Hive', () async {
      localDataSource.cachedPosts = cachedPosts;

      final result = await repository.refreshPosts();

      expect(result.posts, remotePosts);
      expect(result.isFromCache, isFalse);
      expect(remoteDataSource.callCount, 1);
      expect(localDataSource.cachedPosts, remotePosts);
    });
  });
}

class FakePostsRemoteDataSource implements PostsRemoteDataSource {
  FakePostsRemoteDataSource(this.posts);

  final List<PostModel> posts;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<List<PostModel>> getPosts() async {
    callCount++;

    if (shouldThrow) {
      throw const ServerException('Remote failed');
    }

    return posts;
  }
}

class FakePostsLocalDataSource implements PostsLocalDataSource {
  List<PostModel> cachedPosts = const [];

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    cachedPosts = posts;
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    return cachedPosts;
  }

  @override
  Future<bool> hasCachedPosts() async {
    return cachedPosts.isNotEmpty;
  }
}
