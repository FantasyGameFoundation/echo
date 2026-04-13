import 'package:flutter/material.dart';

class PrototypeModulePage extends StatelessWidget {
  const PrototypeModulePage({
    super.key,
    required this.title,
    required this.badge,
    required this.summary,
    required this.objective,
    required this.icon,
    required this.coreActions,
    required this.businessRules,
    required this.nextSteps,
  });

  final String title;
  final String badge;
  final String summary;
  final String objective;
  final IconData icon;
  final List<String> coreActions;
  final List<String> businessRules;
  final List<String> nextSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                Chip(label: Text(badge)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '模块目标',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      objective,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(summary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PrototypeSection(
              title: '核心动作',
              items: coreActions,
            ),
            const SizedBox(height: 16),
            _PrototypeSection(
              title: '关键规则',
              items: businessRules,
            ),
            const SizedBox(height: 16),
            _PrototypeSection(
              title: '后续实现焦点',
              items: nextSteps,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeSection extends StatelessWidget {
  const _PrototypeSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final item in items) ...[
              Text('• $item'),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
