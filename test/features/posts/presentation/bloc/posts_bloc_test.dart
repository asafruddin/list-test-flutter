import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_list_test/core/errors/failures.dart';
import 'package:showcase_list_test/features/posts/domain/entities/post.dart';
import 'package:showcase_list_test/features/posts/domain/entities/posts_result.dart';
import 'package:showcase_list_test/features/posts/domain/repositories/posts_repository.dart';
import 'package:showcase_list_test/features/posts/domain/usecases/get_posts.dart';
import 'package:showcase_list_test/features/posts/domain/usecases/refresh_posts.dart';
import 'package:showcase_list_test/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:showcase_list_test/features/posts/presentation/bloc/posts_event.dart';
import 'package:showcase_list_test/features/posts/presentation/bloc/posts_state.dart';

void main() {
  group('PostsBloc', () {
    const posts = [
      Post(userId: 1, id: 1, title: 'Post title', body: 'Post body'),
    ];

    late FakePostsRepository repository;

    PostsBloc buildBloc() => PostsBloc(
      getPosts: GetPosts(repository),
      refreshPosts: RefreshPosts(repository),
    );

    setUp(() {
      repository = FakePostsRepository(
        result: const PostsResult(posts: posts, isFromCache: false),
      );
    });

    blocTest<PostsBloc, PostsState>(
      'emits loading then loaded when posts load succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const PostsLoadRequested()),
      expect: () => const [
        PostsState(status: PostsStatus.loading),
        PostsState(
          status: PostsStatus.loaded,
          posts: posts,
          isFromCache: false,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits empty when repository returns no posts',
      build: () {
        repository = FakePostsRepository(
          result: const PostsResult(posts: [], isFromCache: false),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsLoadRequested()),
      expect: () => const [
        PostsState(status: PostsStatus.loading),
        PostsState(status: PostsStatus.empty),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits failure when repository throws',
      build: () {
        repository = FakePostsRepository(
          failure: const Failure('No connection'),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsLoadRequested()),
      expect: () => const [
        PostsState(status: PostsStatus.loading),
        PostsState(status: PostsStatus.failure, message: 'No connection'),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'refresh asks repository for fresh posts',
      build: buildBloc,
      act: (bloc) => bloc.add(const PostsRefreshRequested()),
      expect: () => const [
        PostsState(
          status: PostsStatus.loaded,
          posts: posts,
          isFromCache: false,
        ),
      ],
      verify: (_) {
        expect(repository.refreshCallCount, 1);
      },
    );
  });
}

class FakePostsRepository implements PostsRepository {
  FakePostsRepository({this.result, this.failure});

  PostsResult? result;
  Failure? failure;
  int getPostsCallCount = 0;
  int refreshCallCount = 0;

  @override
  Future<PostsResult> getPosts() async {
    getPostsCallCount++;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return result!;
  }

  @override
  Future<PostsResult> refreshPosts() async {
    refreshCallCount++;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return result!;
  }
}
