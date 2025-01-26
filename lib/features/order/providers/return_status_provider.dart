import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/return_status_api.dart';

class ReturnStatusProvider extends ChangeNotifier {
  String _status = '';
  bool _isLoading = false;
  String? _error;

  String get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getReturnStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _status = await returnStatusService();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error in provider: $e');
    }
  }
}