import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:persistencia_datos_ejercicios/screens/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
