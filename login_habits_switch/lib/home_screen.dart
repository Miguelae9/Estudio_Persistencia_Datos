import 'package:flutter/material.dart';
import 'package:login_habits_switch/lateral_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitched = false;
  double sliderValue = 1;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitched = prefs.getBool('darkMode') ?? false;
      sliderValue = prefs.getDouble('dailyGoal') ?? 1;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isSwitched);
    await prefs.setDouble('dailyGoal', sliderValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      drawer: const Drawer(child: LateralMenu()),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Welcome to the Home Screen!",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Center(
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  _savePrefs();
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
                  _savePrefs();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
