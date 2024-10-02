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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/intelligearth_logo.png', height: 50),
            const SizedBox(height: 10),
            const Text('IntelligEarth App', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            // Form di Sign In
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Funzione per il recupero della password
                },
                child: const Text('Forgot your password?'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
               // Funzione per autenticare l'utente 
              onPressed: () => _loginUser(context),              
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
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
    );
  }

  // Funzione simulata per il login
}