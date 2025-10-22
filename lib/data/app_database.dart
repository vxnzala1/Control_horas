import 'dart:async';

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  bool get canManageFichajes => role == 'admin';
  bool get canExport => role == 'admin';
  bool get canGenerateReports => role == 'admin';
  bool get canManageProjects => role == 'admin';

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
  String? _dbPath;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    sqfliteFfiInit();
    // Resolve DB directory; fallback if path_provider plugin isn't registered
    Directory dbDir;
    try {
      dbDir = await getApplicationDocumentsDirectory();
    } catch (_) {
      final fallback = Directory(p.join(Directory.current.path, 'data'));
      if (!fallback.existsSync()) {
        fallback.createSync(recursive: true);
      }
      dbDir = fallback;
    }
    final dbPath = p.join(dbDir.path, 'control_horas.db');
    _dbPath = dbPath;

    _database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 5,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
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
            'user_id INTEGER NOT NULL, '
            'username TEXT, '
            'display_name TEXT, '
            'role TEXT, '
            'logged_at TEXT, '
            'FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE'
            ')',
          );
          await db.execute(
            'CREATE TABLE projects ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name TEXT UNIQUE NOT NULL'
            ')',
          );
          await db.execute(
            'CREATE TABLE sessions ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'user_id INTEGER NOT NULL, '
            'project_id INTEGER NOT NULL, '
            'start_at TEXT NOT NULL, '
            'end_at TEXT, '
            'status TEXT NOT NULL, '
            'confirmed_by INTEGER, '
            'confirmed_at TEXT, '
            'confirmed_hours REAL, '
            'FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE, '
            'FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE'
            ')',
          );
          // Indexes
          await db.execute('CREATE INDEX idx_logins_logged_at ON logins(logged_at)');
          await db.execute('CREATE INDEX idx_sessions_user ON sessions(user_id)');
          await db.execute('CREATE INDEX idx_sessions_project ON sessions(project_id)');
          await db.execute('CREATE INDEX idx_sessions_status ON sessions(status)');
          await _seedUsers(db);
          await _seedProjects(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'CREATE TABLE projects ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT UNIQUE NOT NULL'
              ')',
            );
            await db.execute(
              'CREATE TABLE sessions ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'user_id INTEGER NOT NULL, '
              'project_id INTEGER NOT NULL, '
              'start_at TEXT NOT NULL, '
              'end_at TEXT, '
              'status TEXT NOT NULL'
              ')',
            );
            await _seedProjects(db);
          }
          if (oldVersion < 3) {
            // Recreate logins with FK
            await db.execute(
              'CREATE TABLE logins_new ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'user_id INTEGER NOT NULL, '
              'username TEXT, '
              'display_name TEXT, '
              'role TEXT, '
              'logged_at TEXT, '
              'FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE'
              ')',
            );
            await db.execute(
              'INSERT INTO logins_new (id, user_id, username, display_name, role, logged_at) '
              'SELECT id, user_id, username, display_name, role, logged_at '
              'FROM logins WHERE user_id IN (SELECT id FROM users)'
            );
            await db.execute('DROP TABLE logins');
            await db.execute('ALTER TABLE logins_new RENAME TO logins');

            // Recreate sessions with FKs
            await db.execute(
              'CREATE TABLE sessions_new ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'user_id INTEGER NOT NULL, '
              'project_id INTEGER NOT NULL, '
              'start_at TEXT NOT NULL, '
              'end_at TEXT, '
              'status TEXT NOT NULL, '
              'FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE, '
              'FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE'
              ')',
            );
            await db.execute(
              'INSERT INTO sessions_new (id, user_id, project_id, start_at, end_at, status) '
              'SELECT id, user_id, project_id, start_at, end_at, status '
              'FROM sessions '
              'WHERE user_id IN (SELECT id FROM users) '
              'AND project_id IN (SELECT id FROM projects)'
            );
            await db.execute('DROP TABLE sessions');
            await db.execute('ALTER TABLE sessions_new RENAME TO sessions');

            // Indexes
            await db.execute('CREATE INDEX IF NOT EXISTS idx_logins_logged_at ON logins(logged_at)');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id)');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_project ON sessions(project_id)');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status)');
          }
          if (oldVersion < 4) {
            // Add projected_hours to projects
            await db.execute(
              'ALTER TABLE projects ADD COLUMN projected_hours INTEGER NOT NULL DEFAULT 0',
            );

            // Ensure default passwords and roles as requested
            // Set everyone to empleado by default
            await db.execute("UPDATE users SET role = 'empleado'");

            // Upsert specified users with admin role where needed
            /* Admins: Valentín, Alberto, Antonio, Gosia */
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('valentin.porta@motitworld.com','admin123','Valentín Porta','admin','Activo',160)",
            );
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('alberto.leon@motitworld.com','admin123','Alberto León','admin','Activo',160)",
            );
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('antonio.venzala@motitworld.com','admin123','Antonio Venzalá','admin','Activo',160)",
            );
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('gosia@motitworld.com','admin123','Gosia Szymkowiak','admin','Activo',160)",
            );

            // Set these four to admin in case they already existed
            await db.execute(
              "UPDATE users SET role='admin', password='admin123', display_name='Valentín Porta', status='Activo', monthly_hours=160 WHERE username='valentin.porta@motitworld.com'",
            );
            await db.execute(
              "UPDATE users SET role='admin', password='admin123', display_name='Alberto León', status='Activo', monthly_hours=160 WHERE username='alberto.leon@motitworld.com'",
            );
            await db.execute(
              "UPDATE users SET role='admin', password='admin123', display_name='Antonio Venzalá', status='Activo', monthly_hours=160 WHERE username='antonio.venzala@motitworld.com'",
            );
            await db.execute(
              "UPDATE users SET role='admin', password='admin123', display_name='Gosia Szymkowiak', status='Activo', monthly_hours=160 WHERE username='gosia@motitworld.com'",
            );

            // Insert remaining non-admin users (empleados)
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('polina.krylnikova@motitworld.com','admin123','Polina Krylnikova','empleado','Activo',160)",
            );
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('cristobal.cruz@motitworld.com','admin123','Cristóbal Cruz','empleado','Activo',160)",
            );
            await db.execute(
              "INSERT OR IGNORE INTO users (username, password, display_name, role, status, monthly_hours) VALUES "
              "('alvaro.hidalgo@motitworld.com','admin123','Álvaro Hidalgo','empleado','Activo',160)",
            );

            // Demote any seed 'admin' or 'manager' accounts except the specified ones
            await db.execute(
              "UPDATE users SET role='empleado' WHERE role IN ('admin','manager') AND username NOT IN (" 
              "'valentin.porta@motitworld.com','alberto.leon@motitworld.com','antonio.venzala@motitworld.com','gosia@motitworld.com'"
              ")",
            );
          }
          if (oldVersion < 5) {
            await db.execute('ALTER TABLE sessions ADD COLUMN confirmed_by INTEGER');
            await db.execute('ALTER TABLE sessions ADD COLUMN confirmed_at TEXT');
            await db.execute('ALTER TABLE sessions ADD COLUMN confirmed_hours REAL');
          }
        },
      ),
    );

    _initialized = true;
  }

  String? get databasePath => _dbPath;

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

  Future<void> _seedProjects(Database db) async {
    final batch = db.batch();
    batch.insert('projects', {'name': 'Proyecto General'});
    batch.insert('projects', {'name': 'Proyecto Interno'});
    batch.insert('projects', {'name': 'Cliente A'});
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

  // --- Projects ---
  Future<int> createProject({
    required String name,
    int projectedHours = 0,
  }) async {
    await _ensureInitialized();
    return _database!.insert('projects', {
      'name': name,
      'projected_hours': projectedHours,
    });
  }

  Future<List<Project>> fetchProjects() async {
    await _ensureInitialized();
    final res = await _database!.query('projects', orderBy: 'name COLLATE NOCASE');
    return res.map(Project.fromMap).toList();
  }

  // --- Sessions ---
  Future<int> startSession({
    required int userId,
    required int projectId,
  }) async {
    await _ensureInitialized();
    final id = await _database!.insert('sessions', {
      'user_id': userId,
      'project_id': projectId,
      'start_at': DateTime.now().toIso8601String(),
      'end_at': null,
      'status': 'running',
    });
    return id;
  }

  Future<void> pauseSession(int sessionId) async {
    await _ensureInitialized();
    await _database!.update(
      'sessions',
      {'status': 'paused'},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> resumeSession(int sessionId) async {
    await _ensureInitialized();
    await _database!.update(
      'sessions',
      {'status': 'running'},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> stopSession(int sessionId) async {
    await _ensureInitialized();
    await _database!.update(
      'sessions',
      {
        'status': 'stopped',
        'end_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> confirmSessionHours({
    required int sessionId,
    required int confirmedByUserId,
    required double hours,
  }) async {
    await _ensureInitialized();
    final rows = await _database!.query('sessions', where: 'id = ?', whereArgs: [sessionId], limit: 1);
    if (rows.isEmpty) return;
    final startAt = DateTime.parse(rows.first['start_at'] as String);
    final minutes = (hours * 60).round();
    final newEnd = startAt.add(Duration(minutes: minutes));
    await _database!.update(
      'sessions',
      {
        'end_at': newEnd.toIso8601String(),
        'status': 'stopped',
        'confirmed_by': confirmedByUserId,
        'confirmed_at': DateTime.now().toIso8601String(),
        'confirmed_hours': hours,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<Session?> getActiveSessionForUser(int userId) async {
    await _ensureInitialized();
    final res = await _database!.query(
      'sessions',
      where: 'user_id = ? AND status IN (?, ?)',
      whereArgs: [userId, 'running', 'paused'],
      orderBy: 'start_at DESC',
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Session.fromMap(res.first);
  }

  Future<List<Session>> fetchSessions({int? userId}) async {
    await _ensureInitialized();
    final res = await _database!.query(
      'sessions',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'start_at DESC',
    );
    return res.map(Session.fromMap).toList();
  }

  Future<void> updatePassword({required int userId, required String newPassword}) async {
    await _ensureInitialized();
    await _database!.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // --- Aggregates / Reports ---
  Future<List<UserHours>> totalHoursByUser({
    DateTime? from,
    DateTime? to,
    bool includeRunning = true,
  }) async {
    await _ensureInitialized();
    final nowIso = DateTime.now().toIso8601String();
    final where = <String>[];
    final args = <Object?>[];
    if (from != null) {
      where.add('s.start_at >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('s.start_at <= ?');
      args.add(to.toIso8601String());
    }
    final statusFilter = includeRunning
        ? "(s.status = 'stopped' OR s.status = 'running')"
        : "(s.status = 'stopped')";
    where.add(statusFilter);
    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final sql = '''
      SELECT u.id AS user_id,
             u.display_name AS display_name,
             SUM( (strftime('%s', COALESCE(s.end_at, ?)) - strftime('%s', s.start_at)) ) / 3600.0 AS hours
      FROM sessions s
      JOIN users u ON u.id = s.user_id
      $whereSql
      GROUP BY u.id, u.display_name
      ORDER BY hours DESC
    ''';
    final rows = await _database!.rawQuery(sql, [nowIso, ...args]);
    return rows.map(UserHours.fromMap).toList();
  }

  Future<List<ProjectHours>> totalHoursByProject({
    DateTime? from,
    DateTime? to,
    bool includeRunning = true,
  }) async {
    await _ensureInitialized();
    final nowIso = DateTime.now().toIso8601String();
    final where = <String>[];
    final args = <Object?>[];
    if (from != null) {
      where.add('s.start_at >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('s.start_at <= ?');
      args.add(to.toIso8601String());
    }
    final statusFilter = includeRunning
        ? "(s.status = 'stopped' OR s.status = 'running')"
        : "(s.status = 'stopped')";
    where.add(statusFilter);
    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final sql = '''
      SELECT p.id AS project_id,
             p.name AS project_name,
             SUM( (strftime('%s', COALESCE(s.end_at, ?)) - strftime('%s', s.start_at)) ) / 3600.0 AS hours
      FROM sessions s
      JOIN projects p ON p.id = s.project_id
      $whereSql
      GROUP BY p.id, p.name
      ORDER BY hours DESC
    ''';
    final rows = await _database!.rawQuery(sql, [nowIso, ...args]);
    return rows.map(ProjectHours.fromMap).toList();
  }

  Future<List<DailyHours>> dailyHoursForUser({
    required int userId,
    required DateTime from,
    required DateTime to,
    bool includeRunning = true,
  }) async {
    await _ensureInitialized();
    final nowIso = DateTime.now().toIso8601String();
    final statusFilter = includeRunning
        ? "(status = 'stopped' OR status = 'running')"
        : "(status = 'stopped')";
    final sql = '''
      SELECT DATE(start_at) AS day,
             SUM( (strftime('%s', COALESCE(end_at, ?)) - strftime('%s', start_at)) ) / 3600.0 AS hours
      FROM sessions
      WHERE user_id = ?
        AND start_at >= ?
        AND start_at <= ?
        AND $statusFilter
      GROUP BY DATE(start_at)
      ORDER BY day ASC
    ''';
    final rows = await _database!.rawQuery(sql, [
      nowIso,
      userId,
      from.toIso8601String(),
      to.toIso8601String(),
    ]);
    return rows.map(DailyHours.fromMap).toList();
  }
}

class Project {
  const Project({required this.id, required this.name, required this.projectedHours});
  final int id;
  final String name;
  final int projectedHours;
  factory Project.fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as int,
        name: map['name'] as String,
        projectedHours: (map['projected_hours'] as int?) ?? 0,
      );
}

class Session {
  const Session({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.startAt,
    this.endAt,
    required this.status,
  });

  final int id;
  final int userId;
  final int projectId;
  final DateTime startAt;
  final DateTime? endAt;
  final String status;

  factory Session.fromMap(Map<String, Object?> map) => Session(
        id: map['id'] as int,
        userId: map['user_id'] as int,
        projectId: map['project_id'] as int,
        startAt: DateTime.parse(map['start_at'] as String),
        endAt: map['end_at'] != null ? DateTime.tryParse(map['end_at'] as String) : null,
        status: map['status'] as String,
      );
}

class UserHours {
  const UserHours({required this.userId, required this.displayName, required this.hours});
  final int userId;
  final String displayName;
  final double hours;
  factory UserHours.fromMap(Map<String, Object?> map) => UserHours(
        userId: (map['user_id'] as num).toInt(),
        displayName: map['display_name'] as String,
        hours: (map['hours'] as num?)?.toDouble() ?? 0.0,
      );
}

class ProjectHours {
  const ProjectHours({required this.projectId, required this.projectName, required this.hours});
  final int projectId;
  final String projectName;
  final double hours;
  factory ProjectHours.fromMap(Map<String, Object?> map) => ProjectHours(
        projectId: (map['project_id'] as num).toInt(),
        projectName: map['project_name'] as String,
        hours: (map['hours'] as num?)?.toDouble() ?? 0.0,
      );
}

class DailyHours {
  const DailyHours({required this.day, required this.hours});
  final String day; // YYYY-MM-DD
  final double hours;
  factory DailyHours.fromMap(Map<String, Object?> map) => DailyHours(
        day: map['day'] as String,
        hours: (map['hours'] as num?)?.toDouble() ?? 0.0,
      );
}
