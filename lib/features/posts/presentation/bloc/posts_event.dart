import 'package:equatable/equatable.dart';
import 'package:showcase_list_test/features/posts/presentation/bloc/posts_state.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class PostsLoadRequested extends PostsEvent {
  const PostsLoadRequested();
}

class PostsRefreshRequested extends PostsEvent {
  const PostsRefreshRequested();
}

class PostsSearchKeywordChanged extends PostsEvent {
  final String keyword;
  final bool isDebouncing;

  const PostsSearchKeywordChanged(this.keyword, {this.isDebouncing = false});

  @override
  List<Object> get props => [keyword, isDebouncing];
}

class PostsSortChanged extends PostsEvent {
  final PostSort sort;

  const PostsSortChanged(this.sort);

  @override
  List<Object> get props => [sort];
}
