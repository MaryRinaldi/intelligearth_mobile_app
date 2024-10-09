import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

class AuthService {
final String apiUrl = 'http://localhost:3000/api';

Future<User?> signIn(String email, String password) async {
final response = await http.post(
  Uri.parse('$apiUrl/signin'),
  headers: {
    'Content-Type': 'application/json',
},
body: json.encode({
  'email': email,
  'password': password,
}),
);

if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);

      return User(
        id: data['id'].toString(),
        name: data['name'],
        email: data['email'],
        role: data['role'],
      );
    } else {
      // Gestisci gli errori di login
      print("Error during login: ${response.statusCode}");
      return null;
    }
  }

  // Effettua la registrazione di un nuovo utente
  Future<User?> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return User(
        id: data['id'].toString(),
        name: data['name'],
        email: data['email'],
        role: 'user',
      );
    } else if (response.statusCode == 409) {
      // Gestisci il caso di conflitto (ad esempio, email già esistente)
      print("Error: Email already exists.");
      return null; // Mostra un messaggio di errore personalizzato
    } else {
      // Gestione di eventuali altri errori
      print("Error during sign up: ${response.statusCode}");
      return null;
    }
  }

  // Recupera l'utente corrente 
  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    
    if (token != null) {
      // Fai una chiamata API per verificare il token JWT
      final response = await http.get(
        Uri.parse('$apiUrl/current_user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User(
          id: data['id'].toString(),
          name: data['name'],
          email: data['email'],
          role: data['role'],
        );
      } else {
        print("Error retrieving current user: ${response.statusCode}");
        return null;
      }
    } else {
      // Nessun token salvato, l'utente non è autenticato
      print("No token found, user is not authenticated");
      return null;
    }
  }

  // Simula il logout (da implementare)
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Rimuove il token salvato per effettuare il logout
    print("User signed out successfully");
  }
}