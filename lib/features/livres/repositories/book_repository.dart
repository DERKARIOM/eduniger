import 'package:eduniger/features/livres/models/book_model.dart';
import 'package:eduniger/features/livres/models/detaille_book_model.dart';

import '../dto/detaille_book_dto.dart';
import '../models/livres_model.dart';

abstract class BookRepository {
  Future <List<LivresModel>> livres(String number);
  Future <BookDetailDto> detail(String numero,String id_book);
  Future <List<Book>> livreTelecharger(String numero,String version);
  Future <List<Book>> livreElectronique(String numero);
  Future <List<Book>> livreAudio(String numero);
  Future <List<Book>> livreEmprunter(String numero);
  Future <String> vue(String numero,String id_book);
  Future <String> like(String numero,String id_book);
  Future <String> dislike(String numero,String id_book);
  Future <String> abonner(String numero,String id_book);
  Future <String> comment(String numero,String id_book,String comment);
  Future<String> reserverLivre(String numero, String idBook);


}