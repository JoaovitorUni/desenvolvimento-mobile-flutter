import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
      title: 'Cook Roulette',
      home: Home(),
  ));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cook Roulette"),
      ),
      body: const Center(
        child: Text(
          "Hello World!",
        ),
      ),
      bottomNavigationBar: NavigationBar(destinations: const [
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
      ]),
    );
  }
}
