import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // =========================
  // SQFLITE - CREATE USER
  // =========================
  Future<int> createUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  // =========================
  // SQFLITE - READ ALL USERS
  // =========================
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // =========================
  // SQFLITE - READ ONE USER
  // =========================
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

  // =========================
  // SQFLITE - LOGIN
  // =========================
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

  // =========================
  // SQFLITE - EXAMPLE USERS
  // =========================
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

  bool rememberUser = false;

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
    await _loadRememberedUser();
  }

  // ==========================================
  // SHARED PREFERENCES - LOAD SAVED USER
  // Carga el usuario guardado anteriormente
  // ==========================================
  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedUsername = prefs.getString('saved_username');
    String? savedPassword = prefs.getString('saved_password');
    bool savedRemember = prefs.getBool('remember_user') ?? false;

    if (savedRemember) {
      setState(() {
        usernameController.text = savedUsername ?? '';
        passwordController.text = savedPassword ?? '';
        rememberUser = true;
      });

      // LOGIN AUTOMÁTICO
      if (savedUsername != null && savedPassword != null) {
        final user = await dbHelper.login(savedUsername, savedPassword);

        if (user != null && mounted) {
          Navigator.pushReplacementNamed(context, "/sqflite");
        }
      }
    }
  }

  // ==========================================
  // SHARED PREFERENCES - SAVE USER
  // Guarda usuario y contraseña si el checkbox
  // "Remember user" está activado
  // ==========================================
  Future<void> _saveRememberedUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
    await prefs.setBool('remember_user', true);
  }

  // ==========================================
  // SHARED PREFERENCES - CLEAR SAVED USER
  // Borra los datos guardados si el usuario
  // no quiere ser recordado
  // ==========================================
  Future<void> _clearRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_user', false);
  }

  // ==========================================
  // SCREEN LOGIC - REGISTER
  // Lee la pantalla, valida y llama a sqflite
  // ==========================================
  Future<void> _register() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill in all fields")));
      return;
    }

    final existingUser = await dbHelper.getUserByUsername(username);

    if (!mounted) return;

    if (existingUser != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Username already exists")));
      return;
    }

    await dbHelper.createUser(username, password);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User registered successfully")),
    );
  }

  // ==========================================
  // SCREEN LOGIC - LOGIN
  // Lee la pantalla, valida y llama a sqflite
  // ==========================================
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
      // ==========================================
      // SHARED PREFERENCES - SAVE OR CLEAR
      // Si rememberUser está activo, guarda datos.
      // Si no, borra los datos guardados.
      // ==========================================
      if (rememberUser) {
        await _saveRememberedUser(username, password);
      } else {
        await _clearRememberedUser();
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/sqflite");
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
            CheckboxListTile(
              title: const Text("Remember me"),
              value: rememberUser,
              onChanged: (value) {
                setState(() {
                  rememberUser = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _register, child: const Text("Register")),
          ],
        ),
      ),
    );
  }
}
