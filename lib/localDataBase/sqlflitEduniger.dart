import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../features/livres/models/book_model.dart';
import '../features/livres/models/detaille_book_model.dart';
import '../features/utilisateurs/models/user_model.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eduniger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
        path,
        version: 2,
        onUpgrade: _onUpgrade,
        onCreate: _createDB);
  }
// Ajoutez cette fonction pour gérer les mises à jour futures
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Si la table existe déjà, on la supprime et on la recrée
      await db.execute("DROP TABLE IF EXISTS users");
      await _createDB(db, newVersion);
    }
  }
  Future _createDB(Database db, int version) async {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        firstName TEXT,
        email TEXT,
        profile TEXT,
        profession INTEGER,
        role INTEGER,
        token TEXT,
        loginDate TEXT
      );
    ''');

      await db.execute('''
      CREATE TABLE idNumber (
        id INTEGER PRIMARY KEY,
        idNumber TEXT
      );
    ''');
      // Créer la table livres_telecharges
      await db.execute('''
  CREATE TABLE IF NOT EXISTS livres_telecharges (
    id            TEXT PRIMARY KEY,
    numero        TEXT,
    titre         TEXT NOT NULL,
    auteur        TEXT,
    couverture    TEXT,
    categorie     TEXT,
    est_pysique   INTEGER,
    est_electronique INTEGER,
    est_audio     INTEGER,
    fichier_local TEXT,
    fichier_url   TEXT,
    vues          INTEGER DEFAULT 0,
    likes         INTEGER DEFAULT 0,
    dislikes      INTEGER DEFAULT 0,
    nombre_abonne INTEGER DEFAULT 0,
    nombre_page   INTEGER DEFAULT 0,
    est_abonne    INTEGER DEFAULT 0,
    date_telecharge TEXT
  );
''');

  }
//sauvegarder numero
  Future<void> saveIdNumber(String idNumber) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.delete('idNumber'); // Supprimer l'ancien numéro
      await txn.insert('idNumber', {
        'idNumber': idNumber
      });
    });
  }

  Future<Object?> getIdNumber() async {
    final db = await instance.database;
    final maps = await db.query('idNumber', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['idNumber'];
    }
    return null;
  }
  //recupere le tocken
  // Récupérer le token de l'utilisateur connecté
  Future<String?> gettoken() async {
    final db = await instance.database;
    // On cherche dans la table 'users' et on ne sélectionne que la colonne 'token'
    final maps = await db.query(
        'users',
        columns: ['token'],
        limit: 1
    );

    if (maps.isNotEmpty && maps.first['token'] != null) {
      return maps.first['token'] as String;
    }
    return null;
  }



  // Sauvegarder l'utilisateur
  Future<void> saveUser(UserModel user, String token) async {
    final db = await instance.database;

    // Utilisation d'une transaction pour garantir que le delete et l'insert se font ensemble
    await db.transaction((txn) async {
      // 1. On vide la table proprement
      await txn.delete('users');

      // 2. On insère le nouvel utilisateur
      await txn.insert(
        'users',
        {
          'id': user.idantifiant,
          'name': user.nom,
          'firstName': user.prenom,
          'email': user.mail,
          'profile': user.profession,
          'profession': user.profession,
          'role': user.role,
          'token': token,
          'loginDate': DateTime.now().toIso8601String(),
        },
        // IMPORTANT: Remplace les données si un conflit d'ID existe malgré le delete
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    //print("Utilisateur sauvegardé en local : ${user.name}");
  }

  // Récupérer l'utilisateur stocké
  Future<Map<String, dynamic>?> getUser() async {
    final db = await instance.database;

    // On récupère toutes les lignes de la table users
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  //verification de durrer de session
  Future<bool> isSessionValid() async {
    final userData = await getUser();
    if (userData == null || userData['loginDate'] == null) return false;

    DateTime loginDate = DateTime.parse(userData['loginDate']);
    DateTime now = DateTime.now();

    // Calculer la différence en heures
    int differenceInHours = now.difference(loginDate).inHours;

    return differenceInHours < 72; // Retourne true si moins de 72h
  }
  // deconnecter utilisateur
  Future<void> logout() async {
    final db = await instance.database;
    // Supprime toutes les lignes de la table users
    await db.delete('users');
  }

  //////gestion des livre
// À ajouter dans sqlflitEduniger.dart

// ── Création de la table livres_telecharges ──────────────────────────

// ── Sauvegarder un livre téléchargé ─────────────────────────────────
  Future<void> saveBookTelecharge(DetailleBookModel book, String cheminLocal,String numero) async {
    final db = await database;
    await db.insert(
      'livres_telecharges',
      {
        'id'             : book.id,
        'numero'         : numero,
        'titre'          : book.titre,
        'couverture'     : book.couverture,
        'categorie'      : book.titre_categorie,
        'est_pysique'    : book.est_pysique ? 1 : 0,
        'est_electronique': book.est_electronique,
        'est_audio'      : book.est_audio ? 1 : 0,
        'fichier_local'  : cheminLocal,
        'fichier_url'    : book.fichier,
        'vues'           : book.nombre_vue,
        'likes'          : book.nombre_jaime,
        'dislikes'       : book.nombre_jaime,
        'nombre_abonne'  : book.nombre_subscribe,
        'nombre_page'    :book.nombre_page,
        'est_abonne'     : book.est_abonne? 1 : 0,
        'date_telecharge': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("✅ Livre ${book.titre} sauvegardé localement");
  }

// ── Récupérer tous les livres téléchargés ────────────────────────────
  // ── Récupérer tous les livres téléchargés ────────────────────────────

  Future<List<DetailleBookModel>> getBooksTelecharges(String numero) async {
    final db = await database;

    // Utilisation correcte des paramètres de requête
    final List<Map<String, dynamic>> rows = await db.query(
      'livres_telecharges',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    return rows.map((row) => DetailleBookModel(
      id: row['id'] as String,
      couverture: row['couverture'] as String,
      titre: row['titre'] as String,
      description: row['description'] as String,
      titre_categorie: row['categorie'] as String,
      est_pysique: row['est_pysique'] == 1,
      est_electronique: row['est_electronique'] as String,
      est_audio: row['est_audio'] == 1,
      nombre_jaime: row['likes'] as int,
      nombre_no_jaime: row['dislikes'] as int,
      nombre_subscribe: row['nombre_abonne'] as int,
      nombre_vue: row['vues'] as int,

    )).toList();
  }

// ── Vérifier si un livre est déjà téléchargé ────────────────────────
  Future<bool> isBookTelecharge(String idBook,String numero) async {
    final db  = await database;
    final res = await db.query(
      'livres_telecharges', where: 'id = ? and numero = ?' ,whereArgs: [idBook,numero],);
    return res.isNotEmpty;
  }

// ── Supprimer un livre téléchargé ────────────────────────────────────
  Future<void> deleteBookTelecharge(String idBook, String numero) async {
    final db = await database;
    await db.delete(
      'livres_telecharges where numero = $numero and id = $idBook',
      //where: 'id = ?', whereArgs: [idBook],
    );
    debugPrint("🗑️ Livre $idBook supprimé localement");
  }

}