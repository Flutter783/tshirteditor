import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum FetchDownloadStatus {
  init,
  fetching,
  success,
  error,
}


class DownloadProvider with ChangeNotifier {

  FetchDownloadStatus _fetchStatus = FetchDownloadStatus.init;
  FetchDownloadStatus get fetchStatus => _fetchStatus;

  List<File> _downloadedFiles = [];
  List<File> get downloadedFiles => _downloadedFiles;

  void notify() {
    notifyListeners();
  }

  Future<void> loadDownloadedFiles() async {
    try {
      _fetchStatus = FetchDownloadStatus.fetching;
      notify();


      bool status = await requestStoragePermission();
      if (status) {
        final directory = await getStorageDirectory();
        if (directory != null) {
          final folderPath = '${directory.path}/T-Shirt Editor';
          final newFiles = Directory(folderPath).listSync().whereType<File>().toList();
          if(newFiles.isEmpty){
            _downloadedFiles = [];
          }else{
            _downloadedFiles = newFiles;
          }

          _fetchStatus = FetchDownloadStatus.success;
        } else {
          _downloadedFiles = [];
          _fetchStatus = FetchDownloadStatus.success;
        }
      } else {
        _downloadedFiles = [];
        _fetchStatus = FetchDownloadStatus.error;
      }
      notify();
    } catch (e) {
      _downloadedFiles = [];
      _fetchStatus = FetchDownloadStatus.success;
      notify();
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return deviceInfo.version.sdkInt <= 32
          ? Permission.storage.request().isGranted
          : Permission.photos.request().isGranted;
    } else if (Platform.isIOS) {
      return Permission.storage.request().isGranted;
    }
    return false;
  }


  Future<Directory?> getStorageDirectory() {
    return Platform.isIOS ? getApplicationDocumentsDirectory() : getExternalStorageDirectory();
  }
}
