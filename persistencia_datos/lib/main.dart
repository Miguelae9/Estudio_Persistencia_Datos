import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClickCounterPage(),
    );
  }
}

class ClickCounterPage extends StatefulWidget {
  const ClickCounterPage({super.key});

  @override
  State<ClickCounterPage> createState() => _ClickCounterPageState();
}

class _ClickCounterPageState extends State<ClickCounterPage> {
  static final DocumentReference counterRef = FirebaseFirestore.instance
      .collection('counters')
      .doc('clicks');

  @override
  void initState() {
    super.initState();
    _initCounter();
  }

  Future<void> _initCounter() async {
    // Verifica si el contador ya existe
    DocumentSnapshot snapshot = await counterRef.get();
    if (!snapshot.exists) {
      // Si no existe, inicializa el contador en 0
      await counterRef.set({'count': 0});
    }
  }

  Future<void> _increment() async {
    await counterRef.update({'count': FieldValue.increment(1)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contador de clics')),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: counterRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final int count = data?['count'] ?? 0;

            return Text('Clicks: $count', style: const TextStyle(fontSize: 32));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
