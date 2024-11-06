import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

enum FetchDesignStatus {
  init,
  fetching,
  success,
  error,
}


class DesignProvider with ChangeNotifier {

  FetchDesignStatus _fetchStatus = FetchDesignStatus.init;
  FetchDesignStatus get fetchStatus => _fetchStatus;

  List<DesignModel> _designModel = [];
  List<DesignModel> get designModel => _designModel;

  void notify() {
    notifyListeners();
  }

  Future<void> fetchDesignList() async {
    try {
      _fetchStatus = FetchDesignStatus.fetching;
      notify();

      final response = await http
          .get(Uri.parse('https://thecodetrinity.com/apps/TShirtEditor/designs.php'));
      if (response.statusCode == 200) {
        final List<dynamic> designList = jsonDecode(response.body)['designList'];
        _designModel = designList.map((map) {
          return DesignModel.fromJson(map);
        }).toList();
        _fetchStatus = FetchDesignStatus.success;
      } else {
        _fetchStatus = FetchDesignStatus.error;
      }
      notify();
    } catch (e) {
      _fetchStatus = FetchDesignStatus.error;
      notify();
    }
  }
}

class DesignModel{
  final String designId;
  final String designImage;

  DesignModel({required this.designId, required this.designImage});

  factory DesignModel.fromJson(Map<String, dynamic> json) {
    return DesignModel(
      designId:  json['designId'],
      designImage: json['designImage'],
    );
  }
}