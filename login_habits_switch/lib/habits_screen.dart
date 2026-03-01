import 'package:flutter/material.dart';
import 'package:login_habits_switch/lateral_menu.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final List<Map<String, dynamic>> habits = [
    {"title": "Beber agua", "done": false},
    {"title": "Gimnasio", "done": true},
  ];

  void _addHabit(String title) {
    setState(() {
      habits.add({"title": title, "done": false});
    });
  }

  void _openAddDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nuevo hábito"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Ej: Leer 10 min"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  _addHabit(text);
                }
                Navigator.pop(context);
              },
              child: const Text("Añadir"),
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
        title: const Text("Hábitos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddDialog,
          ),
        ],
      ),
      drawer: const Drawer(child: LateralMenu()),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          return HabitCard(
            title: habit["title"] as String,
            done: habit["done"] as bool,
            onChanged: (value) {
              setState(() {
                habit["done"] = value ?? false;
              });
            },
            onDelete: () {
              setState(() {
                habits.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}

class Habit {
  Habit({required this.title, this.done = false});
  final String title;
  bool done;
}

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.title,
    required this.done,
    required this.onChanged,
    required this.onDelete,
  });

  final String title;
  final bool done;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        leading: Checkbox(value: done, onChanged: onChanged),
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ),
    );
  }
}