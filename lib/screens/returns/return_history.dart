import 'package:flutter/material.dart';
import 'package:one_smart_shop/models/return.dart';

class ReturnsProvider with ChangeNotifier {
  List<Return> _returns = [];

  List<Return> get returns => _returns;

  Future<void> fetchReturns() async {
    // Fetch return data from your database or API
    // Example: _returns = await database.fetchReturns();

    // After fetching data, notify listeners
    notifyListeners();
  }

  void addReturn(Return returnItem) {
    _returns.add(returnItem);
    notifyListeners();
  }
}
