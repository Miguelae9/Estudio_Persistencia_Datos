class Cliente {
  final int id;
  final String nombre;
  final String email;
  final int edad;
  final String ciudad;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.edad,
    required this.ciudad,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      edad: json['edad'],
      ciudad: json['ciudad'],
    );
  }
}