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
    String path = '${await getDatabasesPath()}/my_database.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE prestamo (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            title TEXT NOT NULL,
            days INTEGER NOT NULL,
            status INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // CRUD

  // CREATE
  Future<int> insertPrestamo(Map<String, dynamic> prestamo) async {
    final db = await database;
    return await db.insert('prestamo', prestamo);
  }

  // READ ALL
  Future<List<Map<String, dynamic>>> getPrestamos() async {
    final db = await database;
    return await db.query('prestamo');
  }

  // READ ONE
  Future<Map<String, dynamic>?> getPrestamoById(int id) async {
    final db = await database;
    final result = await db.query('prestamo', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return result.first;
  }

  // UPDATE
  Future<void> updatePrestamo(
    int id,
    Map<String, dynamic> updatedPrestamo,
  ) async {
    final db = await database;
    await db.update(
      'prestamo',
      updatedPrestamo,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<void> deletePrestamo(int id) async {
    final db = await database;
    await db.delete('prestamo', where: 'id = ?', whereArgs: [id]);
  }

  // EXTRA

  // DELETE ALL
  Future<void> deleteAllPrestamos() async {
    final db = await database;
    await db.delete('prestamo');
  }

  // GET PENDING
  Future<List<Map<String, dynamic>>> pendingPrestamos() async {
    final db = await database;
    return await db.query('prestamo', where: 'status = ?', whereArgs: [0]);
  }

  // EXAMPLE DATA
  Future<void> examplePrestamos() async {
    final db = await database;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM prestamo');
    final count = result.first['count'] as int;

    if (count > 0) return;

    await db.transaction((txn) async {
      await txn.insert('prestamo', {
        'name': 'John Doe',
        'title': 'Book Loan',
        'days': 7,
        'status': 0,
      });
      await txn.insert('prestamo', {
        'name': 'Jane Smith',
        'title': 'DVD Loan',
        'days': 3,
        'status': 1,
      });
      await txn.insert('prestamo', {
        'name': 'Walter White',
        'title': 'VHS Loan',
        'days': 6,
        'status': 0,
      });
      await txn.insert('prestamo', {
        'name': 'Jesse Pinkman',
        'title': 'Vinyl Loan',
        'days': 27,
        'status': 1,
      });
    });
  }
}

class PrestamoListScreen extends StatefulWidget {
  const PrestamoListScreen({super.key});

  @override
  State<PrestamoListScreen> createState() => _PrestamoListScreenState();
}

class _PrestamoListScreenState extends State<PrestamoListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _prestamos = [];
  bool _showingPending = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _databaseHelper.examplePrestamos();
    await _readPrestamos();
  }

  // CRUD

  // CREATE
  Future<void> _addPrestamo() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController daysController = TextEditingController();
    bool statusValue = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Prestamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: daysController,
                  decoration: const InputDecoration(labelText: "Days"),
                  keyboardType: TextInputType.number,
                ),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return SwitchListTile(
                      title: const Text("Status"),
                      subtitle: Text(statusValue ? "Devuelto" : "Pendiente"),
                      value: statusValue,
                      onChanged: (value) {
                        setDialogState(() {
                          statusValue = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final days = int.tryParse(daysController.text);

                if (nameController.text.isNotEmpty &&
                    titleController.text.isNotEmpty &&
                    days != null) {
                  await _databaseHelper.insertPrestamo({
                    'name': nameController.text,
                    'title': titleController.text,
                    'days': days,
                    'status': statusValue ? 1 : 0,
                  });
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
    await _readPrestamos();
  }

  // READ
  Future<void> _readPrestamos() async {
    final prestamos = await _databaseHelper.getPrestamos();
    setState(() {
      _prestamos = prestamos;
    });
  }

  // READ ONE
  Future<void> _readPrestamoById() async {
    TextEditingController idController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Prestamo by ID"),
          content: TextField(
            controller: idController,
            decoration: const InputDecoration(labelText: "Prestamo ID"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final id = int.tryParse(idController.text);

                if (id != null) {
                  final prestamo = await _databaseHelper.getPrestamoById(id);

                  if (!mounted) return;

                  setState(() {
                    _prestamos = prestamo != null ? [prestamo] : [];
                    _showingPending = false;
                  });
                  if(!context.mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }

  // UPDATE
  Future<void> _updatePrestamo(int id) async {
    final matches = _prestamos.where((p) => p['id'] == id);
    if (matches.isEmpty) return;
    final prestamo = matches.first;

    TextEditingController nameController = TextEditingController(
      text: prestamo['name'],
    );
    TextEditingController titleController = TextEditingController(
      text: prestamo['title'],
    );
    TextEditingController daysController = TextEditingController(
      text: prestamo['days'].toString(),
    );
    bool statusValue = prestamo['status'] == 1;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modify Prestamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: daysController,
                  decoration: const InputDecoration(labelText: "Days"),
                  keyboardType: TextInputType.number,
                ),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return SwitchListTile(
                      title: const Text("Status"),
                      subtitle: Text(statusValue ? "Devuelto" : "Pendiente"),
                      value: statusValue,
                      onChanged: (value) {
                        setDialogState(() {
                          statusValue = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final days = int.tryParse(daysController.text);

                if (nameController.text.isNotEmpty &&
                    titleController.text.isNotEmpty &&
                    days != null) {
                  await _databaseHelper.updatePrestamo(prestamo['id'], {
                    'name': nameController.text,
                    'title': titleController.text,
                    'days': days,
                    'status': statusValue ? 1 : 0,
                  });
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Modify"),
            ),
          ],
        );
      },
    );
    await _readPrestamos();
  }

  // DELETE
  Future<void> _deletePrestamo(int id) async {
    await _databaseHelper.deletePrestamo(id);
    await _readPrestamos();
  }

  // EXTRA

  // TOGGLE PENDING
  Future<void> _togglePendingPrestamos() async {
    if (_showingPending) {
      final prestamos = await _databaseHelper.getPrestamos();
      setState(() {
        _prestamos = prestamos;
        _showingPending = false;
      });
    } else {
      final prestamosPendientes = await _databaseHelper.pendingPrestamos();
      setState(() {
        _prestamos = prestamosPendientes;
        _showingPending = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prestamos")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _prestamos.length,
              itemBuilder: (context, index) {
                final prestamo = _prestamos[index];
                return ListTile(
                  title: Text('${prestamo['title']} (${prestamo['id']})'),
                  subtitle: Text(
                    'Nombre: ${prestamo['name']}\n'
                    'Días: ${prestamo['days']}\n'
                    'Estado: ${prestamo['status'] == 1 ? 'Devuelto' : 'Pendiente'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePrestamo(prestamo['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _updatePrestamo(prestamo['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.add), onPressed: _addPrestamo),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.pending),
                onPressed: _togglePendingPrestamos,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _readPrestamoById,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
