import '../../autheurs/model/author_model.dart';
import '../../livres/dto/book_dto.dart';
import '../../livres/models/book_model.dart';
import '../../structures/model/structure_model.dart';


class AccueilData {
  final List<Book>      livresRecomandes;
  final List<Structure> structuresAdherees;
  final List<Structure> structuresRecomandees;
  final List<Author>    auteurs;

  const AccueilData({
    required this.livresRecomandes,
    required this.structuresAdherees,
    required this.structuresRecomandees,
    required this.auteurs,
  });
}