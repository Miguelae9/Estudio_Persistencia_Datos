import 'package:flutter/material.dart';
import 'package:login_habits_switch/habits_screen.dart';
import 'package:login_habits_switch/home_screen.dart';
import 'package:login_habits_switch/login_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
      initialRoute: "/home",

      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
        "/habits": (context) => const HabitsScreen(),
      },
    );
  }
}
