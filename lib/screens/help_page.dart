import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aiuto')),
      body: Center(
        child: Text('Questa è la pagina di aiuto.'),
      ),
    );
  }
}
