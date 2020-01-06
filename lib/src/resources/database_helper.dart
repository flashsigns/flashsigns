import 'dart:io';

import 'package:flashsigns/src/models/sign.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "sign_database.db";
  static final _databaseVersion = 3;

  static final table = 'sign_table';

  static final columnId = '_id';
  static final columnDescription = 'description';
  static final columnUrl = 'url';
  static final columnCorrect = 'correct';
  static final columnIncorrect = 'incorrect';
  static final columnScore = 'score';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static File _databaseFile;
  Future<File> get databaseFile async {
    if (_databaseFile != null) return _databaseFile;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocDir.list().map((FileSystemEntity event) => print(event.path));
    return File(join(appDocDir.path, _databaseName));
  }

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  void closeDatabase() {
    _database?.close();
    _database = null;
  }

  _initDatabase() async {
    String databasePath = (await databaseFile).path;

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDescription TEXT NOT NULL,
        $columnUrl TEXT NOT NULL,
        $columnCorrect INTEGER DEFAULT 0,
        $columnIncorrect INTEGER DEFAULT 0,
        $columnScore INTEGER DEFAULT 0
      )
    ''');

    // Insert the first one manually to start the ID column at 0
    await db.execute('''
      INSERT INTO $table
      ($columnId, $columnDescription, $columnUrl)
      VALUES
      (0, "Ne pas pouvoir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/72243C67-AE37-2F8F-7C0478E143AF4CB2.mp4")
      ''');

    await insertBatch1(db);
    await insertBatch2(db);
    await insertBatch3(db);
  }

  Future insertBatch1(Database db) async {
    await db.execute('''
      INSERT INTO $table
      ($columnDescription, $columnUrl)
      VALUES
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
      ("Ce soir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F3D2CF32-95F8-E38B-B24AC1CA20C0A361.mp4"),
      ("Ce n'est pas grave", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/2B4ECEEE-C005-1A68-5E06B072D020CC39.mp4"),
      ("C'est la vie", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/261E2F46-A8C7-0286-7C658CD037B54647.mp4"),
      ("Pas d'accord", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D5E96F2D-B48C-3429-CDEF254301E4C1B0.mp4"),
      ("Pas compris", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/701F45B1-A8D1-F1F0-601453BF79111765.mp4"),
      ("Pas fini", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/43C902A8-5056-0100-46BC20AAD4E8D7B5.mp4"),
      ("Avoir de la chance", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D8B2D6BD-D6CC-6F54-9F2873033B7B3B29.mp4"),
      ("Dommage", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/9E212184-C588-B1E0-7D5E82D43A984609.mp4"),
      ("Discuter", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/9FDC7F9D-D8EB-F3CA-39F26D1EFE99BFE5.mp4"),
      ("S'exprimer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/11A0580C-0806-B95F-EC90E32AE15C4672.mp4"),
      ("Dire", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/83E97DF5-DE51-1DC6-3EE83D58FEA25F72.mp4"),
      ("Communiquer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AC3C5F9D-F083-A2C8-0AF9F56EFEBBA31C.mp4"),
      ("Expliquer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CDB7E4BE-BE4C-EE2A-C38C69F07027EFCC.mp4"),
      ("Raconter", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C87463C0-E2C8-156D-42676D6903AFDCEA.mp4"),
      ("Facile", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C854C096-0C1D-0E67-D6A9BFA7B4F2640C.mp4"),
      ("Difficile", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/8796BBEA-BC42-337F-85932EFEC278A655.mp4"),
      ("Compliqué", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/46906502-5056-0100-461238B5BBB07452.mp4"),
      ("Triste", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D59D2B40-A9C4-F056-1B3F1898F68379D0.mp4"),
      ("Apprendre", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/0618A720-07C4-5F76-EB56289212D916AC.mp4"),
      ("Fatigué", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/83CDFC6C-D746-8AD1-8804C73B2DD55344.mp4"),
      ("Signer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CA49FC2D-BF8D-24E6-BD078B0886A7BBD0.mp4"),
      ("Boire", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C598A46C-AA9F-68C6-EC1FC7CF45488B25.mp4"),
      ("Manger", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BE3B0FF2-BA9B-3159-57ED78193BC155D0.mp4")
    ''');
  }

  Future insertBatch2(Database db) async {
    await db.execute('''
      INSERT INTO $table
      ($columnDescription, $columnUrl)
      VALUES
      ("Famille", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/867C8B2E-056C-F719-AD82B498B34647BA.mp4"),
      ("Frère", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/86D5E78D-B318-6E84-8F753A1631B4CCB9.mp4"),
      ("Soeur", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/A81F47B0-B0DA-D926-0851506152D9205B.mp4"),
      ("Jumeau  - Jumelle", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D39AF790-0421-E6C9-AD4ED38681451DB5.mp4"),
      ("Tante", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/7D698B23-E490-50DC-862004463DEAAF08.mp4"),
      ("Oncle", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D4EBEBD6-E7E3-C52D-3672688D7C4B4EF3.mp4"),
      ("Cousin", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/05ADE721-EC30-62A3-A1B4F4B144DBBB03.mp4"),
      ("Papa", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D4F2FC24-C592-CD57-6D78FC5B6AF93AF1.mp4"),
      ("Maman", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CFEE618D-DCF1-0B31-03B280C4B7D2342E.mp4"),
      ("Grand-Papa", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BF7E29FA-97E6-DE61-B77369CAF2F55AF0.mp4"),
      ("Grand-Maman", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BF76F085-BAE8-9607-CF14FB4B46AA5BE1.mp4"),
      ("Les Cinq Sens - Sensoriel", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/641C504F-9312-D78C-4B11A61AB64B32CB.mp4"),
      ("Toucher", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/ADBC25D7-9DB4-90D6-E5CB0F704DD55B4A.mp4"),
      ("Écouter", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/user_upload/207326.mp4"),
      ("Voir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D882101C-9B98-48C7-35EFAF970E3C0F4B.mp4"),
      ("Regarder", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/098609F2-A5A9-C9CD-A16B5C45B438DB79.mp4"),
      ("Sentir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D47F9D73-E675-B143-AFD977F9A0B67143.mp4"),
      ("Goûter", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/E10CD623-C1D1-520E-6FF4D53318C099FE.mp4"),
      ("Aimer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/052BAB7B-B8CB-A7E5-201F80592D6E93E7.mp4"),
      ("Ne Pas Aimer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/E1FB3DBB-9364-6216-714169216A22AE24.mp4"),
      ("Bras", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/041AD9CE-B814-B78E-917CEDBB92B2A8BC.mp4"),
      ("Jambe", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/03BF6B67-A731-9DEC-EF073D9874DAA0AD.mp4"),
      ("Ventre", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BDD36A4D-0715-4141-011861BA12CAB9C1.mp4"),
      ("Tête", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/00290F91-E374-7AF3-5882F0B3583D9B13.mp4"),
      ("Épaule", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/25227C88-95B3-3ABF-A7A6B1C5FAA07C68.mp4"),
      ("Genou", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/23EB8C10-EF3C-5F40-451A3CB04440C6EA.mp4"),
      ("Pied", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D41194D7-FFE6-96B8-0C92B70F62E2498F.mp4"),
      ("Dos", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C96AB193-9759-3344-6E51D781CA78B82F.mp4"),
      ("Cou", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C9647B62-950C-027F-9D9924DA6FDF7E36.mp4"),
      ("Visage", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/DFA711AD-DC68-4787-E30E18DDA8907F6A.mp4"),
      ("Nez", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C2EAF417-B530-59FB-5B00FAE0C7673353.mp4"),
      ("Yeux", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CA7B4647-E07A-BAA5-450294A645B2A8F7.mp4"),
      ("Bouche", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/67374E77-C6BC-718E-2F76243F5FD5A75B.mp4"),
      ("Oreille", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/5F8541DC-C886-10E6-1CF0DE72D3DEE8C2.mp4"),
      ("Métier", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D825AFD6-B525-0976-2FED4A530DCC086F.mp4"),
      ("Travail - Emploi", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AFCE967B-A355-37BE-63A19416C6262D18.mp4"),
      ("Travailler", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/ABD0DA76-AAB3-3D75-63D163B4042919F7.mp4"),
      ("Salaire", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D4647A43-AED9-93C4-2A1C41E51020D177.mp4"),
      ("Fatigué", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/83CDFC6C-D746-8AD1-8804C73B2DD55344.mp4"),
      ("Voyager", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CFFDD423-D61A-446D-3E58CCEFEDD09E9D.mp4"),
      ("Vacances", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/B03F7452-D418-162C-35806A81E5F53DC8.mp4"),
      ("Mer", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/9C0FD5C5-B835-00D7-99F6012DE8C34617.mp4"),
      ("Montagne", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/CD0FF821-D1D3-3B65-575EE589437ECA17.mp4"),
      ("Train", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/ABCA8BE2-AB65-5118-A8F185E8D4DF6047.mp4"),
      ("Avion", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/198A9F0F-97D9-702F-B7B1B152EDBC4FA5.mp4"),
      ("Bateau", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/04215C0D-EE03-E924-EBCC2160B798F426.mp4"),
      ("Autobus - Trolleybus - Bus", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/71AF745A-F1FF-6BCF-A821107C4CD67927.mp4"),
      ("Automobile - Voiture", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/FBA2A58B-C7CE-D875-5404B10E423DDEE6.mp4"),
      ("Conduire", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/E5F9BE42-CB3E-BD70-CBFB7A6931B75607.mp4"),
      ("Week-End", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AE933F4C-F269-FDBE-2142FBF4EE149B7F.mp4")
    ''');
  }

  Future insertBatch3(Database db) async {
    await db.execute('''
      INSERT INTO $table
      ($columnDescription, $columnUrl)
      VALUES
      ("D'Accord - Accord", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/B2DB77E8-E15C-A46C-DAA25F01D8496C43.mp4"),
      ("Compris", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/05398763-A86D-8910-853A9B60F220CC87.mp4"),
      ("Différent", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/83F9C688-C637-24AA-B861C834F577A3B4.mp4"),
      ("Prénom", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BD9CDDA5-CB18-C472-5525C5ED930706EA.mp4"),
      ("Nom", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/6FE3F814-FC4F-6589-FF320D4E0C3DF8D1.mp4"),
      ("Vert", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F856C99A-CE36-A0A4-EC8C02067E3AC7D9.mp4"),
      ("Bleu", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/18C5B3EA-A0E0-C3D6-02E0A92D89B9EFF1.mp4"),
      ("Jaune", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F851C0E2-D514-50A2-2688CE0648CEA81D.mp4"),
      ("Rouge", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/BDAC1BBF-F11B-D17E-666B6521E4104FB0.mp4"),
      ("Noir", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/A8972D1C-EBD0-D742-8119E51275232EEF.mp4"),
      ("Blanc - Blanche", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/18C245CC-9673-FB9E-E616F00FAA79F753.mp4"),
      ("Autre", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C45EF788-E135-31D9-CA75E88B4BB6CA8D.mp4"),
      ("Après", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/18958155-0E76-7BCF-8B37381E65347A8A.mp4"),
      ("Avant", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/8BE83E5E-B06D-90D6-C3690CFB3B21D40D.mp4"),
      ("Cent", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/765A0DC2-9926-65E6-0D5BDE1FAD37CC56.mp4"),
      ("Mille", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/D8C8D7DC-E2DA-5823-983E0BA5FE8F8A32.mp4"),
      ("Million", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/503AC82D-AECD-EC28-FBD21864C0268EEC.mp4"),
      ("Milliard", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/C8197EDF-DFAC-29B8-350C5D8D43392FF8.mp4"),
      ("Ensuite", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/6AD94B83-B125-00F3-D562EBEA206835B2.mp4"),
      ("Soif", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/AB14F7F7-C357-ACAF-C830D13865453F7A.mp4"),
      ("Faim", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/52704C3F-00AB-3957-7BC6E91A81C5F0B0.mp4"),
      ("Combien", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/F9B1A65C-01A6-0291-AD31491616E47A80.mp4"),
      ("Avoir Besoin", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/E0290FC2-C147-DC0C-0E86A3477A3EB2C8.mp4"),
      ("Ne Pas Avoir Besoin", "https://signsuisse.sgb-fss.ch/fileadmin/signsuisse_ressources/videos/E219F791-C351-3055-D6F08EDAA5BBD4D6.mp4")
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion <= 1) {
      insertBatch2(db);
    }

    if (oldVersion <= 2) {
      insertBatch3(db);
    }
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
        nCorrect: rows[i]['$columnCorrect'],
        nIncorrect: rows[i]['$columnIncorrect'],
        score: rows[i]['$columnScore'],
      );
    });
  }

  Future<int> updateCorrect(int signId) async {
    final Database db = await instance.database;
    return await db.rawUpdate(
        'UPDATE $table '
        'SET $columnCorrect = $columnCorrect + 1 '
        'WHERE $columnId = ?', [signId]);
  }

  Future<int> updateIncorrect(int signId) async {
    final Database db = await instance.database;
    return await db.rawUpdate(
        'UPDATE $table '
        'SET $columnIncorrect = $columnIncorrect + 1 '
        'WHERE $columnId = ?', [signId]);
  }

  Future<int> updateScore(int signId, int score) async {
    final Database db = await instance.database;
    return await db.rawUpdate(
      'UPDATE $table '
      'SET $columnScore = ? '
      'WHERE $columnId = ?', [score, signId]);
  }
}
