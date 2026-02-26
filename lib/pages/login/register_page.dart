import 'package:flutter/material.dart';

import '../../infoApp/hachagePassword.dart';
import '../../infoApp/versionAPP_tocken.dart';
import '../../models/modelUser.dart';
import '../../services/register_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String passwordHach='';
  String _appVersion='';
  String finalMessage='';
  String numberProfession='';
  String _errorMessage = '';
  bool _isLoading = false;
  Future<void> _loadAppInfo() async {
    _appVersion = await AppInfo.getAppVersion();
    setState(() {});
  }
  String _selectedProfession = 'Sélectionnez votre profession';


  final List<String> _professions = [
    'Sélectionnez votre profession',
    'Élève',
    'Étudiant',
    'Enseignant',
    'Professionnel',
    'Autre',
  ];

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

  Future<void> _handleRegister() async {
    // 1. Reset et Validation (Ajout de setState pour mettre à jour l'UI)
    setState(() {
      _errorMessage = '';
    });

    if (_nameController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }

    if (_selectedProfession == 'Sélectionnez votre profession') {
      setState(() => _errorMessage = 'Veuillez sélectionner une profession');
      return;
    }

    // 2. Préparation des données
    setState(() {
      _isLoading = true;
      // Détermination du code profession
      switch (_selectedProfession) {
        case 'Élève': numberProfession = '1'; break;
        case 'Étudiant': numberProfession = '2'; break;
        case 'Enseignant': numberProfession = '3'; break;
        case 'Professionnel': numberProfession = '4'; break;
        case 'Autre': numberProfession = '5'; break;
        default: numberProfession = '0';
      }
      passwordHach = PasswordUtil.hashPassword(_passwordController.text);
    });

    // RÉCUPÉRER LA VERSION
    if (_appVersion.isEmpty) {
      _appVersion = await AppInfo.getAppVersion();
    }

    try {
      // 3. Appel API
      AuthResponse response = await AuthService.register(
        id_number: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        // ATTENTION : Vérifiez si votre API attend 'first_name' ou 'fist_name'
        // Dans votre code actuel c'est 'fist_name' (faute d'orthographe probable)
        first_name: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        password: passwordHach,
        profession: numberProfession,
        version: _appVersion,
      );

      setState(() => _isLoading = false);

      if (response.status == 'success') {
        // SUCCÈS
        // Remplacez votre bloc de sélection actuel par celui-ci :    if (response.status == 'success') {
        // SUCCÈS
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // On attend que la SnackBar soit visible avant de rediriger
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });

      } else {
        // ÉCHEC API
        setState(() {
          // Traduction du message "existingAccount" reçu de Postman
          if (response.message.contains('existingAccount')) {
            _errorMessage = "Ce numéro de téléphone est déjà utilisé.";
          } else if (response.message.contains('existingEmail')) {
            _errorMessage = "Cet email est déjà utilisé.";
          } else {
            _errorMessage = response.message;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur de connexion au serveur.";
      });
    }
  }
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
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

              // Image d'inscription
              Container(
                height: 250,
                margin: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/images/img_register.png',
                  fit: BoxFit.contain,
                ),
              ),

              // Champ Nom
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Entrer votre nom',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Champ Prénom
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
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Entrer votre prénom',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Champ Numéro
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
              ),

              const SizedBox(height: 15),

              // Champ Email
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
              ),

              const SizedBox(height: 15),

              // Champ Mot de passe
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
                    hintText: 'Votre mot de passe',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Champ Confirmation mot de passe
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
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirmer votre mot de passe',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Spinner Profession
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedProfession,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _professions.map((String profession) {
                    return DropdownMenuItem<String>(
                      value: profession,
                      child: Text(
                        profession,
                        style: const TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProfession = newValue!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

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

              // Bouton d'inscription
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
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lien vers la page de connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous avez déjà un compte ?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Se connecte',
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
            ],
          ),
        ),
      ),
    );
  }
}