import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final databaseName = "TShirtEditor.db";
  static final databaseVersion = 1;

  static final table = 'favourite_shirt';

  static final tId = 'tId';
  static final shirtId = 'shirtId';
  static final shirtImage = 'shirtImage';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(path,
        version: databaseVersion, onCreate: _onCreate);
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $tId INTEGER PRIMARY KEY,
            $shirtId TEXT NOT NULL,
            $shirtImage TEXT NOT NULL
          )
          ''');
  }

  Future<int> addToFavourite(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }
  Future<bool> isAlreadyFavourite(String id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
        table,
        where: '$shirtId = ?',
        whereArgs: [id]
    );
    return result.isNotEmpty;
  }


  Future<int> removeFavourite(String id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$shirtId = ?',
      whereArgs: [id],
    );
  }

}
