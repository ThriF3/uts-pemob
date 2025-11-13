import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            direction: Axis.horizontal,
            spacing: 12,
            runSpacing: 12,
            children: const [
              _InfoCardRevenue(title: 'Revenue', initialRevenue: 12345.0),
              _InfoCard(title: 'Users', value: '1,234'),
              _InfoCard(title: 'Active', value: '87%'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text('Activity ${i + 1}'),
                subtitle: const Text('Short description'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // added elevation
      child: SizedBox(
        width: 150,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCardRevenue extends StatefulWidget {
  final String title;
  final double initialRevenue;
  const _InfoCardRevenue({required this.title, required this.initialRevenue});

  @override
  State<_InfoCardRevenue> createState() => _InfoCardRevenueState();
}

class _InfoCardRevenueState extends State<_InfoCardRevenue> {
  late double _currentRevenue;
  late double _previousRevenue;
  Timer? _timer;
  final Random _rnd = Random();
  final List<double> _diffHistory = [];

  @override
  void initState() {
    super.initState();
    _currentRevenue = widget.initialRevenue;
    _previousRevenue = _currentRevenue;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    // simulate a small random change in revenue
    final double change = (_rnd.nextDouble() * 200) - 100; // -100 .. +100
    setState(() {
      _previousRevenue = _currentRevenue;
      _currentRevenue = (_currentRevenue + change).clamp(0, double.infinity);
      final diff = _currentRevenue - _previousRevenue;
      _diffHistory.add(diff);
      if (_diffHistory.length > 30) _diffHistory.removeAt(0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatMoney(double value) => '\$${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final diff = _currentRevenue - _previousRevenue;
    // push diff to history (keep last 30 seconds)
    _diffHistory.add(diff);
    if (_diffHistory.length > 30) _diffHistory.removeAt(0);
    final diffSign = diff >= 0 ? '+' : '-';
    final diffAbs = diff.abs();
    final diffText = '$diffSign\$${diffAbs.toStringAsFixed(0)}';
    final diffColor = diff > 0 ? Colors.green : (diff < 0 ? Colors.red : Colors.grey);

    return Card(
      elevation: 4.0,
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title and diff on one horizontal line, spaced between
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: Theme.of(context).textTheme.bodyMedium),
                  Row(
                    children: [
                      Icon(
                        diff > 0 ? Icons.arrow_upward : (diff < 0 ? Icons.arrow_downward : Icons.remove),
                        size: 16,
                        color: diffColor,
                      ),
                      const SizedBox(width: 6),
                      Text(diffText, style: TextStyle(color: diffColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: Text(_formatMoney(_currentRevenue), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  SizedBox(
                    width: 110,
                    height: 40,
                    child: CustomPaint(
                      painter: _SparklinePainter(List.of(_diffHistory), color: diff >= 0 ? Colors.green : Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparklinePainter(this.values, {this.color = Colors.green});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (values.isEmpty) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).abs();

    final dx = size.width / (values.length - 1 > 0 ? values.length - 1 : 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      double normalized;
      if (span == 0) {
        normalized = 0.5;
      } else {
        normalized = (v - minV) / span;
      }
      final x = i * dx;
      final y = size.height - (normalized * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    // draw baseline at middle
    final basePaint = Paint()..color = Colors.white24;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), basePaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.values != values || old.color != color;
}
