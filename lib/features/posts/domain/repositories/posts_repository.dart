import '../entities/posts_result.dart';

abstract interface class PostsRepository {
  /// Local-first: returns cached posts if available, otherwise fetches remote.
  /// Falls back to an error if local is empty and remote fails.
  Future<PostsResult> getPosts();

  /// Remote-first: fetches fresh data from remote.
  /// Falls back to local cache if remote fails; errors if both are empty.
  Future<PostsResult> refreshPosts();
}
