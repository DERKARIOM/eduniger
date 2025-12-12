import 'package:eduniger/pages/forgot_password_page.dart';
import 'package:eduniger/pages/main_page.dart';
import 'package:eduniger/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _countryCode = '+227'; // Code Niger par défaut
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Ajoutez votre logique de connexion ici
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        if(_phoneController.text.isEmpty && _passwordController.text.isEmpty) {
          _errorMessage = "Votre matricule et mot de passe svp";
          return;
        }
        if(_phoneController.text.isEmpty && _passwordController.text.isNotEmpty){
          _errorMessage = "Votre matricule svp";
          return;
        }
        if(_passwordController.text.isEmpty){
          _errorMessage = "Votre mot de passe svp";
          return;
        }
        if(_phoneController.text == "94961793" && _passwordController.text == "Password@2025"){
          _isLoading = true;
        }
        if(_isLoading == true)
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      });
    });
  }

  void _handleGoogleLogin() {
    // Logique de connexion avec Google
  }

  void _handleForgotPassword() {
    // Navigation vers la page de récupération de mot de passe
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  void _handleCreateAccount() {
    // Navigation vers la page de creation de compte
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.app_color,
              Colors.white70,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Logo/Image
                  Container(
                    height: 220,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Image.asset(
                      'assets/images/img_login_edu_niger.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Champ numéro de téléphone avec code pays
                  Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              _countryCode = country.dialCode ?? '+227';
                            });
                          },
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

                  // Champ mot de passe
                  Container(
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
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Votre mot de passe ?',
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

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                            decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                  ),

                  // Message d'erreur
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Bouton de connexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.app_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton Google
                  InkWell(
                    onTap: _handleGoogleLogin,
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

                  // Créer un compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous n'avez pas de compte ?",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: _handleCreateAccount,
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Version
                  const Text(
                    'Version : 3.1.3',
                    style: TextStyle(
                      color: Colors.app_color,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}