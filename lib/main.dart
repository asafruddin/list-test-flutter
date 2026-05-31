import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'app/app_flavor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flavorConfig = AppFlavorConfig.current;
  final dependencies = await AppDependencies.initialize(flavorConfig);

  runApp(ShowcaseApp(dependencies: dependencies, flavorConfig: flavorConfig));
}
