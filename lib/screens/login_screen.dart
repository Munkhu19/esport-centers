import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import '../data/firebase_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_toggle_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String _authErrorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'invalid-email':
        return l10n.authInvalidEmail;
      case 'operation-not-allowed':
        return l10n.authEmailPasswordNotEnabled;
      case 'user-disabled':
        return l10n.authUserDisabled;
      case 'too-many-requests':
        return l10n.authTooManyRequests;
      case 'invalid-api-key':
      case 'api-key-not-valid.-please-pass-a-valid-api-key.':
        return l10n.authApiKeyInvalid;
      case 'network-request-failed':
        return l10n.authNetworkError;
      case 'email-already-in-use':
        return l10n.usernameAlreadyExists;
      case 'weak-password':
        return l10n.authWeakPassword;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.invalidCredentials;
      default:
        return l10n.authUnknownError;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF15803D),
      ),
    );
  }

  Future<void> _submitAuth() async {
    final l10n = AppLocalizations.of(context)!;
    if (!firebaseAvailable) {
      _showError(l10n.authFirebaseNotInitialized);
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }
    if (_isSignUp && password != confirmPassword) {
      _showError(l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _isSignUp = false;
          });
        }
        _showSuccess(l10n.accountCreated);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authErrorMessage(l10n, e.code));
    } catch (_) {
      _showError(l10n.authUnknownError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0F766E)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.78),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF334155)),
      floatingLabelStyle: const TextStyle(color: Color(0xFF0F766E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    const Color(0xFFFFF7ED),
                    const Color(0xFFECFEFF),
                    controller.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFE0F2FE),
                    const Color(0xFFFFEDD5),
                    controller.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -90,
                  left: -50,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.22),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  right: -40,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF97316).withValues(alpha: 0.18),
                    ),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: SafeArea(child: LanguageToggleButton()),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.56),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFF0F766E,
                                    ).withValues(alpha: 0.12),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF0F766E),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  _isSignUp ? l10n.signUp : l10n.signIn,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                 TextField(
                                   controller: emailController,
                                   keyboardType: TextInputType.emailAddress,
                                   cursorColor: const Color(0xFF0F766E),
                                   style: const TextStyle(
                                     color: Color(0xFF0F172A),
                                     fontSize: 16,
                                   ),
                                   decoration: _inputDecoration(
                                     label: l10n.email,
                                     icon: Icons.person_outline_rounded,
                                   ),
                                 ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  cursorColor: const Color(0xFF0F766E),
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                  ),
                                  decoration: _inputDecoration(
                                    label: l10n.password,
                                    icon: Icons.key_outlined,
                                  ),
                                ),
                                if (_isSignUp) ...[
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    cursorColor: const Color(0xFF0F766E),
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                    ),
                                    decoration: _inputDecoration(
                                      label: l10n.confirmPassword,
                                      icon: Icons.verified_user_outlined,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                    child: ElevatedButton(
                                     onPressed: _isLoading ? null : _submitAuth,
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: const Color(0xFF0F766E),
                                       foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                     child: _isLoading
                                         ? const SizedBox(
                                             width: 20,
                                             height: 20,
                                             child: CircularProgressIndicator(
                                               strokeWidth: 2.2,
                                               color: Colors.white,
                                             ),
                                           )
                                          : Text(
                                              _isSignUp ? l10n.signUp : l10n.signIn,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _isSignUp = !_isSignUp;
                                          });
                                        },
                                  child: Text(
                                    _isSignUp
                                        ? l10n.switchToSignIn
                                        : l10n.switchToSignUp,
                                  ),
                                ),
                               ],
                             ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
