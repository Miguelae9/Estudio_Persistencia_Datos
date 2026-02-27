import 'package:flutter/material.dart';
import 'package:login_habits_switch/lateral_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    bool isSwitched = false;

    double sliderValue = 1;

    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      drawer: const Drawer(child: LateralMenu()),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text("Welcome to the Home Screen!", style: TextStyle(fontSize: 20),)),
          Center(
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          ),
          Center(
            child: Slider(
              value: sliderValue,
              min: 1,
              max: 10,
              divisions: 9,
              label: sliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
