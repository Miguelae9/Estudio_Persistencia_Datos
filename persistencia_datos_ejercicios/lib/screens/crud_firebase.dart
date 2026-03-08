import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudFirebaseScreen extends StatefulWidget {
  const CrudFirebaseScreen({super.key});

  @override
  State<CrudFirebaseScreen> createState() => _CrudFirebaseScreenState();
}

class _CrudFirebaseScreenState extends State<CrudFirebaseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final tareasRef = FirebaseFirestore.instance.collection('tareas');

  List<Map<String, dynamic>> _tareas = [];

  String titulo = "";
  String descripcion = "";
  bool estado = false;

  @override
  void initState() {
    super.initState();
    _loadTareas();
  }

  Future<void> _loadTareas() async {
    final snapshot = await _firestore.collection('tareas').get();
    final tareas = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'titulo': doc['titulo'],
        'descripcion': doc['descripcion'],
        'estado': doc['estado'],
      };
    }).toList();

    setState(() {
      _tareas = tareas;
    });
  }

  Future<void> _create(
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

  Future<void> _createTarea() async {
    TextEditingController idController = TextEditingController();
    TextEditingController tituloController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    bool estado = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Tarea'),
          content: Column(
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
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              SwitchListTile(
                title: const Text("Estado"),
                subtitle: const Text(
                  "Indica si la tarea está completada o pendiente",
                ),
                value: estado,
                onChanged: (value) {
                  setState(() {
                    estado = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                String id = idController.text;
                String titulo = tituloController.text;
                String descripcion = descripcionController.text;
                _create(id, titulo, descripcion, estado);
                Navigator.of(context).pop();
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
    _loadTareas();
  }

  Future<void> _update(
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

  Future<void> _updateTarea(String id) async {
    final matches = _tareas.where((tarea) => tarea['id'] == id);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea no encontrada')));
      return;
    }
    final tarea = matches.first;

    TextEditingController tituloControllerRead = TextEditingController(
      text: tarea['titulo'],
    );
    TextEditingController descripcionController = TextEditingController(
      text: tarea['descripcion'],
    );
    bool estado = tarea['estado'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloControllerRead,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: estado
                    ? TextEditingController(text: 'true')
                    : TextEditingController(text: 'false'),
                decoration: const InputDecoration(
                  labelText: 'Estado (true/false)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                String titulo = tituloControllerRead.text;
                String descripcion = descripcionController.text;
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return SwitchListTile(
                      title: const Text("Estado"),
                      subtitle: Text(
                        tarea['estado'] ? "Devuelto" : "Pendiente",
                      ),
                      value: estado,
                      onChanged: (value) {
                        setState(() {
                          estado = value;
                        });
                      },
                    );
                  },
                );
                _update(id, titulo, descripcion, estado);
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
    _loadTareas();
  }

  Future<void> _delete(String id) async {
    await tareasRef.doc(id).delete();
    _loadTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Firebase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _tareas.length,
                itemBuilder: (context, index) {
                  final tarea = _tareas[index];
                  return ListTile(
                    title: Text('Título: ${tarea['titulo']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descripción: ${tarea['descripcion']}'),
                        Text('Estado: ${tarea['estado']}'),
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
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _delete(tarea['id']);
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
                IconButton(
                  onPressed: _createTarea,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
