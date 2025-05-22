import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';
import 'dart:ui' show TextDirection;
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<PasswordEntry>(PasswordEntryAdapter());
  await Hive.openBox<PasswordEntry>('passwords');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF008C00);
    const Color darkGreen = Color(0xFF006000);
    const Color backgroundColor = Color(
      0xFFF0F4F0,
    ); // کمی روشن‌تر برای پس‌زمینه
    const Color cardBackgroundColor = Colors.white;
    const Color errorColor = Color(0xFFD32F2F); // یک قرمز استاندارد برای خطا

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مدیریت رمزها',
        theme: ThemeData(
          useMaterial3: true, // فعال کردن Material 3
          primaryColor: primaryGreen,
          scaffoldBackgroundColor: backgroundColor,
          fontFamily: null,

          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryGreen,
            primary: primaryGreen,
            secondary: darkGreen, // سبز تیره‌تر به عنوان رنگ ثانویه/تاکیدی
            background: backgroundColor,
            surface: cardBackgroundColor,
            error: errorColor,
            brightness: Brightness.light,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Color(
              0xFF1C1B1F,
            ), // رنگ متن استاندارد Material 3 روی پس‌زمینه
            onSurface: Color(
              0xFF1C1B1F,
            ), // رنگ متن استاندارد Material 3 روی کارت‌ها
            onError: Colors.white,
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 1.5, // سایه ملایم‌تر
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600, // کمی ضخیم‌تر
              color: Colors.white,
              fontFamily: null,
            ),
          ),

          cardTheme: CardTheme(
            elevation: 1.5, // سایه کمتر و مدرن‌تر
            margin: EdgeInsets.symmetric(
              vertical: 7.0,
              horizontal: 14.0,
            ), // مارجین کمی متفاوت
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16.0,
              ), // گردی بیشتر برای کارت‌ها
            ),
            color: cardBackgroundColor,
            shadowColor: Colors.black.withOpacity(0.08), // سایه خیلی ملایم
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9), // کمی شفافیت برای فیلدها
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // گردی بیشتر
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primaryGreen, width: 1.5),
            ),
            labelStyle: TextStyle(
              color: darkGreen.withOpacity(0.9),
              fontFamily: null,
              fontSize: 15,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontFamily: null,
              fontSize: 14.5,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ), // پدینگ داخلی بیشتر
            prefixIconColor: primaryGreen.withOpacity(0.75),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 15,
              ), // پدینگ کمی بیشتر
              textStyle: TextStyle(
                fontSize: 15.5, // اندازه فونت متناسب
                fontWeight: FontWeight.w600,
                fontFamily: null,
                letterSpacing: 0.5, // کمی فاصله بین حروف
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // گردی دکمه‌ها
              ),
              elevation: 2.5, // سایه بیشتر برای تاکید
            ),
          ),

          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: darkGreen,
            foregroundColor: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            extendedTextStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          chipTheme: ChipThemeData(
            backgroundColor: primaryGreen.withOpacity(0.12),
            labelStyle: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w600,
              fontFamily: null,
              fontSize: 13.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            iconTheme: IconThemeData(color: primaryGreen, size: 18),
            elevation: 0.5,
            shadowColor: Colors.black.withOpacity(0.1),
          ),

          dividerTheme: DividerThemeData(
            color: Colors.grey.shade200, // جداکننده روشن‌تر
            thickness: 0.8,
            space: 1, // حداقل فضا
          ),

          listTileTheme: ListTileThemeData(
            iconColor: primaryGreen,
            selectedTileColor: primaryGreen.withOpacity(
              0.08,
            ), // رنگ انتخاب خیلی ملایم
            dense: true, // کمی فشرده‌تر کردن ListTile ها
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1B1F),
              fontFamily: null,
            ),
            subtitleTextStyle: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              fontFamily: null,
            ),
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 18.0,
              vertical: 2.0,
            ), // پدینگ جهتی
          ),

          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: darkGreen, // رنگ پیش‌فرض آیکون‌ها
              iconSize: 24.0, // اندازه استاندارد
            ),
          ),

          textTheme: TextTheme(
            // تعریف استایل‌های متن اصلی برای یکپارچگی
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF1C1B1F),
              height: 1.4,
            ), // متن‌های اصلی
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF49454F),
              height: 1.3,
            ), // متن‌های فرعی
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ), // برای لیبل‌ها
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1B1F),
            ), // عناوین متوسط
            headlineSmall: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ), // عناوین کوچک
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
