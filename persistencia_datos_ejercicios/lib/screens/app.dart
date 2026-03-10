import 'package:flutter/material.dart';
import 'package:persistencia_datos_ejercicios/screens/auto_refresh.dart';
import 'package:persistencia_datos_ejercicios/screens/firebase_crud.dart';
import 'package:persistencia_datos_ejercicios/screens/firebase_login.dart';
import 'package:persistencia_datos_ejercicios/screens/home_screen.dart';
import 'package:persistencia_datos_ejercicios/screens/json_assets.dart';
import 'package:persistencia_datos_ejercicios/screens/modo_oscuro_shared_preferences.dart';
import 'package:persistencia_datos_ejercicios/screens/path_provider.dart';
import 'package:persistencia_datos_ejercicios/screens/sqflite_crud.dart';
import 'package:persistencia_datos_ejercicios/screens/sqflite_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  // CARGAR EL TEMA GUARDADO
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // CAMBIAR EL TEMA
  void changeTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/json",

      // TEMA CLARO
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      // ELEGIR ENTRE TEMA CLARO Y OSCURO
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      routes: {
        "/home": (context) => const Dashboard(),
        "/json": (context) => const ClientesScreen(),
        "/refresh": (context) => const AutoRefresh(),
        "/path": (context) => const PathProvider(),
        "/sqflite": (context) => const PrestamoListScreen(),
        "/sqflite_login": (context) => const SqfliteLoginScreen(),
        "/firebase": (context) => const CrudFirebaseScreen(),
        "/firebase_login": (context) => const FirebaseLoginScreen(),

        // A ESTA SCREEN LE PASAMOS EL VALOR Y LA FUNCION
        "/modo_oscuro": (context) => ModoOscuroSharedPreferences(
          isDarkMode: isDarkMode,
          onThemeChanged: changeTheme,
        ),
      },
    );
  }
}
