import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

enum FetchLogoStatus {
  init,
  fetching,
  success,
  error,
}


class LogoProvider with ChangeNotifier {

  FetchLogoStatus _fetchStatus = FetchLogoStatus.init;
  FetchLogoStatus get fetchStatus => _fetchStatus;

  List<LogoModel> _logoModel = [];
  List<LogoModel> get logoModel => _logoModel;

  void notify() {
    notifyListeners();
  }

  Future<void> fetchLogo() async {
    try {
      _fetchStatus = FetchLogoStatus.fetching;
      notify();

      final response = await http
          .get(Uri.parse('https://thecodetrinity.com/apps/TShirtEditor/stickers.php'));
      if (response.statusCode == 200) {
        final List<dynamic> logos = jsonDecode(response.body)['logos'];
        _logoModel = logos.map((map) {return LogoModel.fromJson(map);}).toList();
        _fetchStatus = FetchLogoStatus.success;
      } else {
        _fetchStatus = FetchLogoStatus.error;
      }
      notify();
    } catch (e) {
      _fetchStatus = FetchLogoStatus.error;
      notify();
    }
  }
}

class LogoModel{
  final String logoId;
  final String logoImage;

  LogoModel({required this.logoId, required this.logoImage});

  factory LogoModel.fromJson(Map<String, dynamic> json) {
    return LogoModel(
      logoId:  json['logoId'],
      logoImage: json['logoImage'],
    );
  }
}