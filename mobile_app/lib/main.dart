import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/debug_auth_screen.dart';
import 'features/design_preview/design_preview_screen.dart';
import 'shared/widgets/app_background.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) => AppBackground(child: child!),
      home: const DebugAuthScreen(),
      onGenerateRoute: (settings) {
        if (kDebugMode && settings.name == DesignPreviewScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const DesignPreviewScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
