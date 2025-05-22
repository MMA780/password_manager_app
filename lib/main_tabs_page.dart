import 'package:flutter/cupertino.dart';
import 'package:password_manager_app/home_page.dart'; // صفحه رمزها
import 'package:password_manager_app/dashboard_page.dart'; // صفحه داشبورد

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key});

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lock_shield_fill),
            label: 'رمزها',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie_fill),
            label: 'داشبورد',
          ),
          // می‌توانید تب "درباره ما" را هم اینجا اضافه کنید
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.info_circle_fill),
          //   label: 'درباره ما',
          // ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        CupertinoTabView? returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: HomePage(), // ارجاع به HomePage بازنویسی شده
                );
              },
            );
            break;
          case 1:
            returnValue = CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: DashboardPage(), // ارجاع به DashboardPage بازنویسی شده
                );
              },
            );
            break;
          // case 2:
          //   returnValue = CupertinoTabView(builder: (context) {
          //     return CupertinoPageScaffold(
          //       child: AboutUsPage(), // صفحه درباره ما جدید
          //     );
          //   });
          //   break;
        }
        return returnValue!;
      },
    );
  }
}
