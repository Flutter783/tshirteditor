import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../service/app_color.dart';
import '../sqf/sqf_database.dart';
import 'package:http/http.dart' as http;

class FavouriteDetailScreen extends StatefulWidget {
  final String designId;
  final String designLink;
  final VoidCallback onRemove;
  const FavouriteDetailScreen({super.key, required this.designId, required this.designLink, required this.onRemove});

  @override
  State<FavouriteDetailScreen> createState() => _FavouriteDetailScreenState();
}

class _FavouriteDetailScreenState extends State<FavouriteDetailScreen> {
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
                elevation: 3,
                margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
                color: AppColors.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          removeFromFavourite();
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          margin: const EdgeInsets.only(top: 20, right: 20),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite,
                            size: 30,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.designLink,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: downloadProgress.progress),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          downloadDesign(widget.designLink);

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 15),
                          margin: const EdgeInsets.only(bottom: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: SvgPicture.asset('assets/images/ic_download.svg',color: AppColors.appColor)),
                              Text('Download',
                                  style: TextStyle(
                                      color: AppColors.appColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 50)
          ],
        ),
      ),
    );
  }
  Future<void> removeFromFavourite() async {
    await DatabaseHelper.instance.removeFavourite(widget.designId);
    widget.onRemove();
    Navigator.pop(context);
  }
  Future<void> shareDesign(String imageUri) async {
    showCustomLoadingDialog('Processing...');
    try {
      final response = await http.get(Uri.parse(imageUri));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final formattedDate =
        DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final path = '${directory.path}/image_$formattedDate.png';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        Navigator.pop(context);
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String appID = packageInfo.packageName;
        String? appLink;
        if (Platform.isAndroid) {
          appLink = 'https://play.google.com/store/apps/details?id=$appID';
        } else if (Platform.isIOS) {
          appLink =
          'https://apps.apple.com/us/app/id$appID';
        }
        final xFile = XFile(path);
        Share.shareXFiles([xFile],
            text: 'Download this app for more tattoo designs: $appLink');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed!: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while sharing the image: $e')),
      );
    }
  }
  void showCustomLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.appColor),
                  strokeWidth: 5.0,
                ),
                const SizedBox(width: 20),
                Text(message, style: const TextStyle(color: Colors.black)),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
  Future<void> downloadDesign(String imageUri) async {
    bool status = false;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request().isGranted;
      } else {
        status = await Permission.photos.request().isGranted;
      }
    } else if (Platform.isIOS) {
      status = await Permission.photosAddOnly.request().isGranted;
    }

    if (!status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }
    showCustomLoadingDialog('Downloading...');
    try {
      final response = await http.get(Uri.parse(imageUri));
      if (response.statusCode == 200) {
        final byteData = response.bodyBytes;
        final directory = Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getExternalStorageDirectory();
        final formattedDate =
        DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final folderPath = '${directory?.path}/T-Shirt Designs';
        final newFolder = Directory(folderPath);
        if (!await newFolder.exists()) {
          await newFolder.create(recursive: true);
        }
        final path = '$folderPath/image_$formattedDate.png';
        final file = File(path);
        await file.writeAsBytes(byteData);
        final assetEntity = await PhotoManager.editor
            .saveImageWithPath(file.path, title: 'T-Shirt Design');
        if (assetEntity != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download successful!')),
          );
        } else {
          throw Exception('Failed to save image to gallery');
        }
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while downloading the image: $e')),
      );
    }
  }
}
