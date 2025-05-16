import 'package:flutter/material.dart';
import 'package:password_manager_app/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // تنظیمات انیمیشن
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() => setState(() {}));

    _controller.forward();

    // منتقل کردن به صفحه اصلی بعد از 2 ثانیه
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800], // 🟩 پس‌زمینه سبز تیره
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                "assets/images/icon.png", // 📎 لوگوی سفید
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                color:
                    Colors.white, // اگر لوگو سیاه/خاکستری بود، رنگش رو سفید کن
              ),
            ),
            SizedBox(height: 20),
            Text(
              "مدیریت رمزها",
              style: TextStyle(
                color: Colors.white, // 🪧 متن سفید
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
