import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isCompact;

  const Sidebar({super.key, required this.selectedIndex, required this.onSelect, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
      _NavItem(icon: Icons.person, label: 'Biodata'),
      _NavItem(icon: Icons.contact_phone, label: 'Contact'),
      _NavItem(icon: Icons.calculate, label: 'Calculator'),
      _NavItem(icon: Icons.cloud, label: 'Weather'),
      _NavItem(icon: Icons.article, label: 'News'),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const FlutterLogo(size: 36),
                  if (!isCompact) const SizedBox(width: 12),
                  if (!isCompact)
                    const Text('MyApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(),
            ...List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == selectedIndex;
              return ListTile(
                leading: Icon(item.icon, color: selected ? Theme.of(context).colorScheme.primary : null),
                title: Text(item.label),
                selected: selected,
                onTap: () => onSelect(i),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('v1.0', style: Theme.of(context).textTheme.bodySmall),
            )
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
