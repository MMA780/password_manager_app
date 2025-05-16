import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';
import 'dart:ui' show TextDirection;

// صفحات
import 'splash_screen.dart'; // صفحه اولیه اسپلش
// ignore: unused_import
import 'home_page.dart';     // صفحه اصلی برنامه

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // راه‌اندازی Hive
  await Hive.initFlutter();
  Hive.registerAdapter<PasswordEntry>(PasswordEntryAdapter());
  await Hive.openBox<PasswordEntry>('passwords');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست-چین کردن کل برنامه
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مدیریت رمزها',
        theme: ThemeData(
          primaryColor: Colors.green[800],
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
          ),
        ),
        home: SplashScreen(), // اولین صفحه نمایشی
      ),
    );
  }
}