import 'dart:io';

import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class SavedMediaDatabase {
  static final SavedMediaDatabase instance = SavedMediaDatabase._init();

  static Database? _database;

  final String dbName = 'saved_media_database.db';

  SavedMediaDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> restoreDB(String backupFilePath) async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, dbName);

    await deleteDatabase(dbPath);

    var importFile = File(backupFilePath);
    await importFile.copy(dbPath);

    _database = await openDatabase(dbPath);
  }

  Future<void> exportDatabase({required BuildContext context}) async {
    File? backupFile;
    try {
      var db = await database;
      var dbPath = db.path;

      var appDocDir = await getExternalStorageDirectory();
      var timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      var backupPath = join(appDocDir!.path, 'familiar_faces_backup_${timestamp}.db');

      await db.close();

      var dbFile = File(dbPath);
      backupFile = await dbFile.copy(backupPath);

      _database = await openDatabase(dbPath);

      var result = await SharePlus.instance.share(
        ShareParams(files: [XFile(backupPath)], text: 'Familiar Faces Database Export'),
      );
      if (result.status == ShareResultStatus.success) {
        showSnackbar('Database export success!', context);
      }
    } catch (e) {
      showSnackbar('Database export failed', context);
    } finally {
      // clean up temporary backup file
      if (backupFile != null && await backupFile.exists()) {
        await backupFile.delete();
      }
    }
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
    savedMedia.id = id;
    return savedMedia;
  }

  Future<SavedMedia> get(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableSavedMedia,
      columns: SavedMediaFields.columnNames,
      where: '${SavedMediaFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SavedMedia.fromJson(maps.first);
    } else {
      throw new Exception('Media not found');
    }
  }

  Future<SavedMedia?> getByMediaId(int mediaId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableSavedMedia,
      columns: SavedMediaFields.columnNames,
      where: '${SavedMediaFields.mediaId} = ?',
      whereArgs: [mediaId],
    );
    if (maps.isNotEmpty) {
      return SavedMedia.fromJson(maps.first);
    } else {
      return null;
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

    return db.delete(tableSavedMedia, where: '${SavedMediaFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
