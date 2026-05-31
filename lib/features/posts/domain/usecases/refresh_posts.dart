import '../entities/posts_result.dart';
import '../repositories/posts_repository.dart';

class RefreshPosts {
  const RefreshPosts(this.repository);

  final PostsRepository repository;

  Future<PostsResult> call() {
    return repository.refreshPosts();
  }
}
