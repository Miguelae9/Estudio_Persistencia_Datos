import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  final CollectionReference<Map<String, dynamic>> tareasRef = FirebaseFirestore
      .instance
      .collection('tareas');

  // CRUD

  // CREATE
  Future<void> createTarea(
    String id,
    String titulo,
    String descripcion,
    bool estado,
  ) async {
    await tareasRef.doc(id).set({
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
    });
  }

  // READ ALL
  Future<List<Map<String, dynamic>>> getTareas() async {
    final snapshot = await tareasRef.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'titulo': data['titulo'],
        'descripcion': data['descripcion'],
        'estado': data['estado'],
      };
    }).toList();
  }

  // READ ONE
  Future<Map<String, dynamic>?> getTareaById(String id) async {
    final snapshot = await tareasRef.doc(id).get();

    if (!snapshot.exists) return null;

    final data = snapshot.data()!;
    return {
      'id': snapshot.id,
      'titulo': data['titulo'],
      'descripcion': data['descripcion'],
      'estado': data['estado'],
    };
  }

  // UPDATE
  Future<void> updateTarea(
    String id,
    String titulo,
    String descripcion,
    bool estado,
  ) async {
    await tareasRef.doc(id).update({
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
    });
  }

  // DELETE
  Future<void> deleteTarea(String id) async {
    await tareasRef.doc(id).delete();
  }

  // EXTRA

  // GET BY STATUS
  Future<List<Map<String, dynamic>>> getTareasByEstado(bool estado) async {
    final snapshot = await tareasRef.where('estado', isEqualTo: estado).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'titulo': data['titulo'],
        'descripcion': data['descripcion'],
        'estado': data['estado'],
      };
    }).toList();
  }

  // DELETE ALL
  Future<void> deleteAllTareas() async {
    final snapshot = await tareasRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

class CrudFirebaseScreen extends StatefulWidget {
  const CrudFirebaseScreen({super.key});

  @override
  State<CrudFirebaseScreen> createState() => _CrudFirebaseScreenState();
}

class _CrudFirebaseScreenState extends State<CrudFirebaseScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Map<String, dynamic>> _tareas = [];
  bool _showingCompleted = false;

  String tituloLeido = "";
  String descripcionLeida = "";
  bool estadoLeido = false;

  @override
  void initState() {
    super.initState();
    _readTareas();
  }

  // CRUD

  // READ ALL
  Future<void> _readTareas() async {
    final tareas = await _databaseHelper.getTareas();

    setState(() {
      _tareas = tareas;
    });
  }

  // CREATE
  Future<void> _createTarea() async {
    TextEditingController idController = TextEditingController();
    TextEditingController tituloController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    bool estado = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Tarea'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'ID'),
                    ),
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    SwitchListTile(
                      title: const Text("Estado"),
                      subtitle: const Text(
                        "Indica si la tarea está completada o pendiente",
                      ),
                      value: estado,
                      onChanged: (value) {
                        setDialogState(() {
                          estado = value;
                        });
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
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final id = idController.text.trim();
                    final titulo = tituloController.text.trim();
                    final descripcion = descripcionController.text.trim();

                    if (id.isNotEmpty &&
                        titulo.isNotEmpty &&
                        descripcion.isNotEmpty) {
                      await _databaseHelper.createTarea(
                        id,
                        titulo,
                        descripcion,
                        estado,
                      );

                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
    await _readTareas();
  }

  // READ ONE
  Future<void> _readTareaById(String id) async {
    final tarea = await _databaseHelper.getTareaById(id);

    setState(() {
      if (tarea != null) {
        tituloLeido = tarea['titulo'];
        descripcionLeida = tarea['descripcion'];
        estadoLeido = tarea['estado'];
      } else {
        tituloLeido = 'Id no encontrado';
        descripcionLeida = 'Id no encontrado';
        estadoLeido = false;
      }
    });
  }

  // UPDATE
  Future<void> _updateTarea(String id) async {
    final matches = _tareas.where((tarea) => tarea['id'] == id);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea no encontrada')));
      return;
    }
    final tarea = matches.first;

    TextEditingController tituloController = TextEditingController(
      text: tarea['titulo'],
    );
    TextEditingController descripcionController = TextEditingController(
      text: tarea['descripcion'],
    );
    bool estado = tarea['estado'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Actualizar Tarea'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    SwitchListTile(
                      title: const Text("Estado"),
                      subtitle: Text(estado ? "Completada" : "Pendiente"),
                      value: estado,
                      onChanged: (value) {
                        setDialogState(() {
                          estado = value;
                        });
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
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final titulo = tituloController.text.trim();
                    final descripcion = descripcionController.text.trim();

                    if (titulo.isNotEmpty && descripcion.isNotEmpty) {
                      await _databaseHelper.updateTarea(
                        id,
                        titulo,
                        descripcion,
                        estado,
                      );

                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
    await _readTareas();
  }

  // DELETE
  Future<void> _deleteTarea(String id) async {
    await _databaseHelper.deleteTarea(id);
    await _readTareas();
  }

  // EXTRA

  // TOGGLE COMPLETED
  Future<void> _toggleCompletedTareas() async {
    if (_showingCompleted) {
      await _readTareas();
      setState(() {
        _showingCompleted = false;
      });
    } else {
      final tareasCompletadas = await _databaseHelper.getTareasByEstado(true);
      setState(() {
        _tareas = tareasCompletadas;
        _showingCompleted = true;
      });
    }
  }

  // SHOW DETAILS
  Future<void> _showTareaDetails() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles de la Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Título: $tituloLeido'),
              Text('Descripción: $descripcionLeida'),
              Text('Estado: ${estadoLeido ? "Completada" : "Pendiente"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // SEARCH BY ID
  Future<void> _searchTarea() async {
    TextEditingController idController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar Tarea'),
          content: TextField(
            controller: idController,
            decoration: const InputDecoration(labelText: 'ID de la tarea'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = idController.text.trim();
                await _readTareaById(id);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                await _showTareaDetails();
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Firebase')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tareas.length,
              itemBuilder: (context, index) {
                final tarea = _tareas[index];
                return ListTile(
                  title: Text(
                    'Título: ${tarea['titulo']} (ID: ${tarea['id']})',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descripción: ${tarea['descripcion']}'),
                      Text(
                        'Estado: ${tarea['estado'] ? "Completada" : "Pendiente"}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _updateTarea(tarea['id']);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTarea(tarea['id']);
                        },
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
              IconButton(onPressed: _createTarea, icon: const Icon(Icons.add)),
              const SizedBox(width: 20),
              IconButton(
                onPressed: _searchTarea,
                icon: const Icon(Icons.search),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: _toggleCompletedTareas,
                icon: Icon(
                  _showingCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
