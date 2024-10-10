import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

class UserPage extends StatelessWidget {
  final User user;

  const UserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome: ${user.name}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text('Email: ${user.email}', style: const TextStyle(fontSize: 20)),
          // Aggiungi ulteriori dettagli utente qui
        ],
      ),
    );
  }
}
