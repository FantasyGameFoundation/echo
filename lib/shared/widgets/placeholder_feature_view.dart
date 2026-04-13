import 'package:flutter/material.dart';

class PlaceholderFeatureView extends StatelessWidget {
  const PlaceholderFeatureView({
    super.key,
    required this.title,
    required this.description,
    required this.badge,
    required this.sections,
    this.icon = Icons.dashboard_outlined,
  });

  final String title;
  final String description;
  final String badge;
  final List<Widget> sections;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(badge)),
                      const Spacer(),
                      Icon(icon, size: 20),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Prototype')),
                      Chip(label: Text('Material')),
                      Chip(label: Text('Mobile-first')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前阶段',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '模块原型已接入应用，可直接浏览与对齐实现范围。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '这一页不直接实现业务逻辑，而是把当前分区中的模块、边界与后续工作方向用更具展陈感的方式组织起来。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('业务原型中'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('等待细化实现'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._withSpacing(sections),
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final result = <Widget>[];
    for (var index = 0; index < widgets.length; index++) {
      result.add(widgets[index]);
      if (index != widgets.length - 1) {
        result.add(const SizedBox(height: 18));
      }
    }
    return result;
  }
}
