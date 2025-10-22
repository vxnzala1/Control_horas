import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/punch_record.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.status,
    required this.monthlyHours,
  });

  final int id;
  final String username;
  final String displayName;
  final String role;
  final String status;
  final int monthlyHours;

  bool get canManageFichajes => role == 'admin' || role == 'manager';
  bool get canExport => role != 'empleado';
  bool get canGenerateReports => role == 'admin' || role == 'manager';

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      username: map['username'] as String,
      displayName: map['display_name'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
      monthlyHours: (map['monthly_hours'] as int?) ?? 0,
    );
  }
}

class LoginEntry {
  const LoginEntry({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.loggedAt,
  });

  final int id;
  final String username;
  final String displayName;
  final String role;
  final DateTime loggedAt;

  factory LoginEntry.fromMap(Map<String, Object?> map) {
    return LoginEntry(
      id: map['id'] as int,
      username: map['username'] as String,
      displayName: map['display_name'] as String,
      role: map['role'] as String,
      loggedAt: DateTime.parse(map['logged_at'] as String),
    );
  }
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    sqfliteFfiInit();
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'control_horas.db');

    _database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE users ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'username TEXT UNIQUE, '
            'password TEXT, '
            'display_name TEXT, '
            'role TEXT, '
            'status TEXT, '
            'monthly_hours INTEGER'
            ')',
          );
          await db.execute(
            'CREATE TABLE logins ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'user_id INTEGER, '
            'username TEXT, '
            'display_name TEXT, '
            'role TEXT, '
            'logged_at TEXT'
            ')',
          );
          await db.execute(
            'CREATE TABLE punches ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'user_id INTEGER, '
            'user_name TEXT, '
            'entry_time TEXT, '
            'exit_time TEXT, '
            'status TEXT'
            ')',
          );
          await _seedUsers(db);
          await _seedPunches(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'CREATE TABLE punches ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'user_id INTEGER, '
              'user_name TEXT, '
              'entry_time TEXT, '
              'exit_time TEXT, '
              'status TEXT'
              ')',
            );
            await _seedPunches(db);
          }
        },
      ),
    );

    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<void> _seedUsers(Database db) async {
    final batch = db.batch();
    batch.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'display_name': 'Laura Gómez',
      'role': 'admin',
      'status': 'Activo',
      'monthly_hours': 168,
    });
    batch.insert('users', {
      'username': 'manager',
      'password': 'manager123',
      'display_name': 'Carlos Pérez',
      'role': 'manager',
      'status': 'En pausa',
      'monthly_hours': 152,
    });
    batch.insert('users', {
      'username': 'empleado',
      'password': 'empleado123',
      'display_name': 'María López',
      'role': 'empleado',
      'status': 'Activo',
      'monthly_hours': 140,
    });
    batch.insert('users', {
      'username': 'soporte',
      'password': 'soporte123',
      'display_name': 'Luis Ramírez',
      'role': 'empleado',
      'status': 'Remoto',
      'monthly_hours': 132,
    });
    await batch.commit(noResult: true);
  }

  Future<void> _seedPunches(Database db) async {
    final now = DateTime.now();
    DateTime today(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);

    final punches = [
      PunchRecord(
        userId: 1,
        userName: 'Laura Gómez',
        entryTime: today(8, 0),
        exitTime: today(12, 30),
        status: 'Completo',
      ),
      PunchRecord(
        userId: 2,
        userName: 'Carlos Pérez',
        entryTime: today(8, 15),
        exitTime: null,
        status: 'En pausa',
      ),
      PunchRecord(
        userId: 3,
        userName: 'María López',
        entryTime: today(7, 55),
        exitTime: today(11, 45),
        status: 'Completo',
      ),
      PunchRecord(
        userId: 4,
        userName: 'Luis Ramírez',
        entryTime: today(9, 10),
        exitTime: null,
        status: 'Retraso',
      ),
    ];

    final batch = db.batch();
    for (final punch in punches) {
      batch.insert('punches', punch.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<AppUser?> authenticate(String username, String password) async {
    await _ensureInitialized();
    final results = await _database!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return AppUser.fromMap(results.first);
  }

  Future<void> recordLogin(AppUser user) async {
    await _ensureInitialized();
    await _database!.insert('logins', {
      'user_id': user.id,
      'username': user.username,
      'display_name': user.displayName,
      'role': user.role,
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<LoginEntry>> fetchRecentLogins({int limit = 10}) async {
    await _ensureInitialized();
    final results = await _database!.query(
      'logins',
      orderBy: 'logged_at DESC',
      limit: limit,
    );
    return results.map(LoginEntry.fromMap).toList();
  }

  Future<List<AppUser>> fetchUsers() async {
    await _ensureInitialized();
    final results = await _database!.query(
      'users',
      orderBy: 'display_name COLLATE NOCASE ASC',
    );
    return results.map(AppUser.fromMap).toList();
  }

  Future<List<PunchRecord>> fetchPunches() async {
    await _ensureInitialized();
    final results = await _database!.query(
      'punches',
      orderBy: 'entry_time DESC',
    );
    return results.map(PunchRecord.fromMap).toList();
  }

  Future<PunchRecord> createPunch({
    required int userId,
    required String userName,
    required DateTime entryTime,
    DateTime? exitTime,
    required String status,
  }) async {
    await _ensureInitialized();
    final data = PunchRecord(
      userId: userId,
      userName: userName,
      entryTime: entryTime,
      exitTime: exitTime,
      status: status,
    );
    final id = await _database!.insert('punches', data.toMap());
    return data.copyWith(id: id);
  }
}
