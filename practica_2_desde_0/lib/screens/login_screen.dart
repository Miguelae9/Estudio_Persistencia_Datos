import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave para poder validar el formulario completo
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para leer lo que escribe el usuario
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  // false = Login, true = Sign Up
  bool _isSignUp = false;

  @override
  void dispose() {
    // Siempre liberar controladores
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(_changeMode);
  }

  void _changeMode() {
    _isSignUp = !_isSignUp;
    _confirm.clear(); // al cambiar de modo, limpiamos confirmación
  }

  void _submit() {
    // Valida todos los TextFormField del Form
    final FormState? form = _formKey.currentState;
    final bool ok = form != null && form.validate();
    if (!ok) return;

    // Aquí NO hay persistencia: si valida, entra.
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Validación simple del email
  String? _checkEmail(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return 'Email obligatorio';
    if (!value.contains('@')) return 'Email inválido';
    return null; // null = sin error
  }

  // Validación simple del password
  String? _checkPass(String? v) {
    final String value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  // Solo se valida en Sign Up
  String? _checkConfirm(String? v) {
    if (!_isSignUp) return null; // si es login, no aplica
    final String value = v ?? '';
    if (value.isEmpty) return 'Confirma la contraseña';
    if (value != _pass.text) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Login')),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // EMAIL
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _checkEmail,
                ),

                const SizedBox(height: 12),

                // PASSWORD
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: _checkPass,
                ),

                // CONFIRM PASSWORD (solo en Sign Up)
                if (_isSignUp)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: _checkConfirm,
                    ),
                  ),

                const SizedBox(height: 12),

                // BOTÓN PRINCIPAL
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                  ),
                ),

                // CAMBIAR MODO
                TextButton(
                  onPressed: _switchMode,
                  child: Text(
                    _isSignUp ? 'Ya tengo una cuenta' : 'Crear cuenta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
