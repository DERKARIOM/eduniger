import 'package:flutter/material.dart';

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

  String _selectedProfession = 'Sélectionnez votre profession';
  String _errorMessage = '';
  bool _isLoading = false;

  final List<String> _professions = [
    'Sélectionnez votre profession',
    'Étudiant',
    'Enseignant',
    'Professionnel',
    'Ingénieur',
    'Médecin',
    'Avocat',
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

  void _handleRegister() {
    setState(() {
      _errorMessage = '';

      // Validation des champs
      if (_nameController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer votre nom';
        return;
      }
      if (_firstNameController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer votre prénom';
        return;
      }
      if (_phoneController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer votre numéro';
        return;
      }
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _errorMessage = 'Veuillez entrer un email valide';
        return;
      }
      if (_passwordController.text.isEmpty) {
        _errorMessage = 'Veuillez entrer un mot de passe';
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _errorMessage = 'Les mots de passe ne correspondent pas';
        return;
      }
      if (_selectedProfession == 'Sélectionnez votre profession') {
        _errorMessage = 'Veuillez sélectionner une profession';
        return;
      }

      _isLoading = true;
    });

    // Logique d'inscription
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _navigateToLogin() {
    Navigator.pop(context);
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
              TextField(
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

              const SizedBox(height: 15),

              // Champ Prénom
              TextField(
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

              const SizedBox(height: 15),

              // Champ Numéro
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

              // Champ Mot de passe
              TextField(
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

              const SizedBox(height: 15),

              // Champ Confirmation mot de passe
              TextField(
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.app_color,
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

              const SizedBox(height: 20),

              // Lien vers la page de connexion
              TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  'Vous avez déjà un compte ? Se connecter',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}