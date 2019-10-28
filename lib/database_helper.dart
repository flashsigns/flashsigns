import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Sign {
  final int id;
  final String description;
  final String url;

  Sign({this.id, this.description, this.url});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'url': url,
    };
  }
}

class DatabaseHelper {
  static final _databaseName = "sign_database.db";
  static final _databaseVersion = 1;

  static final table = 'sign_table';

  static final columnId = '_id';
  static final columnDescription = 'description';
  static final columnUrl = 'url';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, _databaseName);

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnDescription TEXT NOT NULL,
        $columnUrl TEXT NOT NULL
      )
    ''');

    await db.execute('''
      INSERT INTO $table
      ($columnDescription, $columnUrl)
      VALUES
      ("Ne pas pouvoir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/72243C67-AE37-2F8F-7C0478E143AF4CB2.mp4"),
      ("Beau - Belle", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/191F5F9D-A76B-8A74-C2884DD5B56863D7.mp4"),
      ("Soir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AE8D6914-BAC0-7687-6D9E5A2F05673DA7.mp4")
    ''');
  }

  Future<int> insert(Sign sign) async {
    final Database db = await instance.database;
    return await db.insert(
        table,
        sign.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Sign>> queryAllSigns() async {
    final Database db = await instance.database;
    var rows = await db.query(table);
    return List.generate(rows.length, (i) {
      return Sign(
        id: rows[i]['$columnId'],
        description: rows[i]['$columnDescription'],
        url: rows[i]['$columnUrl'],
      );
    });
  }
}