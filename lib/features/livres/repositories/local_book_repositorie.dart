import 'package:eduniger/features/livres/models/book_model.dart';
import 'package:eduniger/features/livres/models/detaille_book_model.dart';
import 'package:eduniger/features/livres/repositories/book_repository.dart';

class LocalBookRepositorie implements BookRepository{
  @override
  Future<DetailleBookModel> detail(String numero, String id_book) {
    // TODO: implement detail
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livreAudio(String numero) {
    // TODO: implement livreAudio
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livreElectronique(String numero) {
    // TODO: implement livreElectronique
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livreEmprunter(String numero) {
    // TODO: implement livreEmprunter
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livreRecomander(String numero, String version) {
    // TODO: implement livreRecomander
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livreTelecharger(String numero, String version) {
    // TODO: implement livreTelecharger
    throw UnimplementedError();
  }

  @override
  Future<List<BookModel>> livres(String numero, String version) {
    // TODO: implement livres
    throw UnimplementedError();
  }

  @override
  Future<String> abonner(String numero, String id_book) {
    // TODO: implement abonner
    throw UnimplementedError();
  }

  @override
  Future<String> comment(String numero, String id_book, String comment) {
    // TODO: implement comment
    throw UnimplementedError();
  }

  @override
  Future<String> dislike(String numero, String id_book) {
    // TODO: implement dislike
    throw UnimplementedError();
  }

  @override
  Future<String> like(String numero, String id_book) {
    // TODO: implement like
    throw UnimplementedError();
  }

  @override
  Future<String> vue(String numero, String id_book) {
    // TODO: implement vue
    throw UnimplementedError();
  }

}