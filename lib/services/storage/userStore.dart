import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;


class User {
  final String id;
  final String email;
  final String username;
  final String connectionId;
  String profilePic;
  final bool isPrimary;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.connectionId,
    required this.profilePic,
    required this.isPrimary,
  });

  Map<String, dynamic> toMap([toString = false]) {
    return {
      'userId': id,
      'email': email,
      'username': username,
      "connectionId": connectionId,
      "profilePic": profilePic,
      "isPrimary": toString ? isPrimary.toString() : isPrimary,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["userId"],
      email: map["email"],
      username: map["username"],
      connectionId: map["connectionId"],
      profilePic: map["profilePic"],
      isPrimary: map["isPrimary"],
    );
  }
}

class DatabaseServiceUser {
  static const databaseName = "users.db";
  static const databaseVersion = 1;
  static const tableName = "users";

  static const columnUserId = "userId";
  static const columnEmail = "email";
  static const columnUsername = "username";
  static const columnConnectionId = "connectionId";
  static const columnProfilePic = "profilePic";
  static const columnIsPrimary = "isPrimary";

  // Singleton pattern to ensure only one instance of the database
  static final DatabaseServiceUser instance = DatabaseServiceUser._constructor();

  DatabaseServiceUser._constructor();
  static late Database databaseInstance;

  Future<Database> get database async {
    databaseInstance = await initDatabase();
    return databaseInstance;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            $columnUserId TEXT PRIMARY KEY,
            $columnEmail TEXT,
            $columnUsername TEXT,
            $columnConnectionId TEXT,
            $columnProfilePic TEXT,
            $columnIsPrimary BOOLEAN
          )
        ''');
      },
    );
  }

  // Insert a row in the database
  Future<int> insert(User user) async {
    Database db = await database;
    Map<String, dynamic> row = user.toMap(true);
    return await db.insert(tableName, row);
  }

  // Get a single row by ID
  Future<User?> queryById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnUserId = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<List<User>?> queryByX(String param, String value) async {
    Database db = await database;
    List<Map<String, dynamic>> results = [];
    if (param == "email") {
      results = await db
          .query(tableName, where: '$columnEmail = ?', whereArgs: [value]);
    } else if (param == "isPrimary") {
      results = await db
          .query(tableName, where: '$columnIsPrimary = ?', whereArgs: [value]);
    }

    if (results.isNotEmpty) {
      return results.map((e) {
        var element = {...e};
        element['isPrimary'] = e['isPrimary'] == "true"; // Convert to boolean
        return User.fromMap(element);
      }).toList();
    }
    return null;
  }

  // Get all rows from the database
  Future<List<User>> queryAll() async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableName);
    if (results.isEmpty) {
      return [];
    } else {
      return results.map((element) {
        return User.fromMap(element);
      }).toList();
    }
  }

  // Update a row in the database
  Future<int> update(User user) async {
    Database db = await database;
    String id = user.id;
    return await db.update(tableName, user.toMap(),
        where: '$columnUserId = ?', whereArgs: [id]);
  }

  // Delete a row from the database
  Future<int> delete(String id) async {
    Database db = await database;
    return await db
        .delete(tableName, where: '$columnUserId = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    Database db = await database;
    return await db.delete(tableName);
  }

  // Clear all rows in the database
  Future<int> clearAllExecpt(String userId) async {
    Database db = await database;
    return await db
        .delete(tableName, where: '$columnUserId != ?', whereArgs: [userId]);
  }

  Future<int> replace(User user) async {
    return await delete(user.id).then((itemFound) async {
      return await insert(user);
    });
  }

  Future<int> updateValue(String key, dynamic value, String userId) async {
    final untransformedData = await queryById(userId);
    final data = untransformedData?.toMap(true);
    if (data == null) {
      developer.log("Error: User with ID $userId not found in the database.",
          name: 'DatabaseService');
      throw Exception("User not found");
    }

    data[key] = value;
    User user = User.fromMap(data);
    return update(user);
  }

  Future<List<User>> queryAllExcept(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$columnUserId != ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) {
      return [];
    } else {
      return results.map((element) {
        return User.fromMap(element);
      }).toList();
    }
  }
}
