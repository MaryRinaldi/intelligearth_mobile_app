import 'package:flutter/material.dart';
import 'sign_in_screen.dart'; 

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Spacer(),
            Image.asset('assets/images/intelligearth_logo.png', height: 200, fit: BoxFit.contain,),
            Spacer(),
            const Text('Intelligearth App', style: TextStyle(fontSize: 32)),
            const Text('Descrizione breve', style: TextStyle(fontSize: 16)),
            Spacer(),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text('Get Started', style: TextStyle(fontSize: 30)),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
