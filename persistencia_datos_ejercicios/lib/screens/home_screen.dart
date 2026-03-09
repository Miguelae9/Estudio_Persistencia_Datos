import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const String _kAutoRefreshOn = "autoRefreshOn";

  bool _requestInFlight = false;

  int _lastTodoId = 0;
  String _lastTodoText = "---";
  bool _autoRefreshOn = false;
  bool _isLoading = false;

  int _fetchedTodoId = 0;
  String _fetchedTodoText = "---";
  bool? _fetchedTodoCompleted;

  String? _errorMessage;
  bool? _lastTodoCompleted;

  TextEditingController controller_fetchTodoById = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_kAutoRefreshOn) ?? false;
    setState(() {
      _autoRefreshOn = saved;
    });
  }

  Future<void> _saveAutoRefreshOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoRefreshOn, value);
  }

  Future<void> lastTodoId() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/todos/4"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _lastTodoId = data["id"];
          _lastTodoText = data["todo"];
          _lastTodoCompleted = data["completed"];
        });
      } else {
        setState(() {
          _lastTodoId = 0;
          _lastTodoText = "";
          _lastTodoCompleted = null;
          _errorMessage = "Error al cargar el TODO.";
        });
      }
    } catch (e) {
      setState(() {
        _lastTodoId = 0;
        _lastTodoText = "";
        _lastTodoCompleted = null;
        _errorMessage = "Error de conexión o de ejecución.";
      });
    }
  }

  Future<void> fetchTodoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/todos/$id"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _fetchedTodoId = data["id"];
          _fetchedTodoText = data["todo"];
          _fetchedTodoCompleted = data["completed"];
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "El servidor devolvió un error.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error de conexión o de ejecución.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller_fetchTodoById.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Switch(
                      value: _autoRefreshOn,
                      onChanged: (value) {
                        setState(() {
                          _autoRefreshOn = value;
                        });
                        _saveAutoRefreshOn(value);
                      },
                    ),

                    if (_autoRefreshOn)
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          if (_autoRefreshOn) {
                            lastTodoId();
                          }
                          return Column(
                            children: [
                              Text("Last Todo ID: $_lastTodoId"),
                              Text("Last Todo Text: $_lastTodoText"),
                              Text("Last Todo Completed: $_lastTodoCompleted"),
                              if (_errorMessage != null)
                                Text(
                                  "Error: $_errorMessage",
                                  style: const TextStyle(color: Colors.red),
                                ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              onChanged: (value) {
                setState(() {
                  value = value;
                });
              },
              controller: controller_fetchTodoById,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Last Todo Text",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  if (controller_fetchTodoById.text.isEmpty) {
                    _errorMessage = "Please enter a valid Todo ID.";
                    _isLoading = false;
                    return;
                  }

                  _isLoading = true;
                });
                fetchTodoById(int.parse(controller_fetchTodoById.text));
              },
              child: const Text("Cargar TODO"),
            ),

            SizedBox(height: 20),

            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Column(
                children: [
                  Text("Fetched Todo ID: $_fetchedTodoId"),
                  Text("Fetched Todo Text: $_fetchedTodoText"),
                  Text("Fetched Todo Completed: $_fetchedTodoCompleted"),
                  if (_errorMessage != null)
                    Text(
                      "Error: $_errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/refresh"),
              child: const Text("Go to Auto Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}
