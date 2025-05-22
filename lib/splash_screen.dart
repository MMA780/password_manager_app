import 'package:flutter/material.dart';
import 'package:password_manager_app/home_page.dart';
import 'package:animate_do/animate_do.dart'; // اطمینان از ایمپورت

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600), // کمی سریعتر
      vsync: this,
    );

    // انیمیشن مقیاس برای لوگو با افکت ارتجاعی جذاب تر
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // افکت جذاب
      ),
    );

    // انیمیشن محو شدن برای لوگو و متن
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.2,
          1.0,
          curve: Curves.easeOutSine,
        ), // شروع محو شدن با کمی تاخیر
      ),
    );

    _controller.forward();

    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(
      Duration(milliseconds: 2800),
      () {},
    ); // زمان نمایش قبل از انتقال
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // استفاده از SlideTransition برای ورود صفحه اصلی از پایین
            var begin = Offset(0.0, 0.3); // شروع از کمی پایین تر
            var end = Offset.zero;
            var curve = Curves.easeOutQuint; // منحنی نرم تر
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ); // برای محو شدن همزمان

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: Duration(
            milliseconds: 600,
          ), // مدت زمان انتقال صفحه
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ترکیب انیمیشن مقیاس و محو شدن برای لوگو
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Hero(
                  // اضافه کردن Hero برای انیمیشن احتمالی به صفحه دیگر
                  tag: 'app_logo',
                  child: Image.asset(
                    "assets/images/icon.png",
                    width: 110, // اندازه مناسب
                    height: 110,
                    fit: BoxFit.contain,
                    color: Colors.white, // اگر لوگو نیاز به رنگ سفید دارد
                  ),
                ),
              ),
            ),
            SizedBox(height: 30), // فاصله بیشتر
            // انیمیشن محو شدن برای متن
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                "مدیریت رمزها",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27, // اندازه متناسب
                  fontWeight: FontWeight.bold, // تاکید بیشتر
                  letterSpacing: 0.5, // کمی فاصله بین حروف
                  shadows: [
                    Shadow(
                      blurRadius: 12.0, // سایه نرم‌تر
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(1.5, 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
