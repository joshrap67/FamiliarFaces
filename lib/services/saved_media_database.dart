import 'package:familiar_faces/contracts_sql/saved_media.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedMediaDatabase {
  static final SavedMediaDatabase instance = SavedMediaDatabase._init();

  static Database? _database;

  SavedMediaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saved_media_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future _createDatabase(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final intType = 'INTEGER NOT NULL';
    final textType = 'TEXT';
    await db.execute('''
		CREATE TABLE $tableSavedMedia(
			${SavedMediaFields.id} $idType,
			${SavedMediaFields.mediaId} $intType,
			${SavedMediaFields.mediaType} $intType,
			${SavedMediaFields.title} $textType,
			${SavedMediaFields.posterPath} $textType,
			${SavedMediaFields.releaseDate} $textType
		)
	''');
  }

  Future<SavedMedia> create(SavedMedia savedMedia) async {
    final db = await instance.database;
    final id = await db.insert(tableSavedMedia, savedMedia.toJson());
    return savedMedia.deepCopy(id: id);
  }

  Future<SavedMedia> get(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableSavedMedia,
      columns: SavedMediaFields.values,
      where: '${SavedMediaFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SavedMedia.fromJson(maps.first);
    } else {
      throw new Exception("Media not found");
    }
  }

  Future<List<SavedMedia>> getAll() async {
    final db = await instance.database;

    final result = await db.query(tableSavedMedia);
    return result.map((rawJson) => SavedMedia.fromJson(rawJson)).toList();
  }

  Future<int> update(SavedMedia savedMedia) async {
    final db = await instance.database;
    return db.update(
      tableSavedMedia,
      savedMedia.toJson(),
      where: '${SavedMediaFields.id} = ?',
      whereArgs: [savedMedia.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableSavedMedia,
      where: '${SavedMediaFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
