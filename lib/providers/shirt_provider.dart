import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

enum FetchShirtStatus {
  init,
  fetching,
  success,
  error,
}


class ShirtProvider with ChangeNotifier {

  FetchShirtStatus _fetchStatus = FetchShirtStatus.init;
  FetchShirtStatus get fetchStatus => _fetchStatus;

  List<ShirtModel> _shirtModel = [];
  List<ShirtModel> get shirtModel => _shirtModel;

  void notify() {
    notifyListeners();
  }

  Future<void> fetchShirts() async {
    try {
      _fetchStatus = FetchShirtStatus.fetching;
      notify();

      final response = await http
          .get(Uri.parse('https://thecodetrinity.com/apps/TShirtEditor/shirts.php'));
      if (response.statusCode == 200) {
        final List<dynamic> designList = jsonDecode(response.body)['shirts'];
        _shirtModel = designList.map((map) {
          return ShirtModel.fromJson(map);
        }).toList();
        _fetchStatus = FetchShirtStatus.success;
      } else {
        _fetchStatus = FetchShirtStatus.error;
      }
      notify();
    } catch (e) {
      _fetchStatus = FetchShirtStatus.error;
      notify();
    }
  }
}

class ShirtModel{
  final String shirtId;
  final String shirtImage;

  ShirtModel({required this.shirtId, required this.shirtImage});

  factory ShirtModel.fromJson(Map<String, dynamic> json) {
    return ShirtModel(
      shirtId:  json['shirtId'],
      shirtImage: json['shirtImage'],
    );
  }
}