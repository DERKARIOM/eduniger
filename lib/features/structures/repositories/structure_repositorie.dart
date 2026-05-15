import 'package:eduniger/features/livres/models/book_model.dart';

import '../model/structure_model.dart';

abstract class StructureRepositorie {
  Future<List<Structure>> structures(String numero);
  Future<List<Book>> livre_structure(String numero, int id);
}