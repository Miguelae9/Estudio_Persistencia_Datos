import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoRefresh extends StatefulWidget {
  const AutoRefresh({super.key});

  @override
  State<AutoRefresh> createState() => _AutoRefreshState();
}

class _AutoRefreshState extends State<AutoRefresh> {
  bool _isSwitched = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt("counter") ?? 0;
    setState(() {
      counter = saved;
    });
  }

  Future<void> _saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("counter", value);
  }

  Stream<int> _counterStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      counter = counter + 1;
      yield counter;
    }
  }

  @override
  void dispose() {
    _saveCounter(counter); // guarda aunque salgas sin apagar el switch
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auto Refresh")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Switch(
              value: _isSwitched,
              onChanged: (value) {
                setState(() {
                  _isSwitched = value;
                });
                if (!value) {
                  _saveCounter(counter);
                }
              },
            ),
            if (_isSwitched)
              StreamBuilder<int>(
                stream: _counterStream(),
                builder: (context, snapshot) {
                  final number = snapshot.data ?? 0;
                  return Text("Counter: $number");
                },
              ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/home"),
              child: Text("Go to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
