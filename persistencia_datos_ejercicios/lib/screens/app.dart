import 'package:flutter/material.dart';
import 'package:persistencia_datos_ejercicios/screens/auto_refresh.dart';
import 'package:persistencia_datos_ejercicios/screens/firebase_crud.dart';
import 'package:persistencia_datos_ejercicios/screens/home_screen.dart';
import 'package:persistencia_datos_ejercicios/screens/path_provider.dart';
import 'package:persistencia_datos_ejercicios/screens/sqflite_crud.dart';
import 'package:persistencia_datos_ejercicios/screens/sqflite_login.dart';

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
      initialRoute: "/firebase",

      routes: {
        "/home": (context) => const Dashboard(),
        "/refresh": (context) => const AutoRefresh(),
        "/path": (context) => const PathProvider(),
        "/sqflite": (context) => const PrestamoListScreen(),
        "/sqflite_login": (context) => const SqfliteLoginScreen(),
        "/firebase": (context) => const CrudFirebaseScreen(),
      },
    );
  }
}
