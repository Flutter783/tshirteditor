import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';
bool isInternetConnected=false;

class InternetChecker {
  static final InternetChecker _instance = InternetChecker._internal();
  factory InternetChecker() {
    return _instance;
  }
  InternetChecker._internal();

  Future<void> checkInternet() async {
    isInternetConnected = await InternetConnectionChecker().hasConnection;
    Timer(const Duration(seconds: 1), checkInternet);
  }

}
