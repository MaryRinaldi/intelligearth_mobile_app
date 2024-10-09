import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quest_page.dart';
import 'screens/reward_screen.dart';
import 'screens/user_page.dart';
import 'models/user_model.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/quests': (context) => const QuestPage(),
        '/rewards': (context) => const RewardScreen(),
        '/user': (context) => UserPage(user: User(
          id: '',
          name: 'Mario Rossi',
          email: 'mario.rossi@example.com',
          role: 'admin',
        )),
        // '/impostazioni': (context) => const SettingsPage(),
        // '/aiuto': (context) => const SupportPage(),
      },
    );
  }
}
