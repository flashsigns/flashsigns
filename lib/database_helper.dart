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
      ("Soir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AE8D6914-BAC0-7687-6D9E5A2F05673DA7.mp4"),
      ("Faire quoi", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/051F4E73-D5C6-78B0-E22CBF1682FC68C0.mp4"),
      ("Quoi?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/36A66D84-9370-F58F-012FA8CF0514DF2A.mp4"),
      ("Qui?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/A36A7826-AF07-97C6-7310326901FCA121.mp4"),
      ("Quand?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AE9AFB48-B70E-183F-5F4E4FAE49ECFE64.mp4"),
      ("Pourquoi?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F99F2A1B-9966-9111-EA692464BF4BBCA2.mp4"),
      ("Comment?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F9ABE919-F247-4948-888417F1D72B1FB0.mp4"),
      ("Où?", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F8CFCFAF-B684-99CD-F886AE4C53F03867.mp4"),
      ("Temps (durée, moment)", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/9E3677DC-9F95-7FA2-D2E4576F14E9FC15.mp4"),
      ("Hier", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D96060DD-EE41-49C6-41CCDCCB8754FA7B.mp4"),
      ("Avant-hier", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/0AFEF9D8-5056-0100-46A104AAD05D9181.mp4"),
      ("Aujourd'hui", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/04C5EA0C-B529-E7D8-C038B75B17E01133.mp4"),
      ("Demain", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/B99437DF-A383-CCC2-5DFF58E1F09A4472.mp4"),
      ("Après-demain", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/B2D1663C-A1DA-CF8F-5AD87CE3C6D5B2F1.mp4"),
      ("Maintenant", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D99B2C8A-AF51-873A-9E03B372C6996D0F.mp4"),
      ("Minute", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D9508B7B-ECB8-EFAE-784CC11AF3E2E4C5.mp4"),
      ("Matin", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D9585D37-EE00-B997-0BB8E4E6EA70630A.mp4"),
      ("Midi", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D96722DA-CFD5-2DA1-A329A20D8FD86991.mp4"),
      ("Minuit", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D96D017B-E038-3F9D-B705EBB735BC641C.mp4"),
      ("Après-midi", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/A4D87B9B-9737-8EFC-95CF06657BCCA23C.mp4"),
      ("Bientôt", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/18A6BA55-AC61-0210-72E43E79EC5F9E5B.mp4"),
      ("Ce matin", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F38F1699-C946-D054-3FC6FBB8480B3890.mp4"),
      ("Ce soir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F3D2CF32-95F8-E38B-B24AC1CA20C0A361.mp4")
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