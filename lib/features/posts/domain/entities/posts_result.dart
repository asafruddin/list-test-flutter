import 'package:equatable/equatable.dart';

import 'post.dart';

class PostsResult extends Equatable {
  const PostsResult({required this.posts, required this.isFromCache});

  final List<Post> posts;
  final bool isFromCache;

  @override
  List<Object> get props => [posts, isFromCache];
}
