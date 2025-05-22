import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // اگر می‌خواهید لینک‌ها را باز کنید

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Future<void> _launchURL(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (!await launchUrl(uri)) {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'تنظیمات و درباره ما',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: 20),
            // بخش درباره ما
            CupertinoListSection.insetGrouped(
              // استایل لیست iOS
              header: Text(
                'درباره برنامه',
                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
              ),
              children: <CupertinoListTile>[
                CupertinoListTile.notched(
                  title: Text(
                    'نسخه برنامه',
                    style: TextStyle(fontFamily: 'Vazirmatn'),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
                CupertinoListTile.notched(
                  title: Text(
                    'توسعه‌دهنده',
                    style: TextStyle(fontFamily: 'Vazirmatn'),
                  ),
                  additionalInfo: Text(
                    'محمدمهدی ابدال محمودآبادی',
                    style: TextStyle(fontFamily: 'Vazirmatn'),
                  ),
                  trailing: Icon(
                    CupertinoIcons.chevron_forward,
                    color: CupertinoColors.inactiveGray,
                  ),
                  onTap: () {
                    // نمایش اطلاعات بیشتر در یک دیالوگ یا صفحه جدید
                    showCupertinoModalPopup(
                      context: context,
                      builder:
                          (BuildContext context) => CupertinoActionSheet(
                            title: Text(
                              'محمدمهدی ابدال محمودآبادی',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            message: Text(
                              'توسعه‌دهنده فلاتر علاقه‌مند به ساخت اپلیکیشن‌های کاربردی و زیبا.\nهمواره در پی یادگیری فناوری‌های جدید.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 14,
                              ),
                            ),
                            actions: <CupertinoActionSheetAction>[
                              // CupertinoActionSheetAction(
                              //   child: Text('وبسایت من', style: TextStyle(fontFamily: 'Vazirmatn')),
                              //   onPressed: () {
                              //     _launchURL('https://example.com'); // لینک خودتان
                              //     Navigator.pop(context);
                              //   },
                              // ),
                              // CupertinoActionSheetAction(
                              //   child: Text('ارتباط با من', style: TextStyle(fontFamily: 'Vazirmatn')),
                              //   onPressed: () {
                              //      _launchURL('mailto:your.email@example.com'); // ایمیل خودتان
                              //     Navigator.pop(context);
                              //   },
                              // ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: Text(
                                'بستن',
                                style: TextStyle(fontFamily: 'Vazirmatn'),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                    );
                  },
                ),
              ],
            ),

            // بخش تنظیمات (در آینده می‌توانید اضافه کنید)
            // CupertinoListSection.insetGrouped(
            //   header: Text('تنظیمات ظاهری', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
            //   children: <CupertinoListTile>[
            //     CupertinoListTile.notched(
            //       title: Text('حالت تاریک', style: TextStyle(fontFamily: 'Vazirmatn')),
            //       trailing: CupertinoSwitch(
            //         value: false, // مقدار را از یک Provider یا SharedPreferences بگیرید
            //         onChanged: (bool value) {
            //           // منطق تغییر تم
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'ساخته شده با ❤️ توسط محمدمهدی ابدال محمودآبادی',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
