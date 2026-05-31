import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/posts_result.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/refresh_posts.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc({required GetPosts getPosts, required RefreshPosts refreshPosts})
    : _getPosts = getPosts,
      _refreshPosts = refreshPosts,
      super(const PostsState()) {
    on<PostsLoadRequested>(_onLoadRequested);
    on<PostsRefreshRequested>(_onRefreshRequested);
    on<PostsSearchKeywordChanged>(_onSearchKeywordChanged);
    on<PostsSortChanged>(_onSortChanged);
  }

  final GetPosts _getPosts;
  final RefreshPosts _refreshPosts;

  List<Post> _allPosts = [];

  Future<void> _onLoadRequested(
    PostsLoadRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(state.copyWith(status: PostsStatus.loading));
    await _loadWith(emit, _getPosts.call);
  }

  Future<void> _onRefreshRequested(
    PostsRefreshRequested event,
    Emitter<PostsState> emit,
  ) async {
    await _loadWith(emit, _refreshPosts.call);
  }

  void _onSearchKeywordChanged(
    PostsSearchKeywordChanged event,
    Emitter<PostsState> emit,
  ) {
    if (event.isDebouncing) {
      // Keystroke received — show spinner, don't filter yet
      emit(state.copyWith(isDebouncing: true, searchKeyword: event.keyword));
    } else {
      // Debounce settled — apply filter
      emit(
        state.copyWith(
          isDebouncing: false,
          searchKeyword: event.keyword,
          posts: _computePosts(keyword: event.keyword, sort: state.sort),
        ),
      );
    }
  }

  void _onSortChanged(PostsSortChanged event, Emitter<PostsState> emit) {
    emit(
      state.copyWith(
        sort: event.sort,
        posts: _computePosts(
          keyword: state.searchKeyword ?? '',
          sort: event.sort,
        ),
      ),
    );
  }

  Future<void> _loadWith(
    Emitter<PostsState> emit,
    Future<PostsResult> Function() fetch,
  ) async {
    try {
      final result = await fetch();
      if (result.posts.isEmpty) {
        _allPosts = [];
        emit(state.copyWith(status: PostsStatus.empty, posts: []));
        return;
      }

      _allPosts = result.posts;
      emit(
        state.copyWith(
          status: PostsStatus.loaded,
          posts: _computePosts(
            keyword: state.searchKeyword ?? '',
            sort: state.sort,
          ),
          isFromCache: result.isFromCache,
        ),
      );
    } on Failure catch (error) {
      emit(state.copyWith(status: PostsStatus.failure, message: error.message));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: PostsStatus.failure,
          message: 'Unable to load posts. $error',
        ),
      );
    }
  }

  List<Post> _computePosts({required String keyword, required PostSort sort}) {
    final query = keyword.toLowerCase();
    var result = _allPosts.where((p) {
      if (query.isEmpty) return true;
      return p.title.toLowerCase().contains(query) ||
          p.body.toLowerCase().contains(query);
    }).toList();

    switch (sort) {
      case PostSort.all:
        break;
      case PostSort.idAsc:
        result.sort((a, b) => a.id.compareTo(b.id));
      case PostSort.idDesc:
        result.sort((a, b) => b.id.compareTo(a.id));
      case PostSort.userIdAsc:
        result.sort((a, b) => a.userId.compareTo(b.userId));
      case PostSort.userIdDesc:
        result.sort((a, b) => b.userId.compareTo(a.userId));
    }

    return result;
  }
}
