import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tshirteditor/screens/design_screen.dart';
import 'package:tshirteditor/screens/saved_screen.dart';
import 'package:tshirteditor/screens/shirt_screen.dart';
import 'package:tshirteditor/service/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showExitAppDialog(context);
        return shouldLeave ?? false;
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 90),
                        child: Image.asset('assets/images/background.png',
                            fit: BoxFit.fill),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20,bottom: 60),
                        child: Column(
                          children: [
                            Expanded(child: Image.asset('assets/images/shirt.png')),
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    spreadRadius: 5,
                                    blurRadius: 20,
                                    offset: Offset(0, 20), // changes position of shadow on x and y axes
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: SvgPicture.asset(
                                  'assets/images/ic_menu.svg')),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            shareApp();
                          },
                          child: Container(
                            height: 35,
                            width: MediaQuery.of(context).size.width*0.31,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    height: 18,
                                    width: 18,
                                    margin: const EdgeInsets.only(right: 5),
                                    child: SvgPicture.asset(
                                        'assets/images/ic_share.svg',
                                        color: Colors.white)),
                                const Text('Share App',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13))
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ShirtScreen(isEditorScreen: false)));
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: AppColors.appColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        margin: const EdgeInsets.all(8),
                                        child: Image.asset(
                                            'assets/images/img1.png',
                                            fit: BoxFit.fill),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 8),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                                child: Text('Create New',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis)),
                                            Container(
                                              width: 55,
                                              height: 27,
                                              padding: const EdgeInsets.all(4),
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(30)),
                                              child: SvgPicture.asset(
                                                  'assets/images/ic_create.svg',
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DesignScreen()));
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: AppColors.appColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        margin: const EdgeInsets.all(8),
                                        child: Image.asset(
                                            'assets/images/img2.png',
                                            fit: BoxFit.fill),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 8),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                                child: Text('Shirt Ideas',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis)),
                                            Container(
                                              width: 55,
                                              height: 27,
                                              padding: const EdgeInsets.all(4),
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(30)),
                                              child: SvgPicture.asset(
                                                  'assets/images/ic_shirt.svg',
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  permissionChecker();
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: AppColors.appColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        margin: const EdgeInsets.all(8),
                                        child: Image.asset(
                                            'assets/images/img3.png',
                                            fit: BoxFit.fill),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 8),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                                child: Text('Saved',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis)),
                                            Container(
                                              width: 55,
                                              height: 27,
                                              padding: const EdgeInsets.all(4),
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(30)),
                                              child: SvgPicture.asset(
                                                  'assets/images/ic_saved.svg',
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )),
              ],
            )),
      ),
    );
  }

  Future<bool?> showExitAppDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          padding: const EdgeInsets.all(10),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Exit Application',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              Text('Are you sure you want to exit this app?',
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Stay', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Leave', style: TextStyle(color: Colors.black)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void shareApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appID = packageInfo.packageName;
    String? appLink;

    if (Platform.isAndroid) {
      appLink = 'https://play.google.com/store/apps/details?id=$appID';
    } else if (Platform.isIOS) {
      appLink =
          'https://apps.apple.com/us/app/id$appID'; // Ensure correct URL format for iOS
    }

    if (appLink != null) {
      Share.share('Check out this amazing app! Download it here: $appLink');
    }
  }
  Future<void> permissionChecker() async{
    bool status;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request().isGranted;
      } else {
        status = await Permission.photos.request().isGranted;
      }
    } else if (Platform.isIOS) {
      status = await Permission.photosAddOnly.request().isGranted;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported platform!'))
      );
      return;
    }

    if (status) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }
}
