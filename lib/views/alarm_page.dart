import 'package:alarm_app/alarm_helper.dart';
import 'package:alarm_app/constants/theme_data.dart';
import 'package:alarm_app/main.dart';
import 'package:alarm_app/models/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late DateTime _alarmTime;
  late String _alarmTimeString;
  final AlarmHelper _alarmHelper = AlarmHelper();
  late Future<List<AlarmInfo>> _alarms;
  AlarmRepeatInterval _alarmRepeatInterval = AlarmRepeatInterval.onDate;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alarmTime = DateTime.now();
    loadAlarms();
    _alarmHelper.initializeDatabase().then((value) {
      loadAlarms(deleteNonSavedAlarms: true);
    });
  }

  void loadAlarms({bool deleteNonSavedAlarms = false}) {
    _alarms =
        _alarmHelper.getAlarms(deleteNonSavedAlarms: deleteNonSavedAlarms);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _addAlarmBtn = DottedBorder(
      strokeWidth: 2,
      color: CustomColors.clockOutline,
      borderType: BorderType.RRect,
      radius: const Radius.circular(24),
      dashPattern: const [5, 4],
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColors.clockBG,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () {
            _alarmTimeString = DateFormat(
                    _alarmRepeatInterval == AlarmRepeatInterval.onDate
                        ? 'd/M/y HH:mm'
                        : 'HH:mm')
                .format(_alarmTime);
            showModalBottomSheet(
              useRootNavigator: true,
              context: context,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () async {
                              final _now = DateTime.now();
                              if (_alarmRepeatInterval ==
                                  AlarmRepeatInterval.onDate) {
                                final _selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _alarmTime,
                                    firstDate: _now,
                                    lastDate: _now
                                        .add(const Duration(days: 365 * 10)));

                                if (_selectedDate == null) return;
                                _alarmTime = _selectedDate;
                              } else {
                                _alarmTime = _now;
                              }

                              var selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (selectedTime != null) {
                                var selectedDateTime = DateTime(
                                    _alarmTime.year,
                                    _alarmTime.month,
                                    _alarmTime.day,
                                    selectedTime.hour,
                                    selectedTime.minute);
                                _alarmTime = selectedDateTime;
                                setModalState(() {
                                  _alarmTimeString = DateFormat(
                                          _alarmRepeatInterval ==
                                                  AlarmRepeatInterval.onDate
                                              ? 'd/M/y HH:mm'
                                              : 'HH:mm')
                                      .format(selectedDateTime);
                                });
                              }
                            },
                            child: Text(
                              _alarmTimeString,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          DropdownButton<AlarmRepeatInterval>(
                            isExpanded: true,
                            value: _alarmRepeatInterval,
                            items: AlarmRepeatInterval.values
                                .map((e) =>
                                    DropdownMenuItem<AlarmRepeatInterval>(
                                      value: e,
                                      child:
                                          Text(alarmRepeatIntervalDisplay[e]),
                                    ))
                                .toList(),
                            onChanged: (v) => setModalState(() {
                              _alarmRepeatInterval = v!;
                              _alarmTimeString = DateFormat(
                                      _alarmRepeatInterval ==
                                              AlarmRepeatInterval.onDate
                                          ? 'd/M/y HH:mm'
                                          : 'HH:mm')
                                  .format(_alarmTime);
                            }),
                          ),
                          TextFormField(
                            controller: _titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton.extended(
                            onPressed: onSaveAlarm,
                            icon: const Icon(Icons.alarm),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/add_alarm.png',
                scale: 1.5,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add Alarm',
                style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
              ),
            ],
          ),
        ),
      ),
    );

    List<Widget> _cards(AsyncSnapshot<List<AlarmInfo>> snapshot) {
      final _list = <Widget>[];

      for (var i = 0; i < snapshot.data!.length; i++) {
        final alarm = snapshot.data![i];

        var alarmTime = DateFormat(
                alarm.alarmRepeatInterval == AlarmRepeatInterval.onDate
                    ? 'd/M/y HH:mm'
                    : 'hh:mm aa')
            .format(alarm.alarmDateTime);
        var gradientColor =
            GradientTemplate.gradientTemplate[alarm.id! % 5].colors;
        final _widget = Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColor,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColor.last.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.label,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alarm.title,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'avenir'),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                alarmRepeatIntervalDisplay[alarm.alarmRepeatInterval],
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'avenir'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    alarmTime,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'avenir',
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        deleteAlarm(alarm.id!);
                      }),
                ],
              ),
            ],
          ),
        );

        _list.add(_widget);
      }
      return _list;
    }

    final _futureContainer = Expanded(
      child: FutureBuilder<List<AlarmInfo>>(
        future: _alarms,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: _cards(snapshot).toList().followedBy([
                _addAlarmBtn,
              ]).toList(),
            );
          }
          return const Center(
            child: Text(
              'Loading..',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          _futureContainer,
        ],
      ),
    );
  }

  Future<void> onSaveAlarm() async {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = _alarmTime;
    } else {
      scheduleAlarmDateTime = _alarmTime.add(const Duration(days: 1));
    }

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      title: _titleController.text,
      alarmRepeatInterval: _alarmRepeatInterval,
    );
    _titleController.clear();
    final _insertedId = await _alarmHelper.insertAlarm(alarmInfo);
    alarmInfo.id = _insertedId;

    switch (_alarmRepeatInterval) {
      case AlarmRepeatInterval.onDate:
        AlarmFunctions.scheduleAlarmOnDate(alarmInfo);
        break;
      case AlarmRepeatInterval.daily:
        AlarmFunctions.repeatNotification(alarmInfo,
            repeatInterval: RepeatInterval.daily);
        break;
      case AlarmRepeatInterval.everyMinute:
        AlarmFunctions.repeatNotification(alarmInfo,
            repeatInterval: RepeatInterval.everyMinute);
        break;
      case AlarmRepeatInterval.hourly:
        AlarmFunctions.repeatNotification(alarmInfo,
            repeatInterval: RepeatInterval.hourly);
        break;
      case AlarmRepeatInterval.weekly:
        AlarmFunctions.repeatNotification(alarmInfo,
            repeatInterval: RepeatInterval.weekly);
        break;
      default:
        AlarmFunctions.scheduleAlarmOnDate(alarmInfo);
    }

    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    flutterLocalNotificationsPlugin.cancel(id);
    loadAlarms();
  }
}
