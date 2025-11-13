import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_1/theme/app_colors.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final Random _rnd = Random();
  Timer? _timer;
  int _highlightIndex = 0;

  late final List<Map<String, Object>> _contacts = List.generate(
    15,
    (i) => {
      'name': 'Contact ${i + 1}',
      'phone': '+62 812-0000-00${i + 1}',
      'image': 'https://picsum.photos/seed/contact$i/200',
      // randomize last contact within the last 7 days
      'lastContact': DateTime.now().subtract(Duration(
        days: _rnd.nextInt(7),
        hours: _rnd.nextInt(24),
        minutes: _rnd.nextInt(60),
      )),
    },
  );

  @override
  void initState() {
    super.initState();
    // start rotating highlighted last-contact every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _highlightIndex = _rnd.nextInt(_contacts.length);
        // update the chosen contact's lastContact to a new randomized timestamp
        _contacts[_highlightIndex]['lastContact'] = DateTime.now().subtract(Duration(
          days: _rnd.nextInt(7),
          hours: _rnd.nextInt(24),
          minutes: _rnd.nextInt(60),
        ));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header above the list
          const Text(
            'My Contacts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const Text(
            'Last Contacted',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),

          // show the currently highlighted (last contacted) contact
          Card(
            color: AppColors.primary,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundImage: NetworkImage(_contacts[_highlightIndex]['image'] as String)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_contacts[_highlightIndex]['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_contacts[_highlightIndex]['phone'] as String, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_timeAgo(_contacts[_highlightIndex]['lastContact'] as DateTime), style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${(_contacts[_highlightIndex]['lastContact'] as DateTime).toLocal()}'.split(' ')[0], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ListView takes the rest of the space
          Expanded(
            child: ListView.separated(
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final c = _contacts[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(c['image'] as String),
                  ),
                  title: Text(c['name'] as String),
                  subtitle: Text(c['phone'] as String),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 
