import 'package:flutter/material.dart';
import '../internet_checker.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    InternetChecker().checkInternet();
    navigateScreen();

  }
  void navigateScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/splash.png',fit: BoxFit.fill),
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CircularProgressIndicator(color: Colors.black)),
              )
            ],
          )
        )
    );
  }
}
