import 'package:alarm_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:alarm_app/models/alarm_info.dart';
import 'package:timezone/timezone.dart' as tz;

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnDateTime = 'alarmDateTime';
const String columnPending = 'isPending';
const String columnColorIndex = 'gradientColorIndex';

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
          $columnDateTime text not null,
          $columnPending integer,
          $columnColorIndex integer)
        ''');
      },
    );
    return database;
  }

  void insertAlarm(AlarmInfo alarmInfo) async {
    var db = await database;
    await db?.insert(tableAlarm, alarmInfo.toMap());
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> _alarms = [];

    var db = await database;
    var result = await db?.query(tableAlarm);
    for (var element in result!) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
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
  static void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        alarmInfo.title,
        alarmInfo.title,
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'gonzaloaldana.com/local_notifications', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// Every minute
  /// TODO there are more examples here https://pub.dev/packages/flutter_local_notifications/versions/9.5.3+1/example
  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}
