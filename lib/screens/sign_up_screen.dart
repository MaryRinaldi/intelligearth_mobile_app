import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _registerUser(BuildContext context) {
    // Simulazione della registrazione
    if (_emailController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Ottieni la dimensione dello schermo

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Scorrimento verticale per contenuti lunghi
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/intelligearth_logo.png', height: 50),
              const Text('IntelligEarth App', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 70),
              // Contenitore per i campi di input
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 134, 142, 150),
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
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      // Pulsante di registrazione
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
                          onPressed: () => _registerUser(context),
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Già registrato? Vai al login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              // Torna alla pagina di Sign In
                              Navigator.pop(context);
                            },
                            child: const Text('Sign In'),
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
