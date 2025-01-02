import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late final Animation<double> _slideAnimation;
  late final Animation<double> _pulseAnimation;
  int _currentPage = 0;
  bool _showLanguagePopup = true;
  bool _isLoading = true;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      icon: Icons.camera_alt_rounded,
      title: 'Documenta il Patrimonio',
      description:
          'Contribuisci alla conservazione dei beni culturali attraverso il monitoraggio fotografico',
      color: AppTheme.successColor,
    ),
    OnboardingItem(
      icon: Icons.architecture_rounded,
      title: 'Monitora i Cambiamenti',
      description:
          'Aiuta a preservare monumenti e infrastrutture segnalando variazioni nel tempo',
      color: AppTheme.accentColor,
    ),
    OnboardingItem(
      icon: Icons.emoji_events_rounded,
      title: 'Ottieni Riconoscimenti',
      description:
          'Ricevi punti e badge per il tuo contributo alla salvaguardia del patrimonio culturale',
      color: AppTheme.warningColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });

    _controller.repeat();
  }

  Future<void> _initializeApp() async {
    // Simula il caricamento delle risorse
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _controller.forward();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else if (_showLanguagePopup) {
      _showLanguageSelector();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildSplashScreen() : _buildOnboardingContent(),
        ),
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'app_logo',
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 51),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 26),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/intelligearth_logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_fadeInAnimation),
                  child: Column(
                    children: [
                      Text(
                        'IntelligEarth',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.textOnPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        'Documenta. Monitora. Preserva.',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textOnPrimaryColor
                                      .withValues(alpha: 179),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Center(
            child: RotationTransition(
              turns: _controller,
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.textOnPrimaryColor.withValues(alpha: 179),
                  ),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingContent() {
    return Column(
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
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Padding(
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
                      foregroundColor: AppTheme.textOnPrimaryColor,
                    ),
                    child: const Text('Salta'),
                  ),
                  Row(
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingXSmall,
                        ),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppTheme.textOnPrimaryColor
                              : AppTheme.textOnPrimaryColor
                                  .withValues(alpha: 77),
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
                      foregroundColor: AppTheme.textOnPrimaryColor,
                    ),
                    child: const Text('Avanti'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
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
                  color: AppTheme.textOnPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXLarge),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textOnPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textOnPrimaryColor.withValues(alpha: 179),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
            const Spacer(),
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 51),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 26),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/intelligearth_logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(_fadeInAnimation),
              child: Column(
                children: [
                  Text(
                    'Unisciti alla Missione',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textOnPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    'Contribuisci al monitoraggio e alla preservazione del patrimonio culturale',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textOnPrimaryColor
                              .withValues(alpha: 179),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _finishOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textOnPrimaryColor,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Accedi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                OutlinedButton(
                  onPressed: _finishOnboarding,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textOnPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                    side: BorderSide(
                      color: AppTheme.textOnPrimaryColor.withValues(alpha: 77),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                  ),
                  child: const Text(
                    'Registrati',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                Text(
                  'Accedendo, accetti i nostri Termini di Servizio e la Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            AppTheme.textOnPrimaryColor.withValues(alpha: 128),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
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
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 51),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleziona la tua lingua',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textOnPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Choose your language',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textOnPrimaryColor.withValues(alpha: 179),
                  ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
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
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.textOnPrimaryColor.withValues(alpha: 77),
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
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
                      color: AppTheme.textOnPrimaryColor,
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
