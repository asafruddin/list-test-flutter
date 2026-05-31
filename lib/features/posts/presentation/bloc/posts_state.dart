import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

enum PostsStatus { initial, loading, loaded, empty, failure }

enum PostSort { all, idAsc, idDesc, userIdAsc, userIdDesc }

class PostsState extends Equatable {
  final PostsStatus status;
  final String? message;
  final List<Post> posts;
  final bool isFromCache;
  final String? searchKeyword;
  final PostSort sort;
  final bool isDebouncing;

  const PostsState({
    this.status = PostsStatus.initial,
    this.message,
    this.posts = const [],
    this.isFromCache = false,
    this.searchKeyword,
    this.sort = PostSort.all,
    this.isDebouncing = false,
  });

  @override
  List<Object> get props => [
    status,
    message ?? '',
    posts,
    isFromCache,
    searchKeyword ?? '',
    sort,
    isDebouncing,
  ];

  PostsState copyWith({
    PostsStatus? status,
    String? message,
    List<Post>? posts,
    bool? isFromCache,
    String? searchKeyword,
    PostSort? sort,
    bool? isDebouncing,
  }) {
    return PostsState(
      status: status ?? this.status,
      message: message ?? this.message,
      posts: posts ?? this.posts,
      isFromCache: isFromCache ?? this.isFromCache,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      sort: sort ?? this.sort,
      isDebouncing: isDebouncing ?? this.isDebouncing,
    );
  }
}
