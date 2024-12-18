import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeInAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.lightColor,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Image.asset(
                          'assets/images/intelligearth_logo.png',
                          height: size.height * 0.15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Text(
                    l10n.welcomeTitle,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.lightColor,
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildLanguageSelector(context, l10n),
                const SizedBox(height: AppTheme.spacingXLarge),
                _buildActionButtons(context, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Column(
        children: [
          Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color.fromRGBO(253, 253, 253, 0.9),
                ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LanguageButton(
                language: 'English',
                flag: '🇬🇧',
                locale: const Locale('en'),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              _LanguageButton(
                language: 'Italiano',
                flag: '🇮🇹',
                locale: const Locale('it'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/signin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              minimumSize: const Size(200, 50),
            ),
            child: Text(l10n.signIn),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightColor,
            ),
            child: Text(l10n.signUp),
          ),
        ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => localeProvider.setLocale(locale),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(253, 253, 253, 0.2)
                : Colors.transparent,
            border: Border.all(
              color: const Color.fromRGBO(253, 253, 253, 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                language,
                style: TextStyle(
                  color: AppTheme.lightColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
