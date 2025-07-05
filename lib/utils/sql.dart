import 'dart:io';

import 'package:accounts_saver/models/account.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:convert';

class Sql {
  Database? _db;

  Future<Database?> get db async {
    _db = _db ?? await _initialData();
    return _db;
  }

  Future<Database> _initialData() async {
    String databasePath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    try {
      final String defualtDatabasePath = await getDatabasesPath();
      databasePath = join(defualtDatabasePath, "data.db");
    } catch (e) {
      databasePath = join("./", "data.db");
    }
    final Database database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _create,
    );
    return database;
  }

  void _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS accounts (
      Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      Title TEXT,
      Email TEXT,
      Password TEXT
      )
      ''');
  }

  Future<List<Map<String, Object?>>> getAccount(
    String sql, {
    List<Object> args = const [],
  }) async {
    final Database? database = await db;
    final List<Map<String, Object?>> data = await database!.rawQuery(sql, args);
    return data;
  }

  Future<int> addAccount(String sql, {List<Object> args = const []}) async {
    final Database? database = await db;
    final int data = await database!.rawInsert(sql, args);
    return data;
  }

  Future<int> updateAccount(String sql, {List<Object> args = const []}) async {
    final Database? database = await db;
    final int data = await database!.rawUpdate(sql, args);
    return data;
  }

  Future<int> deleteAccount(String sql, {List<Object> args = const []}) async {
    final Database? database = await db;
    final int data = await database!.rawDelete(sql, args);
    return data;
  }

  Future<List<Account>> addFromJson(String jsonContent) async {
    try {
      List<dynamic> data = jsonDecode(jsonContent)['accounts'];
      List<Account> accounts = [];

      for (var acc in data) {
        int id = await addAccount(
          '''
          INSERT INTO accounts (Title, Email, Password) VALUES (?, ?, ?)
          ''',
          args: [acc["Title"], acc["Email"], acc["Password"]],
        );

        accounts.add(
          Account(
            id: id,
            title: acc["Title"],
            email: acc["Email"],
            password: acc["Password"],
          ),
        );
      }

      return accounts;
    } catch (e) {
      return Future.error(Exception("File is Currepted"));
    }
  }
}
