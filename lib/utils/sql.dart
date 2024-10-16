import 'package:accounts_saver/models/account.dart';
import 'package:sqflite/sqflite.dart';
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
      CREATE TABLE accounts (
      Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      Title TEXT,
      Email TEXT,
      Password TEXT
      )
      ''');
  }

  Future<List<Map<String, Object?>>> getAccount(String sql) async {
    final Database? database = await db;
    final List<Map<String, Object?>> data = await database!.rawQuery(sql);
    return data;
  }

  Future<int> addAccount(String sql) async {
    final Database? database = await db;
    final int data = await database!.rawInsert(sql);
    return data;
  }

  Future<int> updateAccount(String sql) async {
    final Database? database = await db;
    final int data = await database!.rawUpdate(sql);
    return data;
  }

  Future<int> deleteAccount(String sql) async {
    final Database? database = await db;
    final int data = await database!.rawDelete(sql);
    return data;
  }

  Future<List<Account>> addFromJson(String jsonContent) async {
    List<dynamic> data = jsonDecode(jsonContent);
    List<Account> accounts = [];

    for (var data in data) {
      int ID = await addAccount('''
        INSERT INTO accounts ("Title", "Email", "Password") VALUES ("${data["Title"]}", "${data["Email"]}", "${data["Password"]}")
        ''');

      accounts.add(Account(
          id: ID,
          title: data["Title"],
          email: data["Email"],
          password: data["Password"]));
    }

    return accounts;
  }
}
