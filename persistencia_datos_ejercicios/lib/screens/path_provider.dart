import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PathProvider extends StatefulWidget {
  const PathProvider({super.key});

  @override
  State<PathProvider> createState() => _PathProviderState();
}

class _PathProviderState extends State<PathProvider> {
  List<String> entries = [];
  late File _fileMain;
  late File _fileBackup;
  late File _fileExport;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    await _getApplicationDocumentsDirectory();
    await _getApplicationCacheDirectory();
  }

  Future<void> _getApplicationDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    _fileMain = File('${directory.path}/entries.txt');

    if (await _fileMain.exists()) {
      final content = await _fileMain.readAsLines();
      setState(() {
        entries = content;
      });
    } else {
      await _fileMain.create();
    }
  }

  Future<void> _getApplicationCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();
    _fileBackup = File('${directory.path}/entries_backup.txt');

    await _fileBackup.create();
  }

  Future<void> _getTemporaryDirectory() async {
    final directory = await getTemporaryDirectory();
    _fileExport = File('${directory.path}/export.txt');
  }

  Future<void> _exportData() async {
    await _getTemporaryDirectory();
    DateTime now = DateTime.now();
    String header =
        "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}\n";
    String body = entries.join('\n');
    String fullContent = '$header$body\n';

    await _fileExport.writeAsString(fullContent);
    final info = await _fileExport.stat();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Data exported to ${_fileExport.path} (${info.size} bytes) (${info.modified})",
        ),
      ),
    );
  }

  Future<void> saveData() async {
    await _fileMain.writeAsString(entries.join('\n'));
    try {
      await _fileBackup.writeAsString(entries.join('\n'));
    } catch (e) {
      Text("Error writing to backup file: $e");
    }
  }

  Future<void> _addEntry(String entry) async {
    setState(() {
      entries.add(entry);
    });
    await saveData();
  }

  Future<void> _updateEntry(int index, String newEntry) async {
    setState(() {
      entries[index] = newEntry;
    });
    await saveData();
  }

  Future<void> _deleteEntry(int index) async {
    setState(() {
      entries.removeAt(index);
    });
    await saveData();
  }

  void _addDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Entry"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addEntry(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _updateDialog(int index) {
    TextEditingController controller = TextEditingController(
      text: entries[index],
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Entry"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _updateEntry(index, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Path Provider")),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(entries[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _updateDialog(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteEntry(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: _addDialog, child: Icon(Icons.add)),

          SizedBox(height: 10),

          FloatingActionButton(onPressed: _exportData, child: Icon(Icons.save)),
        ],
      ),
    );
  }
}
