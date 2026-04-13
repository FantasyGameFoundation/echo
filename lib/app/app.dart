import 'package:echo/app/router/app_router.dart';
import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/core/constants/app_constants.dart';
import 'package:echo/features/curation/presentation/pages/curation_page.dart';
import 'package:echo/features/project/presentation/pages/project_home_page.dart';
import 'package:echo/features/structure/presentation/pages/structure_page.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page.dart';
import 'package:flutter/material.dart';

class EchoApp extends StatefulWidget {
  const EchoApp({super.key});

  @override
  State<EchoApp> createState() => _EchoAppState();
}

class _EchoAppState extends State<EchoApp> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    ProjectHomePage(),
    StructurePage(),
    CurationPage(),
    TimelinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routes: AppRouter.routes,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _AtmosphereBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Row(
                      children: [
                        const _AtlasChip(label: 'ECHO / Prototype Atlas'),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            '摄影项目创作系统',
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _pages[_currentIndex]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            _NavButton(
                              label: '项目',
                              icon: Icons.home_outlined,
                              selected: _currentIndex == 0,
                              onPressed: () => setState(() => _currentIndex = 0),
                            ),
                            const SizedBox(width: 8),
                            _NavButton(
                              label: '结构',
                              icon: Icons.account_tree_outlined,
                              selected: _currentIndex == 1,
                              onPressed: () => setState(() => _currentIndex = 1),
                            ),
                            const SizedBox(width: 8),
                            _NavButton(
                              label: '整理',
                              icon: Icons.auto_stories_outlined,
                              selected: _currentIndex == 2,
                              onPressed: () => setState(() => _currentIndex = 2),
                            ),
                            const SizedBox(width: 8),
                            _NavButton(
                              label: '历程',
                              icon: Icons.timeline_outlined,
                              selected: _currentIndex == 3,
                              onPressed: () => setState(() => _currentIndex = 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(label),
      ],
    );

    return Expanded(
      child: selected
          ? FilledButton(
              onPressed: onPressed,
              child: buttonChild,
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: buttonChild,
            ),
    );
  }
}

class _AtlasChip extends StatelessWidget {
  const _AtlasChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AtmosphereBackground extends StatelessWidget {
  const _AtmosphereBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceContainerLowest,
            colors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _GlowOrb(
              size: 220,
              color: colors.primary.withValues(alpha: .10),
            ),
          ),
          Positioned(
            top: 140,
            left: -90,
            child: _GlowOrb(
              size: 260,
              color: colors.tertiary.withValues(alpha: .10),
            ),
          ),
          Positioned(
            bottom: -80,
            right: 20,
            child: _GlowOrb(
              size: 240,
              color: colors.secondary.withValues(alpha: .08),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
