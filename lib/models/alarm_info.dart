class AlarmInfo {
  int? id;
  String title;
  DateTime alarmDateTime;
  AlarmRepeatInterval alarmRepeatInterval;

  AlarmInfo({
    this.id,
    required this.title,
    required this.alarmDateTime,
    required this.alarmRepeatInterval,
  });

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        alarmRepeatInterval: AlarmRepeatInterval.values.firstWhere(
            (e) => e.toString() == json["alarmRepeatInterval"],
            orElse: () => AlarmRepeatInterval.onDate),
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "alarmDateTime": alarmDateTime.toIso8601String(),
        "alarmRepeatInterval": alarmRepeatInterval.toString(),
      };
}

enum AlarmRepeatInterval {
  everyMinute,
  hourly,
  // An alarm every 8 hours is a list of 3 alarms every day
/* 
  every6Hours,
  every8Hours,
  every12Hours, */
  daily,
  weekly,
  onDate,
}

Map alarmRepeatIntervalDisplay = {
  AlarmRepeatInterval.everyMinute: 'Every minute',
  AlarmRepeatInterval.hourly: 'Every hour',
  AlarmRepeatInterval.daily: 'Every day',
  AlarmRepeatInterval.weekly: 'Every week',
  AlarmRepeatInterval.onDate: 'On a specific date',
};
