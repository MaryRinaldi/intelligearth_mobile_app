import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/services/auth_service.dart';
import '../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _signUp() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Le password non corrispondono';
        _isLoading = false;
      });
      return;
    }

    final user = await _authService.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = 'Registrazione fallita';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 56, 79, 156).withValues(alpha: 230),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 31),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTheme.spacingXLarge),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: false,
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_rounded,
                          color: AppTheme.textOnPrimaryColor),
                      labelStyle: TextStyle(color: AppTheme.textOnPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                            color: AppTheme.textOnPrimaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                          color:
                              AppTheme.textOnPrimaryColor.withValues(alpha: 51),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: false,
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded,
                          color: AppTheme.textOnPrimaryColor),
                      labelStyle: TextStyle(color: AppTheme.textOnPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                            color: AppTheme.textOnPrimaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                          color:
                              AppTheme.textOnPrimaryColor.withValues(alpha: 51),
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
                      filled: false,
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_rounded,
                          color: AppTheme.textOnPrimaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppTheme.textOnPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      labelStyle: TextStyle(color: AppTheme.textOnPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                            color: AppTheme.textOnPrimaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                          color:
                              AppTheme.textOnPrimaryColor.withValues(alpha: 51),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      filled: false,
                      labelText: 'Conferma Password',
                      prefixIcon: Icon(Icons.lock_rounded,
                          color: AppTheme.textOnPrimaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppTheme.textOnPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      labelStyle: TextStyle(color: AppTheme.textOnPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                            color: AppTheme.textOnPrimaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(
                          color:
                              AppTheme.textOnPrimaryColor.withValues(alpha: 51),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Conferma la tua password';
                      }
                      return null;
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spacingSmall),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSmall),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 26),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: AppTheme.errorColor, size: 20),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textOnPrimaryColor,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
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
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Registrati',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textOnPrimaryColor,
              ),
              child: const Text(
                'Hai già un account? Accedi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
