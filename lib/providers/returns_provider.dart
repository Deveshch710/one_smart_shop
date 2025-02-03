// returns_provider.dart
import 'package:flutter/foundation.dart';
import 'package:one_smart_shop/database/database_helper.dart';
import 'package:one_smart_shop/models/return.dart';

class ReturnsProvider with ChangeNotifier {
  List<Return> _returns = [];
  bool _isLoading = false;

  List<Return> get returns => _returns;
  bool get isLoading => _isLoading;

  Future<void> fetchReturns() async {
    _isLoading = true;
    notifyListeners();

    try {
      _returns = await DatabaseHelper.instance.getAllReturns();
    } catch (e) {
      print('Error fetching returns: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReturn(Return returnItem) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseHelper.instance.insertReturn(returnItem);
      await fetchReturns();
    } catch (e) {
      print('Error adding return: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
