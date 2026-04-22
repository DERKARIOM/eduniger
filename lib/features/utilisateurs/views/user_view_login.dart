import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eduniger/appstate.dart';
import 'package:eduniger/features/utilisateurs/models/user_model.dart';
import 'package:eduniger/features/utilisateurs/views/user_view_change_password.dart';
import 'package:eduniger/features/utilisateurs/views/user_view_register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class user_view_login extends StatefulWidget {
  const user_view_login({Key? key}) : super(key: key);

  @override
  State<user_view_login> createState() => _LoginPageState();
}

class _LoginPageState extends State<user_view_login> {

  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String passwordhach='';
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Callbacks de navigation (View seule responsable de naviguer) ───────




  @override
  Widget build(BuildContext context) {
    // Consumer reconstruit uniquement ce widget quand le ViewModel notifie
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final vm=appState.utilisa;
        // ── Navigation après connexion réussie ─────────────────────────
        // addPostFrameCallback évite d'appeler Navigator pendant un build
        if (vm.loginSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.resetLoginSuccess();
            Navigator.pushReplacementNamed(context, '/mainPage');
          });
        }

        return Scaffold(
          body: Container(
            height: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.white70],
              ),
            ),

            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // ── Logo ─────────────────────────────────────────
                      Container(
                        height: 220,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Image.asset(
                          'assets/images/img_login_edu_niger.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // ── Champ matricule ───────────────────────────────
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                        child: Row(
                          children: [
                            CountryCodePicker(
                              onChanged: (country) =>
                                  vm.setCountryCode(country.dialCode ?? '+227'),
                              initialSelection: 'NE',
                              favorite: const ['+227', 'NE'],
                              showFlag: true,
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Entrer votre numéro',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Champ mot de passe ────────────────────────────
                      Container(
                        height: 65,
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
                          controller: _passwordController,
                          // ← vm.isPasswordVisible contrôle l'affichage
                          obscureText: !vm.isPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: 'Votre mot de passe ?',
                            prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                            suffixIcon: IconButton(
                              // ← délégué au ViewModel
                              onPressed: vm.togglePasswordVisibility,
                              icon: Icon(
                                vm.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      // ── Mot de passe oublié ───────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:(){ appState.update((){
                            vm.clearError();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => UserViewChangePassword()));
                          });
                          },

                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      // ── Message d'erreur ──────────────────────────────
                      if (vm.errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            vm.errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ── Bouton Se connecter ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // ← appelle vm.login avec les valeurs des controllers

                          onPressed:
                            vm.isLoading
                                ? null
                                : () => vm.login(
                              // verification.se_connecter(_phoneController.text.trim(), _passwordController.text);
                              _phoneController.text.trim(),
                              _passwordController.text,

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
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── Bouton Google ─────────────────────────────────
                      InkWell(
                        onTap: () {/* TODO: Google login */},
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/img_google.png',
                                width: 25,
                                height: 25,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continuer avec Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── Créer un compte ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Vous n'avez pas de compte ?",
                            style: TextStyle( fontSize: 10),
                          ),
                          TextButton(
                            onPressed:(){ appState.update((){
                              vm.clearError();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => UserViewRegister()));
                              });
                              },
                            child: const Text(
                              'Créer un compte',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Version ───────────────────────────────────────
                      Text(
                        'Version : ${vm.appVersion}',
                        //style: const TextStyle(color: Colors.blue),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}