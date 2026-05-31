import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/debouncer.dart';
import '../../../widgets/offline_banner.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import 'post_card.dart';

class PostsLoadedView extends StatelessWidget {
  const PostsLoadedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(
      buildWhen: (prev, curr) =>
          prev.posts != curr.posts ||
          prev.sort != curr.sort ||
          prev.isFromCache != curr.isFromCache ||
          prev.searchKeyword != curr.searchKeyword ||
          prev.isDebouncing != curr.isDebouncing,
      builder: (context, state) {
        final sort = state.sort;
        final posts = state.posts;
        final isUserIdSort =
            sort == PostSort.userIdAsc || sort == PostSort.userIdDesc;
        final isIdSort = sort == PostSort.idAsc || sort == PostSort.idDesc;

        return Column(
          children: [
            const _PostsSearchBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Sort:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: sort == PostSort.all,
                            onSelected: (_) => context.read<PostsBloc>().add(
                              const PostsSortChanged(PostSort.all),
                            ),
                          ),
                          FilterChip(
                            showCheckmark: false,
                            avatar: isUserIdSort
                                ? Icon(
                                    sort == PostSort.userIdAsc
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  )
                                : null,
                            label: const Text('User ID'),
                            selected: isUserIdSort,
                            onSelected: (_) {
                              final next = sort == PostSort.userIdAsc
                                  ? PostSort.userIdDesc
                                  : PostSort.userIdAsc;
                              context.read<PostsBloc>().add(
                                PostsSortChanged(next),
                              );
                            },
                          ),
                          FilterChip(
                            showCheckmark: false,
                            avatar: isIdSort
                                ? Icon(
                                    sort == PostSort.idAsc
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  )
                                : null,
                            label: const Text('ID'),
                            selected: isIdSort,
                            onSelected: (_) {
                              final next = sort == PostSort.idAsc
                                  ? PostSort.idDesc
                                  : PostSort.idAsc;
                              context.read<PostsBloc>().add(
                                PostsSortChanged(next),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.isDebouncing)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (posts.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results for "${state.searchKeyword}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PostsBloc>().add(
                      const PostsRefreshRequested(),
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: posts.length + (state.isFromCache ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (state.isFromCache && index == 0) {
                        return const OfflineBanner();
                      }
                      final postIndex = state.isFromCache ? index - 1 : index;
                      return PostCard(post: posts[postIndex]);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PostsSearchBar extends StatefulWidget {
  const _PostsSearchBar();

  @override
  State<_PostsSearchBar> createState() => _PostsSearchBarState();
}

class _PostsSearchBarState extends State<_PostsSearchBar> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 300));

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Immediately signal debouncing — BLoC shows spinner
    context.read<PostsBloc>().add(
      PostsSearchKeywordChanged(value, isDebouncing: true),
    );
    // After 300 ms silence — apply the actual search
    _debouncer.run(() {
      if (mounted) {
        context.read<PostsBloc>().add(PostsSearchKeywordChanged(value));
      }
    });
  }

  void _clearSearch() {
    _debouncer.cancel();
    _controller.clear();
    context.read<PostsBloc>().add(const PostsSearchKeywordChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          return TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear',
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          );
        },
      ),
    );
  }
}
