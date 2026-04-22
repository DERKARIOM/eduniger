import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../repositories/postmant_user_repositore.dart';
import '../view_models/user_view_model.dart';


class UserViewRegister extends StatefulWidget {
  const UserViewRegister({Key? key}) : super(key: key);

  @override
  State<UserViewRegister> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<UserViewRegister> {
  // Controllers : responsabilité de la View uniquement
  final TextEditingController _nameController            = TextEditingController();
  final TextEditingController _firstNameController       = TextEditingController();
  final TextEditingController _phoneController           = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
@override

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _)  {
        final vm=appState.utilisa;
        // ── Navigation après succès ──────────────────────────────────
        if (vm.registerSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.resetRegisterSuccess();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compte créé avec succès !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            });
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 3,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ── Image ────────────────────────────────────────────
                  Container(
                    height: 250,
                    margin: const EdgeInsets.all(25),
                    child: Image.asset(
                      'assets/images/img_register.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // ── Champs texte ─────────────────────────────────────
                  _buildField(_nameController,      'Entrer votre nom'),
                  const SizedBox(height: 15),
                  _buildField(_firstNameController, 'Entrer votre prénom'),
                  const SizedBox(height: 15),
                  _buildField(_phoneController,     'Entrer votre numéro',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  _buildField(_emailController,     'exemple@gmail.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildField(_passwordController,  'Votre mot de passe',
                      obscure: true),
                  const SizedBox(height: 15),
                  _buildField(_confirmPasswordController, 'Confirmer votre mot de passe',
                      obscure: true),
                  const SizedBox(height: 20),

                  // ── Dropdown Profession ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: vm.selectedProfession,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: vm.professions.map((String p) {
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      // ← délégué au ViewModel
                      onChanged: (value) => vm.selectProfession(value!),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ── Message d'erreur ─────────────────────────────────
                  if (vm.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        vm.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ── Bouton S'inscrire ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // ← appelle vm.register avec les valeurs des controllers
                      onPressed: vm.isLoading
                          ? null
                          : () => vm.register(_nameController.text.trim(),
                        _firstNameController.text.trim(),
                                _phoneController.text.trim(),
                                 _emailController.text.trim(),
                              _passwordController.text,
                         _confirmPasswordController.text,
                         vm.selectedProfession,
                        vm.firebaseToken
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
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Lien login ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous avez déjà un compte ?",
                          style: TextStyle(color: Colors.black54)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Widget réutilisable pour les champs texte ──────────────────────────
  Widget _buildField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        bool obscure = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
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
      ),
    );
  }
}