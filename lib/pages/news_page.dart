import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => {
      'title': 'Headline ${i + 1}',
      'desc': 'This is a short description for news ${i + 1}.',
      'date': '2025-11-${10 + i}',
      'pub': 'Provider ${i + 1}',
      'image': 'https://picsum.photos/seed/news$i/400/200'
    });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(it['image'] as String, fit: BoxFit.cover, width: double.infinity, height: 160),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(it['desc'] as String),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(it['pub'] as String, style: Theme.of(context).textTheme.bodySmall),
                          Text(it['date'] as String, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
