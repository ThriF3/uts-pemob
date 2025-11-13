import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/biodata_page.dart';
import 'pages/contact_page.dart';
import 'pages/calculator_page.dart';
import 'pages/weather_page.dart';
import 'pages/news_page.dart';
import 'widgets/sidebar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    BiodataPage(),
    ContactPage(),
    CalculatorPage(),
    WeatherPage(),
    NewsPage(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Biodata',
    'Contact',
    'Calculator',
    'Weather',
    'News',
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: isWide ? null : Drawer(child: Sidebar(selectedIndex: _selectedIndex, onSelect: (i) { Navigator.of(context).pop(); _onItemSelected(i); }, isCompact: true)),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 240,
              child: Sidebar(selectedIndex: _selectedIndex, onSelect: _onItemSelected),
            ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
