import 'package:flutter/material.dart';

class SqfliteLoginScreen extends StatefulWidget {
  const SqfliteLoginScreen({super.key});

  @override
  State<SqfliteLoginScreen> createState() => _SqfliteLoginScreenState();
}

class _SqfliteLoginScreenState extends State<SqfliteLoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Sqflite"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement login logic here
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}