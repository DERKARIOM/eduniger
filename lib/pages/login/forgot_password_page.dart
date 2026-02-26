import 'package:flutter/material.dart';

import '../../infoApp/hachagePassword.dart';
import '../../infoApp/versionAPP_tocken.dart';
import '../../models/modelUser.dart';
import '../../services/changePassword_api.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String passwordHach='';
  String _appVersion='';
  String finalMessage='';
  String _errorMessage = '';
  bool _isLoading = false;
  Future<void> _loadAppInfo() async {
    _appVersion = await AppInfo.getAppVersion();
    setState(() {});
  }
  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _errorMessage = '';

      // Validation des champs
      if (_phoneController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer votre numéro';
        return;
      }
      if (_emailController.text.isEmpty ||
          !_emailController.text.contains('@')) {
        _errorMessage = 'Veuillez entrer un email valide';
        return;
      }
      if (_passwordController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer un nouveau mot de passe';
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _errorMessage = 'Les mots de passe ne correspondent pas';
        return;
      }

    });
    try {
      setState(() {
        //passwordHach= _passwordController.text;
        passwordHach = PasswordUtil.hashPassword(_passwordController.text);
      });
      AuthResponse response = await AuthService.changePassword(
        id_number: _phoneController.text.trim(),
        mail: _emailController.text.trim(),
        password: passwordHach,
      );
      setState(() {
        _isLoading = false;
      });
      //response.isSuccess &&
      if (response.data != null) {
        try {
          // 1. Afficher le message
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Mot de passe changé avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2), // Temps d'affichage
          ),
          );

          // 2. Attendre un court instant ou rediriger immédiatement
          // Si vous voulez que l'utilisateur lise, ajoutez un Future.delayed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            }
          });

        } catch (e) {
          print('Erreur lors de la redirection : $e');
        }
      }else {
        // ERREUR RETOURNÉE PAR L'API (Identifiants incorrects, etc.)
        String apiMessage = response.message;

        setState(() {
          _isLoading = false; // Arrêter le chargement

          // On filtre les messages techniques de l'API pour les traduire
          if (apiMessage.contains('noFoundIdNumberOrEmail')) {
            _errorMessage = "Le numéro ou l'email est incorrect.";
          } else {
            // Message générique si l'erreur est différente
            _errorMessage = "Erreur ";
          }
        });

        print("Erreur API: $apiMessage");
      }
    } catch (e) {
      // ERREUR TECHNIQUE (Réseau, Timeout, Crash serveur)
      setState(() {
        _isLoading = false;
        if (e.toString().contains('SocketException')) {
          _errorMessage =
          "Pas de connexion internet. Veuillez vérifier votre réseau.";
        } else if (e.toString().contains('TimeoutException')) {
          _errorMessage =
          "Le serveur met trop de temps à répondre. Réessayez plus tard.";
        } else {
          _errorMessage =
          "Une erreur inattendue est survenue. Veuillez réessayer.";
        }
      });
      // Optionnel : imprimer l'erreur réelle dans la console pour le debug
      debugPrint('Login Error: $e');
    }
  }
    // Logique de changement de mot de passe


  @override
  Widget build(BuildContext context) {
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
            // Image "Mot de passe oublié"
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
                  // Champ Numéro de téléphone
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Entrer votre numéro',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Champ Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'exemple@gmail.com',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Champ Nouveau mot de passe
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Nouveau mot de passe',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Champ Confirmation mot de passe
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirmer le mot de passe',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Message d'erreur
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Bouton de changement de mot de passe
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
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

                  // Version
                  const Text(
                    'Version : 3.1.3',
                    style: TextStyle(
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
  }
}