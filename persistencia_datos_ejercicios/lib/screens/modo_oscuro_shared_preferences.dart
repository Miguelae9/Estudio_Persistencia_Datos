import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModoOscuroSharedPreferences extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ModoOscuroSharedPreferences({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ModoOscuroSharedPreferences> createState() =>
      _ModoOscuroSharedPreferencesState();
}

class _ModoOscuroSharedPreferencesState
    extends State<ModoOscuroSharedPreferences> {
  // GUARDAR TEMA
  Future<void> saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  // CAMBIAR TEMA
  void toggleTheme(bool value) async {
    await saveTheme(value);
    widget.onThemeChanged(
      value,
    ); // NOTIFICAR A LA SCREEN PRINCIPAL DEL CAMBIO DE TEMA
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modo oscuro")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isDarkMode
                  ? "El modo oscuro está activado"
                  : "El modo claro está activado",
            ),
            const SizedBox(height: 20),
            Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 80,
            ),
            const SizedBox(height: 20),
            Switch(value: widget.isDarkMode, onChanged: toggleTheme),
          ],
        ),
      ),
    );
  }
}
