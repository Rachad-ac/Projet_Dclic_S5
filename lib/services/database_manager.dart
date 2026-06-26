import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/redacteur.dart';

class DatabaseManager {
  Database? _database;

  // Getter pour récupérer ou initialiser la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDB();
    return _database!;
  }

  // Initialisation de la base de donnees et creation de la table redacteurs
  Future<void> initDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'redacteur.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE redacteurs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT,
          prenom TEXT,
          email TEXT
          )
          ''');
      },
      version: 1,
    );
  }

  // Insertion d'un redacteur en base
  Future<void> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    await db.insert(
      'redacteurs', 
      redacteur.toMap());
  }

  // Mise a jour d'un redacteur
  Future<void> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  // Suppresion d'un redacteur
  Future<void> deleteRedacteur(int id) async {
    final db = await database;
    await db.delete('redacteurs', 
    where: 'id = ?', 
    whereArgs: [id]);
  }

  // Recuperation de tous les redacteurs dans la base
  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'redacteurs',
    );
    return List.generate(maps.length, (i) {
      return Redacteur(
        id: maps[i]['id'],
        nom: maps[i]['nom'],
        prenom: maps[i]['prenom'],
        email: maps[i]['email'],
      );
    });
  }
}
