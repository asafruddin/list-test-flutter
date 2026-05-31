import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/posts/domain/repositories/posts_repository.dart';
import '../features/settings/presentation/cubit/theme_cubit.dart';
import 'app_dependencies.dart';
import 'app_flavor.dart';
import 'app_routes.dart';

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({
    required this.dependencies,
    required this.flavorConfig,
    super.key,
  });

  final AppDependencies dependencies;
  final AppFlavorConfig flavorConfig;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostsRepository>.value(
          value: dependencies.postsRepository,
        ),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(dependencies.themeLocalDataSource),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: flavorConfig.appTitle,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: themeMode,
              initialRoute: AppRoutes.posts,
              routes: AppRoutes.routes,
            );
          },
        ),
      ),
    );
  }
}
