import 'package:flutter/material.dart';
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
  late final PageController _pageController;
  late final AnimationController _controller;
  late final Animation<double> _fadeInAnimation;
  int _currentPage = 0;
  bool _showLanguagePopup = true;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      icon: Icons.explore_rounded,
      title: 'Esplora il Mondo',
      description:
          'Scopri luoghi incredibili e partecipa a quest emozionanti nella tua città',
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      icon: Icons.camera_alt_rounded,
      title: 'Cattura Momenti',
      description:
          'Documenta le tue avventure e condividi le tue scoperte con la community',
      color: AppTheme.accentColor,
    ),
    OnboardingItem(
      icon: Icons.emoji_events_rounded,
      title: 'Guadagna Ricompense',
      description:
          'Completa le quest, ottieni punti e sblocca achievement esclusivi',
      color: AppTheme.successColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showLanguagePopup) {
        _showLanguageSelector();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LanguagePopup(),
    ).then((_) {
      setState(() {
        _showLanguagePopup = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingItems.length + 1,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    if (index == _onboardingItems.length) {
                      return _buildFinalPage();
                    }
                    return _buildOnboardingPage(_onboardingItems[index]);
                  },
                ),
              ),
              if (_currentPage < _onboardingItems.length)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _onboardingItems.length,
                            duration: AppTheme.animationNormal,
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Salta'),
                      ),
                      Row(
                        children: List.generate(
                          _onboardingItems.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingXSmall,
                            ),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 77),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: AppTheme.animationNormal,
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Avanti'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 230),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPage() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusLarge),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Image.asset(
                  'assets/images/intelligearth_logo.png',
                  height: 120,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text(
              'Benvenuto in IntelligEarth',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Inizia il tuo viaggio alla scoperta del mondo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 230),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLarge,
                  vertical: AppTheme.spacingMedium,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Inizia'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleziona la tua lingua',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Choose your language',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.neutralColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LanguageOption(
                  flag: '🇮🇹',
                  language: 'Italiano',
                  locale: const Locale('it'),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                _LanguageOption(
                  flag: '🇬🇧',
                  language: 'English',
                  locale: const Locale('en'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String language;
  final Locale locale;

  const _LanguageOption({
    required this.flag,
    required this.language,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          provider.setLocale(locale);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 77),
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
