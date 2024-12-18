import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Sezione Lingua
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.languageSettings,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chooseLanguage,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // Opzioni lingua
                      _LanguageOption(
                        title: 'English',
                        flag: '🇬🇧',
                        locale: const Locale('en'),
                        isSelected: localeProvider.locale.languageCode == 'en',
                      ),
                      const SizedBox(height: 8),
                      _LanguageOption(
                        title: 'Italiano',
                        flag: '🇮🇹',
                        locale: const Locale('it'),
                        isSelected: localeProvider.locale.languageCode == 'it',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Altre impostazioni possono essere aggiunte qui
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.flag,
    required this.locale,
    required this.isSelected,
  });

  final String title;
  final String flag;
  final Locale locale;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return InkWell(
      onTap: () => localeProvider.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(0, 0, 255, 0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : null,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
