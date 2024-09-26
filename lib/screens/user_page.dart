import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({super.key, required this.user});

 @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simuliamo un caricamento di dati
    Future.delayed(const Duration (seconds: 2), () {
      setState(() {
        _isLoading = false; // Fine del caricamento
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Utente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostra il caricamento
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${widget.user.name}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('Email: ${widget.user.email}', style: const TextStyle(fontSize: 20)),
                  // Aggiungi ulteriori dettagli utente qui
                ],
              ),
          ),
    );
  }
}
