import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intelligearth_mobile/services/auth_service.dart';
import '../theme/app_theme.dart';
import 'sign_up_screen.dart';
import '../services/preferences_service.dart';
import 'package:geolocator/geolocator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? errorMessage;
  bool _isLocationPermissionChecked = false;

  late final AnimationController _controller;
  Animation<double>? _fadeInAnimation;

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

    _controller.forward();
    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    final rememberMe = await _preferencesService.getRememberMe();
    if (!mounted) return;

    setState(() => _rememberMe = rememberMe);

    if (rememberMe) {
      final storedUser = await _preferencesService.getStoredUser();
      if (!mounted) return;

      if (storedUser != null) {
        // Check if we already have location permission
        final hasLocationPermission = await _preferencesService.getLocationPermission();
        if (!mounted) return;

        if (hasLocationPermission) {
          // Se abbiamo già sia il login che i permessi, andiamo direttamente alla home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Se abbiamo il login ma non i permessi, chiediamoli prima di andare alla home
          final permissionGranted = await _checkLocationPermission();
          if (!mounted) return;

          if (permissionGranted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    }
  }

  Future<bool> _checkLocationPermission() async {
    if (_isLocationPermissionChecked) return true;

    final hasLocationPermission = await _preferencesService.getLocationPermission();

    if (hasLocationPermission) {
      setState(() => _isLocationPermissionChecked = true);
      return true;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      _showLocationDialog(
        'Servizi di localizzazione disattivati',
        'Per una migliore esperienza, attiva i servizi di localizzazione.',
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        _showLocationDialog(
          'Permesso negato',
          'Per utilizzare tutte le funzionalità dell\'app, concedi l\'accesso alla posizione.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      _showLocationDialog(
        'Permesso negato permanentemente',
        'Per utilizzare tutte le funzionalità dell\'app, concedi l\'accesso alla posizione dalle impostazioni del dispositivo.',
        true,
      );
      return false;
    }

    await _preferencesService.setLocationPermission(true);
    setState(() => _isLocationPermissionChecked = true);
    return true;
  }

  void _showLocationDialog(String title, String message, [bool openSettings = false]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (openSettings) {
                  Geolocator.openLocationSettings();
                }
              },
              child: Text(openSettings ? 'Apri Impostazioni' : 'Ho capito'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final signedInUser = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (signedInUser != null) {
        await _authService.rememberUser(_rememberMe);
        if (!mounted) return;
        
        // Check location permission after successful login
        final hasPermission = await _checkLocationPermission();
        if (!mounted) return;

        // Proceed to home only if we have location permission
        if (hasPermission) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          errorMessage = 'Credenziali non valide. Riprova.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Si è verificato un errore. Riprova più tardi.';
        _isLoading = false;
      });
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showRecoveryDialog() async {
    if (!mounted) return;

    final emailController = TextEditingController();
    bool isLoading = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Recupera Password',
              style: TextStyle(
                color: AppTheme.textOnLightColor,
                fontWeight: FontWeight.w600,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Inserisci la tua email per ricevere le istruzioni di recupero',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                  prefixIcon:
                      Icon(Icons.email_rounded, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Annulla',
                  style: TextStyle(color: AppTheme.textOnPrimaryColor)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Inserisci un indirizzo email valido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      final success = await _authService
                          .resetPassword(emailController.text);

                      if (!context.mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Email di recupero inviata a ${emailController.text}'
                                : 'Errore nell\'invio dell\'email di recupero',
                          ),
                          backgroundColor: success
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Invia', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: FadeTransition(
              opacity: _fadeInAnimation!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.textOnPrimaryColor,
                          width: 1,
                        ),
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
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Text(
                    'Bentornato',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textOnPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    'Accedi per continuare la tua missione',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textOnPrimaryColor
                              .withValues(alpha: 179),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          style: TextStyle(color: AppTheme.textOnPrimaryColor),
                          decoration: InputDecoration(
                            filled: false,
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: AppTheme.textOnPrimaryColor,
                            ),
                            labelStyle:
                                TextStyle(color: AppTheme.textOnPrimaryColor),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                              borderSide: BorderSide(
                                  color: AppTheme.textOnPrimaryColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                              borderSide: BorderSide(
                                color: AppTheme.textOnPrimaryColor
                                    .withValues(alpha: 51),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci la tua email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: AppTheme.textOnPrimaryColor),
                          decoration: InputDecoration(
                            filled: false,
                            labelText: 'Password',
                            labelStyle:
                                TextStyle(color: AppTheme.textOnPrimaryColor),
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: AppTheme.textOnPrimaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: AppTheme.textOnPrimaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                              borderSide: BorderSide(
                                  color: AppTheme.textOnPrimaryColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                              borderSide: BorderSide(
                                color: AppTheme.textOnPrimaryColor
                                    .withValues(alpha: 51),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci la tua password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Row(
                          children: [
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return AppTheme.textOnPrimaryColor;
                                    }
                                    return Colors.transparent;
                                  },
                                ),
                                checkColor: AppTheme.primaryColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Text(
                                'Ricordami',
                                style: TextStyle(
                                  color: AppTheme.textOnPrimaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _showRecoveryDialog,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.textOnPrimaryColor,
                              ),
                              child: const Text('Password dimenticata?'),
                            ),
                          ],
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: AppTheme.spacingSmall),
                          Container(
                            padding:
                                const EdgeInsets.all(AppTheme.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withValues(alpha: 26),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacingSmall),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.errorColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingLarge),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.textOnPrimaryColor,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Accedi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Non hai un account?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textOnPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 178),
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingMedium),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: const SignUpScreen(),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textOnPrimaryColor,
                        ),
                        child: const Text(
                          'Registrati',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
