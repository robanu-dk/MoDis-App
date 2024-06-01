import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tracking_coordinate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tracking_coordinate(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude TEXT,
        longitude TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('tracking_coordinate', row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db.query('tracking_coordinate');
  }

  Future<List<Map<String, Object?>>> get() async {
    final db = await instance.database;
    return await db.query('tracking_coordinate');
  }

  Future<int> delete() async {
    final db = await instance.database;
    return await db.delete('tracking_coordinate');
  }
}
