import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelligEarth App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 225, 225, 225)),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
