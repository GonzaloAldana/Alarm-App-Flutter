import 'package:alarm_app/constants/theme_data.dart';
import 'package:alarm_app/data.dart';
import 'package:alarm_app/models/menu_info.dart';
import 'package:alarm_app/views/clock_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm_app/enums.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuItems
                .map((currentMenuInfo) => buildMenuButton(currentMenuInfo))
                .toList(),
          ),
          VerticalDivider(
            color: CustomColors.dividerColor,
            width: 1,
          ),
          Expanded(
            child: Consumer<MenuInfo>(
              builder: (BuildContext context, MenuInfo value, Widget? child) {
                if (value.menuType == MenuType.clock) {
                  return const ClockPage();
                } /* else if (value.menuType == MenuType.alarm) {
                  return AlarmPage();
                } */
                else {
                  return SizedBox(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20),
                        children: <TextSpan>[
                          const TextSpan(text: 'Upcoming Tutorial\n'),
                          TextSpan(
                            text: value.title,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget? child) {
        return TextButton(
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(32))),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            backgroundColor: currentMenuInfo.menuType == value.menuType
                ? CustomColors.menuBackgroundColor
                : Colors.transparent,
          ),
          onPressed: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            menuInfo.updateMenu(currentMenuInfo);
          },
          child: Column(
            children: <Widget>[
              Image.asset(
                currentMenuInfo.imageSource!,
                scale: 1.5,
              ),
              const SizedBox(height: 16),
              Text(
                currentMenuInfo.title ?? '',
                style: TextStyle(
                    fontFamily: 'avenir',
                    color: CustomColors.primaryTextColor,
                    fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
