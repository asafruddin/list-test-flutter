import '../entities/posts_result.dart';
import '../repositories/posts_repository.dart';

class GetPosts {
  const GetPosts(this.repository);

  final PostsRepository repository;

  Future<PostsResult> call() {
    return repository.getPosts();
  }
}
