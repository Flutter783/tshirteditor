import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../services/ad_Server.dart';
import '../services/bannerAd.dart';

class MyWorkScreen extends StatefulWidget {
  final String shirtPath;
  final VoidCallback onDeleted;
  const MyWorkScreen({super.key, required this.shirtPath, required this.onDeleted});

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
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
                  const Text('Shirt Ideas',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(20),
                color: Colors.white,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(widget.shirtPath),fit: BoxFit.fill),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: (){
                          shareFile();
                        },
                        child: Card(
                        color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 20,right: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share,size: 20,color: Colors.black),
                                SizedBox(width: 5),
                                Text('Share',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: (){
                          deleteFile();
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 20,right: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.delete,size: 27,color: Colors.red,),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: AdsServer().isInternetConnected
                  ? BannerAdWidget(
                  width: MediaQuery.of(context).size.width, maxHeight: 60)
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
  void shareFile() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appID = packageInfo.packageName;
    String? appLink;
    if (Platform.isAndroid) {
      appLink = 'https://play.google.com/store/apps/details?id=$appID';
    } else if (Platform.isIOS) {
      appLink =
      'https://apps.apple.com/us/app/id$appID'; // Ensure correct URL format for iOS
    }

    final File file = File(widget.shirtPath);
    if (await file.exists()) {
      final xFile = XFile(widget.shirtPath);
      await Share.shareXFiles([xFile], text: 'Download this amazing app: $appLink');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File does not exist")),
      );
    }
  }
  void deleteFile() async {
    final bool confirmDelete = await showDeleteConfirmDialog();
    if (confirmDelete) {
      try {
        final file = File(widget.shirtPath);
        if (await file.exists()) {
          await file.delete();
          widget.onDeleted?.call();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File successfully deleted")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File already deleted")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete the file: $e")),
        );
      }
    }
  }
  Future<bool> showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this design? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}
