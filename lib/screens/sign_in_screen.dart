import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import 'package:intelligearth_mobile/screens/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}
class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    void _loginUser(BuildContext context) {
    // Simulazione del login
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final screenSize = MediaQuery.of(context).size;
     
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/intelligearth_logo.png', height: 50),
            const Text('IntelligEarth App', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 70),
            Center(
              child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 134, 142, 150),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              width: screenSize.width * 0.85,
              child: Column(
              children: <Widget>[
              TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Funzione per il recupero della password
                },
                child: const Text('Forgot your password?'),
              ),
            ),
            SizedBox(height: 16),
             SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 225, 225, 225), // Colore di sfondo
                            shape: RoundedRectangleBorder( // Forma del pulsante
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0), // Altezza del pulsante
                          ),
                          onPressed: () => _loginUser(context),
                          child: const Text('Sign Up'),
                        ),
                      ),
            SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    // Naviga alla schermata di registrazione (Sign Up)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Sign Up'),
                    ),
                    ],
                  ),
                ],
              ),
            ),
        ),
        ],
        ),
      ),
      ),
    );
  }
}
