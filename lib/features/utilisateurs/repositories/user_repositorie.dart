import 'package:eduniger/features/utilisateurs/models/user_model.dart';

abstract class UserRepositorie {
  Future <UserModel> seconecter(String numero,String mot_de_passe,String token,String version);
  Future <String> creer_compte(String numero,String email, String nom,String prenom,String mot_de_passe,String profession,String version);
  Future <String> changer_mot_de_passe(String numero,String email,String mot_de_passe_confirmer);
  Future <String> changer_profil(UserModel user);
}