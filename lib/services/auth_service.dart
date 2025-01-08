import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'preferences_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final PreferencesService _preferencesService = PreferencesService();
  User? _currentUser;

  // Imposta la variabile per distinguere l'ambiente
  static const bool isProduction = false;

  // Usa l'URL corretto in base all'ambiente e alla piattaforma
  String getApiUrl() {
    if (isProduction) {
      return 'https://myappserver.com/api';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      } else if (Platform.isIOS) {
        return 'http://127.0.0.1:3000/api';
      } else {
        return 'http://localhost:3000/api';
      }
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      // Gestione utente hardcoded
      if (email == "mary@example.com" && password == "password123") {
        _currentUser = User(
          id: "1",
          name: "Mary",
          email: email,
          role: "user",
          position: "Explorer",
        );
        return _currentUser;
      }

      // Prova l'autenticazione con il server
      final response = await http.post(
        Uri.parse('${getApiUrl()}/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);
        return _currentUser;
      }
    } catch (e) {
      log('Server auth failed: $e');
    }

    return null;
  }

  Future<User?> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiUrl()}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);
        return _currentUser;
      } else if (response.statusCode == 409) {
        throw Exception('Email già registrata');
      }
    } catch (e) {
      log('Server registration failed: $e');
      // In modalità offline, crea un nuovo utente locale
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: "user",
        position: "Novice Explorer",
      );
      return _currentUser;
    }
    return null;
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _preferencesService.clearStoredUser();
    await _preferencesService.setRememberMe(false);
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final rememberMe = await _preferencesService.getRememberMe();
    if (rememberMe) {
      final storedUser = await _preferencesService.getStoredUser();
      if (storedUser != null) {
        _currentUser = storedUser;
        return _currentUser;
      }
    }

    return null;
  }

  Future<void> rememberUser(bool remember) async {
    await _preferencesService.setRememberMe(remember);
    if (remember && _currentUser != null) {
      await _preferencesService.storeUser(_currentUser!);
    } else if (!remember) {
      await _preferencesService.clearStoredUser();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiUrl()}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Password reset failed: $e');
      return false;
    }
  }
}
