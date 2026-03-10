import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // REGISTER
  Future<UserCredential> registerUser(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGIN
  Future<UserCredential> loginUser(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future<void> logoutUser() async {
    await auth.signOut();
  }

  // CURRENT USER
  User? getCurrentUser() {
    return auth.currentUser;
  }
}

class FirebaseLoginScreen extends StatefulWidget {
  const FirebaseLoginScreen({super.key});

  @override
  State<FirebaseLoginScreen> createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String message = "";

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = "Fill in all fields";
      });
      return;
    }

    try {
      await dbHelper.registerUser(email, password);
      setState(() {
        message = "Registration successful! Please log in.";
      });
    } catch (e) {
      setState(() {
        message = "Registration failed: ${e.toString()}";
      });
    }
  }

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = "Fill in all fields";
      });
      return;
    }

    try {
      await dbHelper.loginUser(email, password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/firebase");
    } catch (e) {
      setState(() {
        message = "Login failed: ${e.toString()}";
      });
    }
  }

  Future<void> _logout() async {
    await dbHelper.logoutUser();

    setState(() {
      message = "Sesión cerrada";
    });
  }

  Future<void> _showCurrentUser() async {
    User? user = dbHelper.getCurrentUser();
    setState(() {
      if (user != null) {
        message = "Current user: ${user.email}";
      } else {
        message = "No user is currently logged in.";
      }
    });
  }

  Future<void> _checkIfUserIsLoggedIn() async {
  User? user = dbHelper.getCurrentUser();

  if (user != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/firebase");
    });
  }
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            ElevatedButton(onPressed: _register, child: const Text("Register")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _logout, child: const Text("Logout")),
            ElevatedButton(
              onPressed: _showCurrentUser,
              child: const Text("Show Current User"),
            ),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
