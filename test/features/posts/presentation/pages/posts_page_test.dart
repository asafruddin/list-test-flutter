import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_list_test/features/posts/domain/entities/post.dart';
import 'package:showcase_list_test/features/posts/domain/entities/posts_result.dart';
import 'package:showcase_list_test/features/posts/domain/repositories/posts_repository.dart';
import 'package:showcase_list_test/features/posts/presentation/pages/posts_page.dart';

void main() {
  group('PostsPage', () {
    testWidgets('renders post titles', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          repository: FakePostsRepository(
            result: const PostsResult(
              posts: [
                Post(
                  userId: 1,
                  id: 1,
                  title: 'A visible title',
                  body: 'A visible body',
                ),
              ],
              isFromCache: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A visible title'), findsOneWidget);
      expect(find.text('A visible body'), findsOneWidget);
    });

    testWidgets('renders loading state before repository completes', (
      tester,
    ) async {
      final repository = FakePostsRepository.pending();

      await tester.pumpWidget(_TestApp(repository: repository));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repository.complete(const PostsResult(posts: [], isFromCache: false));
      await tester.pump();
    });

    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(
        _TestApp(repository: FakePostsRepository(failure: 'Boom')),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Boom'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.repository});

  final PostsRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PostsRepository>.value(
      value: repository,
      child: const MaterialApp(home: PostsPage()),
    );
  }
}

class FakePostsRepository implements PostsRepository {
  FakePostsRepository({this.result, this.failure})
    : pendingResult = null,
      hasPendingResult = false;

  FakePostsRepository.pending()
    : result = null,
      failure = null,
      pendingResult = Completer<PostsResult>(),
      hasPendingResult = true;

  final PostsResult? result;
  final String? failure;
  final Completer<PostsResult>? pendingResult;
  final bool hasPendingResult;

  void complete(PostsResult result) {
    pendingResult?.complete(result);
  }

  @override
  Future<PostsResult> getPosts() async {
    if (hasPendingResult) {
      return pendingResult!.future;
    }

    final failure = this.failure;
    if (failure != null) {
      throw Exception(failure);
    }

    return result ?? const PostsResult(posts: [], isFromCache: false);
  }

  @override
  Future<PostsResult> refreshPosts() => getPosts();
}
