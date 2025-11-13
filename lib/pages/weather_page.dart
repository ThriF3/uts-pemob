import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _rnd = Random();
  late Timer _timer;

  // simulated current weather
  double _temp = 28.5;
  int _humidity = 72;
  double _wind = 4.2;
  String _description = 'Partly cloudy';

  // forecast for 7 days
  final List<Map<String, dynamic>> _forecast = List.generate(
    7,
    (i) => {
      'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i % 7],
      'temp': 20 + i + (i % 3 == 0 ? 2 : 0),
      'chance': 20 + i * 5,
    },
  );

  final List<Map<String, dynamic>> _otherCities = [
    {'city': 'New York', 'temp': 16.0, 'desc': 'Cloudy'},
    {'city': 'London', 'temp': 12.5, 'desc': 'Light rain'},
    {'city': 'Tokyo', 'temp': 22.0, 'desc': 'Sunny'},
    {'city': 'Sydney', 'temp': 26.3, 'desc': 'Partly cloudy'},
    {'city': 'Cairo', 'temp': 34.0, 'desc': 'Hot sun'},
  ];

  final now = DateTime.now();

  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final formattedDate =
      '${DateTime.now().day} ${months[DateTime.now().month - 1]} ${DateTime.now().year}';

  @override
  void initState() {
    super.initState();
    // update simulated current weather every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  void _tick() {
    setState(() {
      // small random walk for temp/humidity/wind
      _temp = (_temp + (_rnd.nextDouble() * 2 - 1)).clamp(-50.0, 60.0);
      _humidity = (_humidity + _rnd.nextInt(5) - 2).clamp(0, 100);
      _wind = double.parse(
        (_wind + (_rnd.nextDouble() * 0.6 - 0.3)).toStringAsFixed(1),
      );

      // occasionally rotate description
      final descriptions = [
        'Sunny',
        'Clear',
        'Partly cloudy',
        'Cloudy',
        'Light rain',
        'Heavy rain',
        'Thunderstorm',
      ];
      if (_rnd.nextDouble() < 0.15) {
        _description = descriptions[_rnd.nextInt(descriptions.length)];
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _weatherTypeColor(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('sun') || d.contains('clear')) return Colors.orange.shade300;
    if (d.contains('partly') || d.contains('cloud')) {
      return Colors.blueGrey.shade400;
    }
    if (d.contains('rain')) return Colors.indigo.shade200;
    if (d.contains('thunder') || d.contains('storm')) {
      return Colors.deepPurple.shade400;
    }
    return Colors.grey.shade500;
  }

  Color _tempColor(double temp) {
    if (temp < 20) return Colors.lightBlue.shade300; // cold
    if (temp < 25) return Colors.green.shade300; // pleasant
    if (temp < 30) return Colors.orange.shade300; // warm
    if (temp < 35) return Colors.red.shade300; // hot
    return Colors.deepOrange.shade400; // very hot
  }

  LinearGradient _tempGradient(double temp) {
    if (temp < 20) {
      // Cold
      return const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (temp < 25) {
      // Pleasant
      return const LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (temp < 30) {
      // Warm
      return const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (temp < 35) {
      // Hot
      return const LinearGradient(
        colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Very hot
      return const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFBF360C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                        'Updated: $formattedDate',
                      ),
                    ],
                  ),

                  SizedBox(width: 16),
                  Text(
                    'Current Weather',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    'Location: Your City',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  Card(
                    color: Color.fromARGB(0, 255, 255, 255),
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        color: Color.fromARGB(25, 255, 255, 255),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // icon area
                            Icon(
                              _description.toLowerCase().contains('sun')
                                  ? Icons.wb_sunny
                                  : Icons.wb_cloudy,
                              size: 48,
                              color: _weatherTypeColor(_description),
                            ),
                            const SizedBox(width: 16),

                            Chip(
                              label: Text(_description),
                              labelStyle: const TextStyle(fontSize: 12),
                              backgroundColor: _weatherTypeColor(_description),
                            ),
                            const SizedBox(width: 16),

                            // main values
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Temp:',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '${_temp.toStringAsFixed(1)} °C',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Humidity:',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '$_humidity%',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Temp:',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '$_wind m/s',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          const Text(
            '7-day Forecast',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 2),
              itemBuilder: (context, i) {
                final day = _forecast[i];
                final temp = (day['temp'] as num).toDouble();
                final chance = day['chance'];
                return Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _tempGradient(temp),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day['day'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text('${temp.toStringAsFixed(0)} °C'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text('Rain: $chance%'),
                          backgroundColor: Colors.blue.shade200,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Other Cities',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _otherCities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = _otherCities[i];
                final temp = (c['temp'] as num).toDouble();
                return Card(
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: _tempColor(temp),
                          child: Text(
                            c['city'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                c['city'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${temp.toStringAsFixed(1)} °C · ${c['desc']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _tempLabel(double t) {
    if (t < 20) return 'Cold';
    if (t < 25) return 'Pleasant';
    if (t < 30) return 'Warm';
    if (t < 35) return 'Hot';
    return 'Scorching';
  }
}
