import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'screens/welcome_page.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quest_page.dart';
import 'screens/reward_screen.dart';
import 'screens/user_page.dart';
import 'models/user_model.dart';
import 'screens/settings_page.dart';
import 'screens/help_page.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'package:intelligearth_mobile/config/app_config.dart';
import 'services/preferences_service.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    try {
      final prefsService = PreferencesService();
      final authService = AuthService();
      
      // Load preferences and check auth state in parallel
      final results = await Future.wait([
        prefsService.getOnboardingComplete(),
        authService.getCurrentUser(),
      ]);
      
      final onboardingComplete = results[0] as bool;
      final currentUser = results[1];
      
      if (!onboardingComplete) {
        return '/';
      }
      
      if (currentUser != null) {
        return '/home';
      }
      
      return '/signin';
    } catch (e) {
      // In caso di errore, mostra la schermata di login
      return '/signin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('it'), // Italian
          ],
          title: 'IntelligEarth App',
          theme: AppTheme.lightTheme,
          home: FutureBuilder<String>(
            future: _getInitialRoute(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              switch (snapshot.data) {
                case '/':
                  return const WelcomePage();
                case '/home':
                  return const HomeScreen();
                default:
                  return const SignInScreen();
              }
            },
          ),
          routes: {
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomeScreen(),
            '/quests': (context) => QuestPage(),
            '/rewards': (context) => const RewardScreen(),
            '/user': (context) {
              final User user = ModalRoute.of(context)!.settings.arguments as User;
              return UserPage(user: user);
            },
            '/help': (context) => const HelpPage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
