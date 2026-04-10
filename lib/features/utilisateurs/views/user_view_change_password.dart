import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/user_view_model.dart';


class UserViewChangePassword extends StatefulWidget {
  const UserViewChangePassword({Key? key}) : super(key: key);

  @override
  State<UserViewChangePassword> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<UserViewChangePassword> {
  // Controllers : responsabilité de la View uniquement
  final TextEditingController _phoneController           = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {

        // ── Navigation après succès ────────────────────────────────────
        if (vm.changeSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.resetChangeSuccess();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mot de passe changé avec succès !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            });
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 3,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Image ──────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 60, top: 20),
                  child: Image.asset(
                    'assets/images/forget_password.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      // ── Champs texte ─────────────────────────────────
                      _buildField(
                        _phoneController,
                        'Entrer votre numéro',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        _emailController,
                        'exemple@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        _passwordController,
                        'Nouveau mot de passe',
                        obscure: true,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        _confirmPasswordController,
                        'Confirmer le mot de passe',
                        obscure: true,
                      ),
                      const SizedBox(height: 20),

                      // ── Message d'erreur ──────────────────────────────
                      if (vm.errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            vm.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // ── Bouton Changer ────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // ← appelle vm.changerMotDePasse avec valeurs controllers
                          onPressed: vm.isLoading
                              ? null
                              : () => vm.changerMotDePasse(
                                    _phoneController.text.trim(),
                                     _emailController.text.trim(),
                                   _passwordController.text,
                             _confirmPasswordController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: vm.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Changer le mot de passe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Version dynamique ─────────────────────────────
                      Text(
                        'Version : ${vm.appVersion}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Widget réutilisable ────────────────────────────────────────────────
  Widget _buildField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        bool obscure = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}