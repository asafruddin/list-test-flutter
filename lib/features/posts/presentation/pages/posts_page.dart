import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/refresh_posts.dart';
import '../../../widgets/loading_view.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/posts_empty_view.dart';
import '../widgets/posts_failure_view.dart';
import '../widgets/posts_loaded_view.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostsBloc(
        getPosts: GetPosts(context.read<PostsRepository>()),
        refreshPosts: RefreshPosts(context.read<PostsRepository>()),
      )..add(const PostsLoadRequested()),
      child: const _PostsView(),
    );
  }
}

class _PostsView extends StatelessWidget {
  const _PostsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return switch (state.status) {
            PostsStatus.initial || PostsStatus.loading => const LoadingView(),
            PostsStatus.loaded => const PostsLoadedView(),
            PostsStatus.empty => const PostsEmptyView(),
            PostsStatus.failure => PostsFailureView(
              message: state.message ?? 'An error occurred.',
            ),
          };
        },
      ),
    );
  }
}
