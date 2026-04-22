import '../model/acceuil_model.dart';

abstract class AccueilRepository {
  Future<AccueilData> chargerAccueil(String numero, String version);
  Future<String>      adherer(String numero,  String idStructure);
  Future<String>      detacher(String numero, String idStructure);
}