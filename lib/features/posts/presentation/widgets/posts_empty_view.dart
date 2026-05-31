import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';

class PostsEmptyView extends StatelessWidget {
  const PostsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PostsBloc>().add(const PostsRefreshRequested());
      },
      child: ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: Text('No posts found.')),
        ],
      ),
    );
  }
}
