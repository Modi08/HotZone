import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;


class Message {
  final String id;
  final DateTime time;
  final String message;
  final String senderId;

  Message({
    required this.id,
    required this.time,
    required this.message,
    required this.senderId,
  });

  Map<String, dynamic> toMap([toString = false]) {
    return {
      'msgId': id,
      'senderId': senderId,
      'message': message,
      "time": toString ? time.toString() : time,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, [convertString = false]) {
    return Message(
      id: map["msgId"],
      senderId: map["senderId"],
      message: map["message"],
      time: convertString ? DateTime.parse(map["time"]) : map["time"],
    );
  }
}


class DatabaseServiceMsg {
  static const databaseName = "messages.db";
  static const databaseVersion = 1;
  static const tableName = "messages";

  static const columnMsgId = "msgId";
  static const columnTime = "time";
  static const columnMessage = "message";
  static const columnSenderId = "senderId";

  // Singleton pattern to ensure only one instance of the database
  static final DatabaseServiceMsg instance = DatabaseServiceMsg._constructor();

  DatabaseServiceMsg._constructor();
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
            $columnMsgId TEXT PRIMARY KEY,
            $columnMessage TEXT,
            $columnSenderId TEXT,
            $columnTime TEXT
          )
        ''');
      },
    );
  }

  // Insert a row in the database
  Future<int> insert(Message msg) async {
    Database db = await database;
    Map<String, dynamic> row = msg.toMap(true);
    return await db.insert(tableName, row);
  }

  // Get a single row by ID
  Future<Message?> queryById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnMsgId = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return Message.fromMap(results.first);
    }
    return null;
  }

  Future<List<Message>?> queryByX(String param, String value) async {
    Database db = await database;
    List<Map<String, dynamic>> results = [];
    if (param == "Message") {
      results = await db
          .query(tableName, where: '$columnMessage = ?', whereArgs: [value]);
    } else if (param == "senderId") {
      results = await db
          .query(tableName, where: '$columnSenderId = ?', whereArgs: [value]);
    }

    if (results.isNotEmpty) {
      return results.map((e) {
        var element = {...e};
        element['isPrimary'] = e['isPrimary'] == "true"; // Convert to boolean
        return Message.fromMap(element);
      }).toList();
    }
    return null;
  }

  // Get all rows from the database
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await database;
    return await db.query(tableName);
  }

  // Update a row in the database
  Future<int> update(Message msg) async {
    Database db = await database;
    String id = msg.id;
    return await db.update(tableName, msg.toMap(),
        where: '$columnMsgId = ?', whereArgs: [id]);
  }

  // Delete a row from the database
  Future<int> delete(String id) async {
    Database db = await database;
    return await db
        .delete(tableName, where: '$columnMsgId = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    Database db = await database;
    return await db.delete(tableName);
  }

  // Clear all rows in the database
  Future<int> clearAllExecpt(String msgId) async {
    Database db = await database;
    return await db
        .delete(tableName, where: '$columnMsgId != ?', whereArgs: [msgId]);
  }

  Future<int> replace(Message msg) async {
    return await delete(msg.id).then((itemFound) async {
      return await insert(msg);
    });
  }

  Future<int> updateValue(String key, dynamic value, String msgId) async {
      final untransformedData = await queryById(msgId);
    final data = untransformedData?.toMap(true);
    if (data == null) {
      developer.log("Error: message with ID $msgId not found in the database.",
          name: 'DatabaseService');
      throw Exception("message not found");
    }

    data[key] = value;
    Message msg = Message.fromMap(data);
    return update(msg);
  }

  Future<List<Message>> queryAllExcept(String msgId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$columnMsgId != ?',
      whereArgs: [msgId],
    );
    if (results.isEmpty) {
      return [];
    } else {
      return results.map((element) {
        return Message.fromMap(element);
      }).toList();
    }
  }
}
