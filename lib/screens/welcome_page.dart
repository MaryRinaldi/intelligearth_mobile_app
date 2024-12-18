import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/intelligearth_logo.png',
                height: 120,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                l10n.selectLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LanguageButton(
                    language: 'English',
                    flag: '🇬🇧',
                    locale: const Locale('en'),
                  ),
                  const SizedBox(width: 16),
                  _LanguageButton(
                    language: 'Italiano',
                    flag: '🇮🇹',
                    locale: const Locale('it'),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signin'),
                child: Text(l10n.signIn),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text(l10n.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.language,
    required this.flag,
    required this.locale,
  });

  final String language;
  final String flag;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isSelected = localeProvider.locale == locale;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      onPressed: () {
        localeProvider.setLocale(locale);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(language),
        ],
      ),
    );
  }
}
