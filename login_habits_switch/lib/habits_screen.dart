import 'package:flutter/material.dart';
import 'package:login_habits_switch/lateral_menu.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Habits Screen")),
      drawer: const Drawer(child: LateralMenu()),

      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Welcome to the Habits Screen!", style: TextStyle(fontSize: 20),)),
        ],
      ),
    );
  }
}
