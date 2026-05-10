import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../features/livres/models/book_model.dart';
import '../features/livres/models/detaille_book_model.dart';
import '../features/notification/model/notification_model.dart';
import '../features/utilisateurs/models/user_model.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;


  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  Future<Database> get database async {
    // Si la base n'est pas initialisée OU si elle a été fermée
    if (_database == null || !_database!.isOpen) {
      _database = await _initDB('eduniger.db');
    }
    return _database!;
  }
  /*Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eduniger.db');
    return _database!;
  }*/

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    Database? _db;


    return await openDatabase(
        path,
        version: 3,
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
  //Future<Database> get db async => _db ??= await _createDB();

  Future _createDB(Database db, int version) async {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
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
      CREATE TABLE IF NOT EXISTS idNumber (
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
    couverture_url    TEXT,
    couverture_local  TEXT,
    categorie     TEXT,
    est_pysique   INTEGER,
    est_electronique INTEGER,
    est_audio     INTEGER,
    fichier_local TEXT,
    fichier_url   TEXT,
    is_dowlonded_pdf INTEGER DEFAULT 0,
    is_dowlonded_audio INTEGER DEFAULT 0,
    date_telecharge TEXT
  );
''');
      // table de reservation
      await db.execute('''
  CREATE TABLE IF NOT EXISTS reservations (
    id_book          TEXT,
    numero           TEXT,
    date_reservation TEXT,
    dure_de_reservation TEXT,
    statut           TEXT DEFAULT 'en_attente',
    PRIMARY KEY (id_book, numero)
  )
''');
      await db.execute('''
          CREATE TABLE notifications (
            db_id         INTEGER PRIMARY KEY AUTOINCREMENT,
            id            TEXT    NOT NULL,
            numero_user   TEXT    NOT NULL,
            titre         TEXT    NOT NULL DEFAULT '',
            corps         TEXT    NOT NULL DEFAULT '',
            type          TEXT    NOT NULL DEFAULT '',
            extra_data    TEXT    NOT NULL DEFAULT '',
            data_json     TEXT    NOT NULL DEFAULT '{}',
            date_creation TEXT    NOT NULL,
            est_lue       INTEGER NOT NULL DEFAULT 0,
            UNIQUE(id, numero_user)
          )
        ''');
      await db.execute(
        'CREATE INDEX idx_user ON notifications(numero_user, date_creation DESC)',
      );

  }
  //notification
  Future<void> inserer(NotificationModel n) async {
    final base = await database;
    await base.insert(
      'notifications',
      n.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // Garder max 100 par utilisateur
    await base.execute('''
      DELETE FROM notifications
      WHERE numero_user = ?
        AND db_id NOT IN (
          SELECT db_id FROM notifications
          WHERE numero_user = ?
          ORDER BY date_creation DESC LIMIT 100
        )
    ''', [n.numeroUser, n.numeroUser]);
  }

  // ── Lire ─────────────────────────────────────────────────────────────
  Future<List<NotificationModel>> charger(String numeroUser) async {
    final maps = await (await database).query(
      'notifications',
      where    : 'numero_user = ?',
      whereArgs: [numeroUser],
      orderBy  : 'date_creation DESC',
    );
    return maps.map(NotificationModel.fromMap).toList();
  }

  Future<int> compterNonLues(String numeroUser) async {
    final r = await (await database).rawQuery(
      'SELECT COUNT(*) AS c FROM notifications WHERE numero_user=? AND est_lue=0',
      [numeroUser],
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  // ── Mettre à jour ────────────────────────────────────────────────────
  Future<void> marquerLue(String id, String numeroUser) async =>
      (await database).update('notifications', {'est_lue': 1},
          where: 'id=? AND numero_user=?', whereArgs: [id, numeroUser]);

  Future<void> toutMarquerLues(String numeroUser) async =>
      (await database).update('notifications', {'est_lue': 1},
          where: 'numero_user=?', whereArgs: [numeroUser]);

  // ── Supprimer ────────────────────────────────────────────────────────
  Future<void> supprimer(String id, String numeroUser) async =>
      (await database).delete('notifications',
          where: 'id=? AND numero_user=?', whereArgs: [id, numeroUser]);

  Future<void> toutEffacer(String numeroUser) async =>
      (await database).delete('notifications',
          where: 'numero_user=?', whereArgs: [numeroUser]);

  //_____________
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


// ── Sauvegarder un livre téléchargé ─────────────────────────────────
  Future<void> saveBookTelecharge(DetailleBookModel book, String cheminLocal,String numero,String chementCouverture,bool type_pdf,bool type_audio) async {
    final db = await database;
    await db.insert(
      'livres_telecharges',
      {
        'id'             : book.id,
        'numero'         : numero,
        'titre'          : book.titre,
        'couverture_url'     : book.couverture,
        'couverture_local': chementCouverture,
        'categorie'      : book.titre_categorie,
        'est_pysique'    : book.est_pysique ? 1 : 0,
        'est_electronique': book.est_electronique ,
        'est_audio'      : book.est_audio ? 1 : 0,
        'fichier_local'  : cheminLocal,
        'fichier_url'    : book.fichier,
        'is_dowlonded_pdf' : type_pdf ? 1 : 0,
        'is_dowlonded_audio' : type_audio ? 1 : 0,
        'date_telecharge': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("✅ Livre ${book.titre} sauvegardé localement");
  }


 Future<bool> isBookTelecharge_pdf(String idBook,String numero,) async {
    final db  = await database;
    final res = await db.query(
      'livres_telecharges', where: 'id = ? and numero = ? and is_dowlonded_pdf = 1' ,whereArgs: [idBook,numero],);
    return res.isNotEmpty;
  }
  Future<bool> isBookTelecharge_audio(String idBook,String numero,) async {
    final db  = await database;
    final res = await db.query(
      'livres_telecharges', where: 'id = ? and numero = ? and is_dowlonded_audio = 1' ,whereArgs: [idBook,numero,],);
    return res.isNotEmpty;
  }

  //_______________________________________________________________
// ── Correction de deleteBookTelecharge (bug SQL) ──────────────────────
  Future<void> deleteBookTelecharge(String idBook, String numero) async {
    final db = await database;
    await db.delete(
      'livres_telecharges',
      where: 'id = ? AND numero = ?',
      whereArgs: [idBook, numero],   // ← correction : whereArgs séparé
    );
    debugPrint("🗑️ Livre $idBook supprimé localement");
  }

// ── Correction de getBooksTelecharges (champs manquants) ─────────────
  Future<List<DetailleBookModel>> getBooksTelecharges(String numero) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'livres_telecharges',
      where: 'numero = ?',
      whereArgs: [numero],
    );
    return rows.map((row) => DetailleBookModel(
      id              : row['id']?.toString()               ?? '',
      couverture      : row['couverture_local']?.toString()       ?? '',
      titre           : row['titre']?.toString()            ?? '',
      description     : '',
      titre_categorie : row['categorie']?.toString()        ?? '',
      est_pysique     : (row['est_pysique'] as int? ?? 0) == 1,
      est_electronique: row['est_electronique']?.toString() ?? '',
      est_audio       : (row['est_audio'] as int? ?? 0) == 1,
      nombre_jaime    : 0,
      nombre_no_jaime : 0,
      nombre_subscribe: 0,
      nombre_vue      : 0,
      // ← chemin local pour la lecture hors-ligne
      fichier         : row['fichier_local']?.toString()    ?? '',
      is_dowlonded_pdf: (row['is_dowlonded_pdf'] as int? ?? 0) == 1,
      is_dowlonded_audio: (row['is_dowlonded_audio'] as int? ?? 0) == 1,

    )).toList();
  }

// ── Réservation livre physique ────────────────────────────────────────
  Future<void> saveReservation(String idBook, String numero, String duree) async {
    final db = await database;
    // Table réservations à ajouter dans _createDB
    await db.insert(
      'reservations',
      {
        'id_book'        : idBook,
        'numero'         : numero,
        'date_reservation': DateTime.now().toIso8601String(),
        'dure_de_reservation': duree,
        'statut'         : 'en_attente',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isReserve(String idBook, String numero) async {
    final db  = await database;
    final res = await db.query(
      'reservations',
      where: 'id_book = ? AND numero = ?',
      whereArgs: [idBook, numero],
    );
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getReservations(String numero) async {
    final db = await database;
    return db.query(
      'reservations',
      where: 'numero = ?',
      whereArgs: [numero],
    );
  }

}