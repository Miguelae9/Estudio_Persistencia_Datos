import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApiExample(),
    );
  }
}

class ApiExample extends StatefulWidget {
  const ApiExample({super.key});

  @override
  ApiExampleState createState() => ApiExampleState();
}

class ApiExampleState extends State<ApiExample> {
  String _data = "Esperando datos...";

  // Función para obtener datos de una API
  Future<void> accesoDatos() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/3'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _data = jsonData['title'];
        });
      } else {
        setState(() {
          _data = "Error al obtener los datos: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _data = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ejemplo Asíncrono")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _data,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: accesoDatos,
              child: const Text("Obtener Datos"),
            ),
          ],
        ),
      ),
    );
  }
}
