import 'package:alarm_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:alarm_app/models/alarm_info.dart';
import 'package:timezone/timezone.dart' as tz;

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnRepeatInterval = 'alarmRepeatInterval';
const String columnDateTime = 'alarmDateTime';

class AlarmHelper {
  static Database? _database;
  static AlarmHelper? _alarmHelper;

  AlarmHelper._createInstance();
  factory AlarmHelper() {
    _alarmHelper ??= AlarmHelper._createInstance();
    return _alarmHelper!;
  }

  Future<Database?> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnRepeatInterval text not null,
          $columnDateTime text not null)
        ''');
      },
    );
    return database;
  }

  Future<int> insertAlarm(AlarmInfo alarmInfo) async {
    final db = await database;
    final _insertedId = await db!.insert(tableAlarm, alarmInfo.toMap());
    return _insertedId;
  }

  Future<List<AlarmInfo>> getAlarms({bool deleteNonSavedAlarms = false}) async {
    List<AlarmInfo> _alarms = [];

    var db = await database;
    var result = await db?.query(tableAlarm);
    for (var element in result!) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
    }

    if (deleteNonSavedAlarms) {
      final _pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      for (var i = 0; i < _pendingNotificationRequests.length; i++) {
        final _id = _pendingNotificationRequests[i].id;
        if (_alarms.where((element) => element.id == _id).isEmpty) {
          flutterLocalNotificationsPlugin.cancel(_id);
        }
      }
    }

    return _alarms;
  }

  Future<int> delete(int id) async {
    var db = await database;
    return await db!
        .delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }
}

class AlarmFunctions {
  static const _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          'gonzaloaldana.com/local_notifications', 'your channel name',
          channelDescription: 'your channel description'));

  /// Setting alarm for specific date
  static void scheduleAlarmOnDate(AlarmInfo alarmInfo) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmInfo.id ?? 0,
        alarmInfo.title,
        alarmInfo.title,
        tz.TZDateTime.from(alarmInfo.alarmDateTime, tz.local),
        _notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// Setting alarm for repeat interval
  static void repeatNotification(AlarmInfo alarmInfo,
      {required RepeatInterval repeatInterval}) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(alarmInfo.id ?? 0,
        alarmInfo.title, alarmInfo.title, repeatInterval, _notificationDetails,
        androidAllowWhileIdle: true);
  }

  /// TODO there are more examples here https://pub.dev/packages/flutter_local_notifications/versions/9.5.3+1/example
/* 
  Future<void> scheduleMonthlyMondayTenAMNotification(
      AlarmInfo alarmInfo) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmInfo.id ?? 0,
        alarmInfo.title,
        alarmInfo.title,
        _nextInstanceOfMondayTenAM(),
        _notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  } */
}
