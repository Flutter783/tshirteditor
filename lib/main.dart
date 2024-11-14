import 'package:flutter/material.dart';
import 'package:tshirteditor/providers/design_provider.dart';
import 'package:tshirteditor/providers/download_provider.dart';
import 'package:tshirteditor/providers/shirt_provider.dart';
import 'package:tshirteditor/providers/logo_provider.dart';
import 'package:tshirteditor/screens/home_screen.dart';
import 'package:tshirteditor/screens/splash_screen.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>DesignProvider()),
        ChangeNotifierProvider(create: (_)=>ShirtProvider()),
        ChangeNotifierProvider(create: (_)=>LogoProvider()),
        ChangeNotifierProvider(create: (_)=>DownloadProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
