import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.settings,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Text(
                    l10n.languageSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textOnLightColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chooseLanguage,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textOnLightColor,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      _LanguageOption(
                        title: 'English',
                        flag: '🇬🇧',
                        locale: const Locale('en'),
                        isSelected: localeProvider.locale.languageCode == 'en',
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
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
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMedium,
          horizontal: AppTheme.spacingLarge,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 26)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.neutralColor.withValues(alpha: 77),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppTheme.spacingMedium),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textOnLightColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
