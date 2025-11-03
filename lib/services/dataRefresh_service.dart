import 'package:flutter/foundation.dart';

class DataRefreshService extends ChangeNotifier {
  static final DataRefreshService _instance = DataRefreshService._internal();
  factory DataRefreshService() => _instance;
  DataRefreshService._internal();

  void notifyDataUpdated() {
    notifyListeners();
  }
}
