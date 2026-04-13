import 'package:flutter/material.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.title,
    required this.badge,
    required this.description,
    required this.routeName,
    required this.icon,
    required this.highlights,
  });

  final String title;
  final String badge;
  final String description;
  final String routeName;
  final IconData icon;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Chip(label: Text(badge)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in highlights) Chip(label: Text(item)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed(routeName),
                    child: const Text('打开原型页'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('模块边界'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
