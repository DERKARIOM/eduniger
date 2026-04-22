import '../models/modelCategorie.dart';

abstract class CategorieRepositorie {
 Future <List<MCategorie>> categories(String numero);
}