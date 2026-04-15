import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/app/shell/app_shell_page.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:flutter/material.dart';

class EchoApp extends StatelessWidget {
  const EchoApp({super.key, this.projectRepository});

  static final ProjectRepository _defaultProjectRepository =
      LocalProjectRepository();

  final ProjectRepository? projectRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      theme: AppTheme.light(),
      home: AppShellPage(
        projectRepository: projectRepository ?? _defaultProjectRepository,
      ),
    );
  }
}
