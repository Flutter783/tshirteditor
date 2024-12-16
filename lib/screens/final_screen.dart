import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import '../services/ad_Server.dart';
import '../services/bannerAd.dart';
import 'home_screen.dart';

class FinalScreen extends StatefulWidget {
  final Uint8List shirtBytes;
  const FinalScreen({super.key, required this.shirtBytes});

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: 30)),
                  const Text('Share / Save Design',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            AdsServer().isInternetConnected
                ? BannerAdWidget(
                width: MediaQuery.of(context).size.width, maxHeight: 100)
                : Container(),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.memory(widget.shirtBytes),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    shareDesign();
                  },
                  child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(top: 20, bottom: 30),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Share',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    permissionChecker();
                  },
                  child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(top: 20, bottom: 30),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_alt_rounded,
                              size: 20, color: Colors.white),
                          SizedBox(width: 5),
                          Text('Download',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  Future<void> permissionChecker() async {
    bool status = false;

    try {
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt <= 32) {
          status = await Permission.storage.request().isGranted;
        } else {
          status = await Permission.photos.request().isGranted;
        }
      } else if (Platform.isIOS) {
        PermissionStatus permissionStatus = await Permission.photos.status;
        print("Initial Photos permission status: $permissionStatus");

        if (permissionStatus.isDenied) {
          print("Requesting Photos permission...");
          status = await Permission.photos.request().isGranted;
          print("Photos permission granted: $status");
        } else if (permissionStatus.isPermanentlyDenied) {
          // If permanently denied, show dialog and open settings
          print("Photos permission is permanently denied.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable photo permissions in settings to download images.'),
            ),
          );
          await openAppSettings();
          return;
        } else {
          status = permissionStatus.isGranted;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported platform!')),
        );
        return;
      }

      if (status) {
        // Set storage directory based on platform
        final directory = Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getExternalStorageDirectory();

        if (directory == null) {
          throw Exception("Could not find a valid storage directory.");
        }

        final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final folderPath = '${directory.path}/T-Shirt Editor';
        final newFolder = Directory(folderPath);
        if (!await newFolder.exists()) {
          await newFolder.create(recursive: true);
        }

        final path = '$folderPath/image_$formattedDate.png';
        final file = File(path);
        await file.writeAsBytes(widget.shirtBytes);

        // Save image to gallery using PhotoManager
        final assetEntity = await PhotoManager.editor.saveImageWithPath(file.path, title: 'T-Shirt Design');
        if (assetEntity != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          Navigator.pop(context);
          throw Exception('Failed to save image to gallery');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print("Permission or saving error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> shareDesign() async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/shirt_designed_image.png';
    final file = File(path);
    await file.writeAsBytes(widget.shirtBytes);
    final xFile = XFile(path);
    Share.shareXFiles([xFile], text: 'Here is my design!');
  }
}
