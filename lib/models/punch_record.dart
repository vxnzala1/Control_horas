import 'package:intl/intl.dart';

class PunchRecord {
  const PunchRecord({
    this.id,
    required this.userId,
    required this.userName,
    required this.entryTime,
    this.exitTime,
    required this.status,
  });

  final int? id;
  final int userId;
  final String userName;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String status;

  PunchRecord copyWith({
    int? id,
    int? userId,
    String? userName,
    DateTime? entryTime,
    Object? exitTime = _sentinel,
    String? status,
  }) {
    return PunchRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      entryTime: entryTime ?? this.entryTime,
      exitTime:
          identical(exitTime, _sentinel) ? this.exitTime : exitTime as DateTime?,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'user_id': userId,
      'user_name': userName,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'status': status,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory PunchRecord.fromMap(Map<String, Object?> map) {
    return PunchRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      userName: map['user_name'] as String,
      entryTime: DateTime.parse(map['entry_time'] as String),
      exitTime: map['exit_time'] != null
          ? DateTime.parse(map['exit_time'] as String)
          : null,
      status: map['status'] as String,
    );
  }

  String get formattedEntry => DateFormat('HH:mm').format(entryTime);

  String get formattedExit =>
      exitTime != null ? DateFormat('HH:mm').format(exitTime!) : '—';

  double get workedHours {
    if (exitTime == null) {
      return 0;
    }
    final duration = exitTime!.difference(entryTime);
    return duration.inMinutes / 60.0;
  }
}

const _sentinel = Object();
