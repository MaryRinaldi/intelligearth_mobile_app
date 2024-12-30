class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String position;

  // Costruttore
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.position = 'Guest',
  });

  User.empty()
      : id = '',
        name = '',
        email = '',
        role = '',
        position = 'Guest';

  // Metodo factory per creare un oggetto User da un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String, //es admin o utente normale
      position: json['position'] as String? ?? 'Guest',
    );
  }

  // Metodo per convertire un oggetto User in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'position': position,
    };
  }
}
