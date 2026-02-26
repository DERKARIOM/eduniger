import 'dart:async';

import 'package:eduniger/pages/login/forgot_password_page.dart';
import 'package:eduniger/pages/bootomBart/main_page.dart';
import 'package:eduniger/pages/login/register_page.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eduniger/services/login_api.dart';

import '../../infoApp/hachagePassword.dart';
import '../../infoApp/versionAPP_tocken.dart';
import '../../localDataBase/sqlflitEduniger.dart';
import '../../models/modelUser.dart';
import '../../services/login_api.dart';
import '../../services/recomandation_api.dart';
import '../bootomBart/accueil_page.dart'; // Importer le service d'authentification

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
  bool _isPasswordVisible = false;
  bool _visible = false;
  String passwordHach='';
  String _firebaseToken = '';
  String _appVersion = '';
  String _idUser = '';
  _passeDirectement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
  Future<void> _loadAppInfo() async {
    _firebaseToken = await AppInfo.getFirebaseToken();
    _appVersion = await AppInfo.getAppVersion();
    setState(() {});
  }
  void initState() {
    super.initState();
    _loadAppInfo();
  }
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Validation des champs
    if (_phoneController.text.isEmpty && _passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Votre matricule et mot de passe svp";
      });
      return;
    }

    if (_phoneController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Votre matricule svp";
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Votre mot de passe svp";
      });
      return;
    }
    try {
      setState(() {
         //passwordHach= _passwordController.text;
         passwordHach= PasswordUtil.hashPassword(_passwordController.text);
         print("Hash envoyé: $passwordHach");

      });
      // Appel du service d'authentification
      AuthResponse response = await AuthService.login(
        id_number: _phoneController.text.trim(),
        password: passwordHach,
        token: _firebaseToken,
        version: _appVersion,
      );
      //print("Réponse API message: ${response.message}");
     // print("Réponse API data: ${response.data}");

      setState(() { _isLoading = false; });
      //response.isSuccess &&
      if ( response.data != null) {
        //print("Utilisateur trouvé: ${response.data!.user.name}");
        // CONNEXION RÉUSSIE
        User user = response.data!.user;
        String accessToken = response.data!.accessToken;
        //print("Token : $accessToken");
        //print("Utilisateur :${user}");

        try {
          await DatabaseHelper.instance.saveUser(user, accessToken);
          print("Utilisateur sauvegardé localement");
          try {
            await DatabaseHelper.instance.saveIdNumber(_phoneController.text.trim());
            print("ID de l'utilisateur sauvegardé localement");
            final idRecupere = await DatabaseHelper.instance.getIdNumber();

            setState(() {
              _idUser = idRecupere.toString();
            });
            print("ID de l'utilisateur récupéré : $_idUser");
          } catch (dbError) {
            print('Erreur lors de la sauvegarde de l\'ID de l\'utilisateur : $dbError');
          }


          print("ID de l'utilisateur défini pour la navigation : $_idUser");

        } catch (dbError) {
          print("Erreur SQL : $dbError");
          // En cas d'erreur DB, on utilise quand même l'ID de l'API pour ne pas bloquer l'utilisateur
        }
        //print(accessToken);
        //print(user.name);
        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccueilPage(
            IdNumber: _idUser,
            Version: _appVersion,

          )),
        );
        */
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );

      /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );

         */

      } else {
        // ERREUR RETOURNÉE PAR L'API (Identifiants incorrects, etc.)
        String apiMessage = response.message.toLowerCase();
        String finalMessage;

        // On filtre les messages techniques de l'API pour les traduire
        if (apiMessage.contains('incorrectpassword')) {
          finalMessage = " le mot de passe est incorrect.";
        } else if (apiMessage.contains('accountnotexist')) {
          finalMessage = "cet  compte n'existe pas.";
        }else if (apiMessage.contains('account locked')) {
          finalMessage = "Votre compte est temporairement bloqué. Veuillez contacter le support.";
        } else if (apiMessage.contains('update required')) {
          finalMessage = "Veuillez mettre à jour votre application pour continuer.";
        }
        else if (apiMessage.isNotEmpty) {
          // Si l'erreur est inconnue mais que l'API a renvoyé un message, on l'affiche
          finalMessage = apiMessage;
          print(apiMessage);
        }
        else {
          // Message par défaut si l'API ne retourne rien
          finalMessage = "Une erreur d'authentification est survenue.";
        }
        setState(() {
          _errorMessage = finalMessage;
        });
      }
    } catch (e) {
      // ERREUR TECHNIQUE (Réseau, Timeout, Crash serveur)
      setState(() {
        _isLoading = false;
        if (e.toString().contains('SocketException')) {
          _errorMessage = "Pas de connexion internet. Veuillez vérifier votre réseau.";
        } else if (e.toString().contains('TimeoutException')) {
          _errorMessage = "Le serveur met trop de temps à répondre. Réessayez plus tard.";
        } else {
          _errorMessage = "Une erreur inattendue est survenue. Veuillez réessayer.";
        }
      });
      // Optionnel : imprimer l'erreur réelle dans la console pour le debug
      debugPrint('Login Error: $e');
    }
  }

  void _handleGoogleLogin() {
    // Logique de connexion avec Google
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  void _handleCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  @override

    Widget build(BuildContext context) => Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
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
                      obscureText: !_isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Votre mot de passe ?',
                        prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        }, icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black54),

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
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Bouton de connexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:  _isLoading ? null : _handleLogin,//_passeDirectement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                        style: TextStyle(color: Colors.black54,fontSize: 10),
                      ),
                      TextButton(
                        onPressed: _handleCreateAccount,
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 14,
                              decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Version
                   Text(
                     'Version : ${_appVersion}',
                    style: TextStyle(
                      color: Colors.blue,
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