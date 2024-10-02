import 'package:flutter/material.dart';
import 'sign_in_screen.dart'; 

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/intelligearth_logo.png', height: 100),
            const SizedBox(height: 30),
            const Text('Intelligearth App', style: TextStyle(fontSize: 32)),
            const Text('Slogan breve qui', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
