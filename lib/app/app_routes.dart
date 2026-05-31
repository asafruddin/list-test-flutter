import 'package:flutter/widgets.dart';

import '../features/posts/presentation/pages/posts_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const posts = '/';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      posts: (_) => const PostsPage(),
      settings: (_) => const SettingsPage(),
    };
  }
}
