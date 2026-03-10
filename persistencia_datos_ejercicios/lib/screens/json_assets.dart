import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cliente.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> clientes = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/clientes.json',
      );

      final List<dynamic> data = jsonDecode(response);

      setState(() {
        clientes = data.map((item) => Cliente.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar el JSON";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clientes JSON")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(cliente.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: ${cliente.id}"),
                        Text("Email: ${cliente.email}"),
                        Text("Edad: ${cliente.edad}"),
                        Text("Ciudad: ${cliente.ciudad}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
