import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/modelUser.dart';

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





  // Sauvegarder l'utilisateur
  Future<void> saveUser(User user, String token) async {
    final db = await instance.database;

    // Utilisation d'une transaction pour garantir que le delete et l'insert se font ensemble
    await db.transaction((txn) async {
      // 1. On vide la table proprement
      await txn.delete('users');

      // 2. On insère le nouvel utilisateur
      await txn.insert(
        'users',
        {
          'id': user.id,
          'name': user.name,
          'firstName': user.firstName,
          'email': user.email,
          'profile': user.profile,
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
}