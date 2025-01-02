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

  Future<User?> signIn(String email, String password, bool rememberMe) async {
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

      // Salva il token e i dati utente solo se "ricordami" è attivo
      if (rememberMe) {
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString(
            'user_data',
            json.encode({
              'id': data['id'],
              'name': data['name'],
              'email': data['email'],
              'role': data['role'],
            }));
      }

      // Salva sempre la preferenza "ricordami"
      await prefs.setBool('remember_me', rememberMe);

      return User(
        id: data['id'].toString(),
        name: data['name'],
        email: data['email'],
        role: data['role'],
      );
    } else {
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
    String? userData = prefs.getString('user_data');
    bool rememberMe = prefs.getBool('remember_me') ?? false;

    // Se "ricordami" non è attivo o non ci sono dati, ritorna null
    if (!rememberMe || token == null || userData == null) {
      return null;
    }

    final data = json.decode(userData);
    return User(
      id: data['id'].toString(),
      name: data['name'],
      email: data['email'],
      role: data['role'],
    );
  }

  // Logout completo
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('remember_me') ?? false;

    if (!rememberMe) {
      // Se "ricordami" non è attivo, rimuovi tutti i dati
      await prefs.remove('jwt_token');
      await prefs.remove('user_data');
    }
    // Mantieni comunque la preferenza "ricordami"
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
