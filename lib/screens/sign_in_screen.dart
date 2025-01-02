import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intelligearth_mobile/services/auth_service.dart';
import '../theme/app_theme.dart';
import 'sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? errorMessage;

  late final AnimationController _controller;
  late final Animation<double> _fadeInAnimation;

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
      if (_emailController.text == 'mary' &&
          _passwordController.text == '1234') {
        await Future.delayed(
            const Duration(seconds: 1)); // Simula il caricamento

        // Salva i dati dell'utente hardcoded come se fosse un utente normale
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('jwt_token', 'fake_token_for_mary');
          await prefs.setString(
              'user_data',
              json.encode({
                'id': 'mary_id',
                'name': 'Mary',
                'email': 'mary@example.com',
                'role': 'user',
              }));
        }
        await prefs.setBool('remember_me', _rememberMe);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
        _rememberMe,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = 'Credenziali non valide. Riprova.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Si è verificato un errore. Riprova più tardi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _showRecoveryDialog() async {
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
              opacity: _fadeInAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingXLarge),
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
                    'Accedi per continuare a contribuire alla documentazione del patrimonio culturale',
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
                          style: Theme.of(context).textTheme.titleMedium,
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
                          style: Theme.of(context).textTheme.titleMedium,
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
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppTheme.textOnPrimaryColor;
                                  }
                                  return AppTheme.textOnPrimaryColor
                                      .withValues(alpha: 51);
                                },
                              ),
                              checkColor: AppTheme.primaryColor,
                            ),
                            Text(
                              'Ricordami',
                              style: TextStyle(
                                color: AppTheme.textOnPrimaryColor,
                                fontSize: 14,
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
