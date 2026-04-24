import '../model/structure_model.dart';

abstract class StructureRepositorie {
  Future<List<Structure>> structures(String numero);
}