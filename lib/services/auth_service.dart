import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

// Imposta la variabile per distinguere l'ambiente
const bool isProduction = false; // Cambia a true per l'app finale in produzione

// Usa l'URL corretto in base all'ambiente e alla piattaforma
String getApiUrl() {
  if (isProduction) {
    return 'https://myappserver.com/api'; // URL del server remoto in produzione
  } else {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // URL per sviluppo locale su Android Emulator
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:3000/api'; // URL per sviluppo locale su iOS Simulator
    } else {
      return 'http://localhost:3000/api'; // Fallback per altre piattaforme (web, desktop)
    }
  }
}

class AuthService {
  final String apiUrl = getApiUrl();

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

      return null; // Mostra un messaggio di errore personalizzato
    } else {
      // Gestione di eventuali altri errori

      return null;
    }
  }

  // Recupera l'utente corrente
  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      // Gestione utente hardcoded
      if (token == 'mary_test_token') {
        return User(
          id: 'mary123',
          name: 'Mary',
          email: 'mary@example.com',
          role: 'user',
        );
      }

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
        return null;
      }
    } else {
      // Nessun token salvato, l'utente non è autenticato

      return null;
    }
  }

  // Simula il logout (da implementare)
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'jwt_token'); // Rimuove il token salvato per effettuare il logout
  }

  Future<bool> resetPassword(String email) async {
    try {
      //  Replace with your actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      return true;
    } catch (e) {
      return false;
    }
  }
}
