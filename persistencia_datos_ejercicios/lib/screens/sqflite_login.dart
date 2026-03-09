import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = '${await getDatabasesPath()}/users.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE USER
  Future<int> createUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  // READ ALL USERS
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // READ ONE USER BY USERNAME
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  // LOGIN
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  // EXAMPLE USERS
  Future<void> exampleUsers() async {
    final db = await database;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    int count = result.first['count'] as int;

    if (count > 0) return;

    await db.transaction((txn) async {
      await txn.insert('users', {'username': 'admin', 'password': '1234'});

      await txn.insert('users', {'username': 'miguel', 'password': 'abcd'});
    });
  }
}

class SqfliteLoginScreen extends StatefulWidget {
  const SqfliteLoginScreen({super.key});

  @override
  State<SqfliteLoginScreen> createState() => _SqfliteLoginScreenState();
}

class _SqfliteLoginScreenState extends State<SqfliteLoginScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUsers();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _initUsers() async {
    await dbHelper.exampleUsers();
  }

  // LOGIN
  Future<void> _login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill in all fields")));
      return;
    }

    final user = await dbHelper.login(username, password);

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Sqflite")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
