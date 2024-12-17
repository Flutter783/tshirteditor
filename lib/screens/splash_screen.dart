import 'package:flutter/material.dart';
import '../service/app_color.dart';
import '../services/ad_Server.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  final AdsServer adsServer = AdsServer();
  bool showButton=false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override

  void initState() {
    super.initState();
    methodShowButton();
    adsServer.checkInternet();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start below the screen
      end: Offset.zero, // End at its final position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

  }
  void methodShowButton() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showButton=true;
        _animationController.forward();
      });
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
              showButton ? SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        elevation: 3,
                        color: AppColors.appColor,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: 
                          Text('Get Start',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                  ),
                ),
              ) :
              Container(),
            ],
          )
        )
    );
  }
}
