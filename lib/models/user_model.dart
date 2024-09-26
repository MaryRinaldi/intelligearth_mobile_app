class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String role;

  // Costruttore
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });

  // Metodo factory per creare un oggetto User da un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String,
      role: json['role'] as String, //es admin o utente normale
    );
  }

  // Metodo per convertire un oggetto User in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}
