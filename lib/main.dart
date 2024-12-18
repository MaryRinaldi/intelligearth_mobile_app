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
// import 'screens/map_screen.dart';
import 'screens/settings_page.dart';
import 'screens/help_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomePage(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomeScreen(),
            '/quests': (context) => QuestPage(),
            '/rewards': (context) => const RewardScreen(),
            '/user': (context) {
              final User user =
                  ModalRoute.of(context)!.settings.arguments as User;
              return UserPage(user: user);
            },
            // '/map': (context) => const MapScreen(),
            '/help': (context) => const HelpPage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
