import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manejo de ficheros',
      home: UsoFicheros(),
    );
  }
}


class UsoFicheros extends StatefulWidget {
  const UsoFicheros({super.key});


  @override
  State<UsoFicheros> createState() => _UsoFicherosState();
}


class _UsoFicherosState extends State<UsoFicheros> {
  List<String> contenido = [];
  late File fichero;


  @override
  void initState() {
    super.initState();
    _initFichero();
  }


  Future<void> _initFichero() async {
    final directorio = await getApplicationDocumentsDirectory();
    fichero = File('${directorio.path}/data.txt');


    if (await fichero.exists()) {
      final elementos = await fichero.readAsLines();
      setState(() {
        contenido = elementos;
      });
    } else {
      await fichero.create();
    }
  }


  Future<void> _guardarDatos() async {
    await fichero.writeAsString(contenido.join('\n'));
  }


  void _anadeEntrada(String item) {
    setState(() {
      contenido.add(item);
    });
    _guardarDatos();
  }


  void _actualizaEntrada(int index, String newItem) {
    setState(() {
      contenido[index] = newItem;
    });
    _guardarDatos();
  }


  void _borraEntrada(int index) {
    setState(() {
      contenido.removeAt(index);
    });
    _guardarDatos();
  }


  void _mensajeAlerta() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nuevo Item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _anadeEntrada(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }


  void _mensajeEdicionEntrada(int index) {
    final controller = TextEditingController(text: contenido[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nuevo Valor'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _actualizaEntrada(index, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficheros en Flutter'),
      ),
      body: ListView.builder(
        itemCount: contenido.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contenido[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _mensajeEdicionEntrada(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _borraEntrada(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mensajeAlerta,
        child: const Icon(Icons.add),
      ),
    );
  }
}
