import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/services/auth_service.dart';
import '../theme/app_theme.dart';
import 'sign_up_screen.dart';

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
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
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
              style: TextStyle(color: AppTheme.secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Inserisci la tua email per ricevere le istruzioni di recupero',
                style: TextStyle(color: AppTheme.neutralColor),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                  style: TextStyle(color: AppTheme.neutralColor)),
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
                  : const Text('Invia'),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: FadeTransition(
                opacity: _fadeInAnimation,
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
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.secondaryColor.withValues(alpha: 26),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Bentornato',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),
                            Text(
                              'Accedi per continuare la tua avventura',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.neutralColor,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingLarge),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                                labelStyle:
                                    TextStyle(color: AppTheme.primaryColor),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor
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
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    TextStyle(color: AppTheme.primaryColor),
                                prefixIcon: Icon(
                                  Icons.lock_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                  borderSide: BorderSide(
                                      color: AppTheme.primaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showRecoveryDialog,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                ),
                                child: const Text('Password dimenticata?'),
                              ),
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: AppTheme.spacingSmall),
                              Container(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacingSmall),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.errorColor.withValues(alpha: 26),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusSmall),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: AppTheme.errorColor,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                        width: AppTheme.spacingSmall),
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
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingMedium,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Accedi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Non hai un account?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Registrati',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
