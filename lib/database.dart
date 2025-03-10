import 'message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../logging.dart';
import 'shared_data.dart';
import 'dart:io';
import 'package:kaouka/bot.dart';

const selector = bool.fromEnvironment('SELECTOR');

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static Database? _commonDatabase;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> get commonDatabase async {
    if (_commonDatabase != null) return _commonDatabase!;
    _commonDatabase = await _initCommonDatabase();
    return _commonDatabase!;
  }

  Future<Database> _initDatabase() async {
    SharedData sharedData = SharedData();
    String id = sharedData.getId;
    final dbPath = await getDatabasesPath();
    final oldPath = join(dbPath, 'ctj.db');
    final path = join(dbPath, '${id}_ctj.db');

    bool exists = await databaseExists(oldPath);
    if (exists) {
      await File(oldPath).rename(path);
    }
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<Database> _initCommonDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'common_ctj.db');
    return await openDatabase(path,
        version: 1, onCreate: _createCommanDatabase);
  }

  Future<void> recreateDatabase() async {
    SharedData sharedData = SharedData();
    String id = sharedData.getId;
    final dbPath = await getDatabasesPath();
    final oldPath = join(dbPath, 'ctj.db');
    final path = join(dbPath, '${id}_ctj.db');

    bool existsOld = await databaseExists(oldPath);
    if (existsOld) {
      await deleteDatabase(oldPath);
    }
    bool exists = await databaseExists(path);
    if (exists) {
      await deleteDatabase(path);
    }
    _initDatabase();
    _initCommonDatabase();
  }

  Future<void> _createCommanDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bots(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id1 TEXT,
        id2 TEXT
      )
    ''');
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT,
        timestamp TEXT,
        isSentByUser INTEGER,
        personId TEXT,
        filepath TEXT,
        read INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE mydata(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personid TEXT
      )
    ''');
  }

  Future<void> insertBot(Bot bot) async {
    await checkDb();
    final db = await commonDatabase;
    await db.insert('bots', {
      'id1': bot.id1,
      'id2': bot.id2,
    });
  }

  Future<List<Bot>> getBots() async {
    await checkDb();
    final db = await commonDatabase;
    try {
      final List<Map<String, dynamic>> tmpBots = await db.query('bots');
      return tmpBots.map((map) => Bot.fromMap(map)).toList();
    } catch (e) {
      LoggerManager.logError('DB: get bots error: ', e);
    }
    return [];
  }

  Future<void> checkDb() async {
    final db = await database;
    if (!db.isOpen) {
      _database = await _initDatabase();
    }
    final commondb = await commonDatabase;
    if (!commondb.isOpen) {
      _commonDatabase = await _initCommonDatabase();
    }
  }

  Future<void> insertMessage(String timestamp, String message, String personId,
      bool isSentByUser, String file) async {
    await checkDb();
    final db = await database;
    await db.insert('messages', {
      'content': message,
      'timestamp': timestamp,
      'isSentByUser': isSentByUser ? 1 : 0,
      'personId': personId,
      'read': isSentByUser ? 1 : 0,
      'filepath': file
    });
    final List<Map<String, dynamic>> idExist = await db.query(
      'contacts',
      where: 'personId = ?',
      whereArgs: [personId],
    );
    if (idExist.isEmpty) {
      await db.insert('contacts', {'personId': personId});
    }
  }

  Future<List<CustomMessage>> getMessages(String personId) async {
    await checkDb();
    final db = await database;
    List<CustomMessage> messages = [];
    try {
      final dbmessages = await db.query('messages',
          where: 'personId = ?',
          whereArgs: [personId],
          orderBy: 'timestamp ASC');
      for (var element in dbmessages) {
        bool sentByUser;
        if (element['isSentByUser'] == 0) {
          sentByUser = false;
        } else {
          sentByUser = true;
        }
        bool read;
        if (element["read"] == 0) {
          read = false;
        } else {
          read = true;
        }
        if (element["content"].toString().isEmpty &&
            element["filepath"].toString().isEmpty) {
          deleteMessage(
              element["personId"].toString(), element["timestamp"].toString());
        }
        messages.add(CustomMessage(
            isSentByUser: sentByUser,
            message: element["content"].toString(),
            timestamp: element["timestamp"].toString(),
            personId: element["personId"].toString(),
            filepath: element["filepath"].toString(),
            read: read));
      }
      int compareByTimestamp(CustomMessage a, CustomMessage b) {
        DateTime dateTimeA = DateTime.parse(a.timestamp);
        DateTime dateTimeB = DateTime.parse(b.timestamp);
        return dateTimeA.compareTo(dateTimeB);
      }

      // Sort the items array using the custom comparison function
      messages.sort(compareByTimestamp);
    } catch (e) {
      LoggerManager.logError('DB: get messages error: ', e);
    }
    return messages;
  }

  Future<void> deleteMessageMedia(String personId, String timestamp) async {
    await checkDb(); // Ensure the database is initialized
    final db = await database;

    await db.update(
      'messages',
      {'filepath': ""},
      where:
          'timestamp = ? AND personId = ?', // Find the row with the old timestamp
      whereArgs: [timestamp, personId],
    );
  }

  Future<void> deleteMessage(String personId, String timestamp) async {
    await checkDb(); // Ensure the database is initialized
    final db = await database;

    await db.delete(
      'messages',
      where:
          'timestamp = ? AND personId = ?', // Replace 'timestamp' with your unique identifier column if needed
      whereArgs: [timestamp, personId],
    );
  }

  Future<int> deleteMessages(String personId) async {
    await checkDb(); // Ensure the database is initialized
    final db = await database;

    try {
      // Delete messages where the personId matches the provided value
      final result = await db.delete(
        'messages',
        where: 'personId = ?',
        whereArgs: [personId],
      );
      return result; // Return the number of rows deleted
    } catch (e) {
      LoggerManager.logError('DB: delete messages error: ', e);
      return 0; // Return 0 if there was an error
    }
  }

  getUnreadMessages() async {
    List<Map<String, dynamic>> unreadMessages = [];
    try {
      await checkDb();
      final db = await database;
      unreadMessages = await db.query(
        'messages',
        columns: ['personId'],
        where: 'read = ?',
        whereArgs: [0],
      );
    } catch (e) {
      LoggerManager.logError('DB: get unread messages error: ', e);
    }

    return unreadMessages;
  }

  readMessages(String personId) async {
    try {
      await checkDb();
      final db = await database;
      await db.update(
        'messages',
        {'read': 1},
        where: 'personId = ?',
        whereArgs: [personId],
      );
    } catch (e) {
      LoggerManager.logError('DB: read messages error: ', e);
    }
  }

  Future<List<dynamic>> getPerson(String reqId) async {
    List<dynamic> personsId = [];
    await checkDb();
    final db = await database;
    try {
      final dbmessages = await db.query('messages',
          where: 'reqId = ?', whereArgs: [reqId], orderBy: 'timestamp DESC');
      personsId = dbmessages.map((map) => map['personId']).toSet().toList();
    } catch (e) {
      LoggerManager.logError('DB: get person error: ', e);
    }
    return personsId;
  }

  Future<List<String>> getContact() async {
    await checkDb();
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query('contacts');
      return result.map((dataMap) {
        return dataMap['personId'] as String;
      }).toList();
    } catch (e) {
      LoggerManager.logError('DB: get contacts error: ', e);
    }
    return [];
  }

  Future<int> deleteContact(String personId) async {
    await checkDb(); // Ensure the database is initialized
    final db = await database;

    try {
      // Delete messages where the personId matches the provided value
      final result = await db.delete(
        'contacts',
        where: 'personId = ?',
        whereArgs: [personId],
      );
      return result; // Return the number of rows deleted
    } catch (e) {
      LoggerManager.logError('DB: delete messages error: ', e);
      return 0; // Return 0 if there was an error
    }
  }

  Future<void> insertDbId(String id) async {
    await checkDb();
    final db = await database;
    await db.insert('mydata', {'personid': id});
  }

  Future<String> getDbId() async {
    await checkDb();
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query('mydata');
      if (result.isNotEmpty) {
        return result[0]['personid'] as String;
      }
    } catch (e) {
      LoggerManager.logError('DB: retrieveId error: ', e);
    }
    return '';
  }

  Future<String> updateDbId(String newPersonId) async {
    await checkDb(); // Ensure the database is ready
    final db = await database; // Get the database instance

    try {
      // Query the existing data
      final List<Map<String, dynamic>> result = await db.query('mydata');

      if (result.isNotEmpty) {
        // Extract the ID or condition for the row you want to update
        final String currentPersonId = result[0]['personid'] as String;

        // Prepare the updated data
        Map<String, dynamic> updatedData = {
          'personid': newPersonId, // Update personid field with the new value
        };

        // Perform the update
        int count = await db.update(
          'mydata', // Table name
          updatedData, // New data to update
          where: 'personid = ?', // Condition to update specific row
          whereArgs: [
            currentPersonId
          ], // The argument for the where clause (current id)
        );

        // Return success if rows were affected
        if (count > 0) {
          return 'Update successful';
        } else {
          return 'No rows updated';
        }
      }
    } catch (e) {
      LoggerManager.logError('DB: retrieveId error: ', e);
    }

    return 'Update failed';
  }

  Future<void> purgeApp() async {
    // Delete the database file
    try {
      await checkDb();
      final db = await database;
      if (await databaseExists('ctj.db')) {
        await db.delete('messages');
        await db.delete('contacts');
        await db.delete('mydata');
        await db.close();
        await databaseFactory.deleteDatabase('ctj.db');
      }

      // Clear the cache
      final cacheManager = DefaultCacheManager();
      await cacheManager.emptyCache();
    } catch (e) {
      LoggerManager.logError('DB: delete cache error: ', e);
    }
  }

  getReqInteressedDb() async {
    await checkDb();
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query('mydata');
      if (result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      LoggerManager.logError('DB: retrieveId error: ', e);
    }
    return <Map<String, dynamic>>[];
  }

  insertReqInteressedDb(String id) async {
    await checkDb();
    final db = await database;
    await db.insert('mydata', {'personid': id});
  }

  deleteReqInteressedDb(String id) async {
    await checkDb();
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('mydata');
    if (result.isNotEmpty) {
      return result[0]['personid'] as String;
    }
    await db.delete(
      'mydata',
      where: 'id = ?',
      whereArgs: [id], // Delete record with id = 1
    );
  }
}
