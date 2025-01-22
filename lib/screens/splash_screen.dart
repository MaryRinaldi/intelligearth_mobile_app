import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('SplashScreen initialized');
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    try {
      developer.log('Checking initial route...');
      // Aggiungi un piccolo delay per assicurarti che lo splash screen sia visibile
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      final prefs = PreferencesService();
      final initialRoute = await prefs.checkInitialRoute();
      developer.log('Initial route determined: $initialRoute');

      if (!mounted) return;
      
      Navigator.of(context).pushReplacementNamed(initialRoute);
    } catch (e) {
      developer.log('Error in _checkInitialRoute: $e');
      // In caso di errore, vai alla schermata di login come fallback
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building SplashScreen');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/intelligearth_logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}