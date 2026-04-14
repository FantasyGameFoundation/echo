import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/features/prototype/prototype_shell_page.dart';
import 'package:flutter/material.dart';

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      theme: AppTheme.light(),
      home: const PrototypeShellPage(),
    );
  }
}
