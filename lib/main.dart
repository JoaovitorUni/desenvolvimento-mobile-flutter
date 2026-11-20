import 'package:flutter/material.dart';
import 'package:cook_roulette/pages/home.dart';
import 'package:cook_roulette/pages/roulette.dart';

void main() {
  runApp(const MaterialApp(title: 'Cook Roulette', home: Main()));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> {
  int _currentPage = 0;

  final List<Widget> _pages = const [HomePage(), RoulettePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cook Roulette")),
      body: _pages[_currentPage],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPage,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.casino),
            icon: Icon(Icons.casino),
            label: "Roleta",
          ),
        ],
      ),
    );
  }
}
