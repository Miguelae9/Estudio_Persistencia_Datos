import 'package:flutter/material.dart';
import 'package:practica_2_desde_0/screens/login_screen.dart';

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
      initialRoute: "/login",

      routes: {"/login": (context) => const LoginScreen()},
    );
  }
}
