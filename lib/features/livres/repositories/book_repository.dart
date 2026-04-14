import 'package:eduniger/features/livres/models/book_model.dart';
import 'package:eduniger/features/livres/models/detaille_book_model.dart';

abstract class BookRepository {
  Future <List<BookModel>> livreRecomander(String numero,String version);
  Future <List<BookModel>> livres(String numero,String version);
  Future <DetailleBookModel> detail(String numero,String id_book);
  Future <List<BookModel>> livreTelecharger(String numero,String version);
  Future <List<BookModel>> livreElectronique(String numero);
  Future <List<BookModel>> livreAudio(String numero);
  Future <List<BookModel>> livreEmprunter(String numero);
  Future <String> vue(String numero,String id_book);
  Future <String> like(String numero,String id_book);
  Future <String> dislike(String numero,String id_book);
  Future <String> abonner(String numero,String id_book);
  Future <String> comment(String numero,String id_book,String comment);


}