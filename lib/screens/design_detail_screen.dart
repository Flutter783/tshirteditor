import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tshirteditor/service/app_color.dart';
import 'package:http/http.dart' as http;
import 'package:tshirteditor/services/ad_Server.dart';
import '../sqf/sqf_database.dart';

class DesignDetailScreen extends StatefulWidget {
  final String designId;
  final String designLink;
  const DesignDetailScreen({super.key, required this.designLink, required this.designId});

  @override
  State<DesignDetailScreen> createState() => _DesignDetailScreenState();
}

class _DesignDetailScreenState extends State<DesignDetailScreen> {
  bool isFavourite = false;
  bool isAlreadyDownloaded = false;
  @override
  void initState() {
    super.initState();
    checkFavouriteDesign();
  }
  void checkFavouriteDesign() async {
    bool favStatus = await isFavouriteShirt(widget.designId);
    if (mounted) {
      setState(() {
        isFavourite = favStatus;
      });
    }
  }
  Future<bool> isFavouriteShirt(String id) async {
    bool isAvailable = await DatabaseHelper.instance.isAlreadyFavourite(id);
    return isAvailable;
  }
  Future<void> removeFromFavourite(String id) async {
    await DatabaseHelper.instance.removeFavourite(id);
  }
  Future<void> addToFavourite(String id, String image) async {
    bool exists = await DatabaseHelper.instance.isAlreadyFavourite(id);
    if (!exists) {
      await DatabaseHelper.instance.addToFavourite(
          {DatabaseHelper.shirtId: id, DatabaseHelper.shirtImage: image});
    }
  }
  final AdsServer adsServer = AdsServer();
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
                          adsServer.showInterstitialIfAvailable(true);
                          if (isFavourite) {
                            removeFromFavourite(widget.designId);
                            setState(() {
                              isFavourite=false;
                            });
                          } else {
                            addToFavourite(widget.designId, widget.designLink);
                            setState(() {
                              isFavourite=true;
                            });
                          }
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          margin: const EdgeInsets.only(top: 20, right: 20),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            isFavourite ? Icons.favorite : Icons.favorite_border,
                            size: 30,
                            color: isFavourite ? Colors.red : AppColors.appColor,
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
                          adsServer.showInterstitialIfAvailable(true);
                          if(isAlreadyDownloaded){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloaded')),
                            );
                          }else{
                            downloadDesign();
                          }

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
  Future<void> downloadDesign() async {
    bool status = false;

    try {
      // Request permissions based on platform and Android version
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
      }

      if (!status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
    } catch (e) {
      print("Error requesting permissions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permissions: $e')),
      );
      return;
    }

    // Show loading dialog
    showCustomLoadingDialog('Downloading...');

    try {
      // Download the image
      final response = await http.get(Uri.parse(widget.designLink));
      if (response.statusCode == 200) {
        final byteData = response.bodyBytes;

        // Set storage directory based on platform
        final directory = Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getExternalStorageDirectory();

        if (directory == null) {
          throw Exception("Could not find a valid storage directory.");
        }

        final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final folderPath = '${directory.path}/T-Shirt Designs';
        final newFolder = Directory(folderPath);
        if (!await newFolder.exists()) {
          await newFolder.create(recursive: true);
        }
        final path = '$folderPath/image_$formattedDate.png';
        final file = File(path);
        await file.writeAsBytes(byteData);

        // Save image to gallery using PhotoManager
        final assetEntity = await PhotoManager.editor
            .saveImageWithPath(file.path, title: 'T-Shirt Design');

        if (!mounted) return; // Check if widget is still in the tree
        Navigator.pop(context); // Close loading dialog

        if (assetEntity != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download successful!')),
          );
          setState(() {
            isAlreadyDownloaded = true;
          });
        } else {
          throw Exception('Failed to save image to gallery');
        }
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Ensure dialog is closed if an error occurs
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while downloading the image: $e')),
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
}
