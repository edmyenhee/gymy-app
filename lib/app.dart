import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_shell.dart';

class GymyApp extends StatelessWidget {
  const GymyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}
