import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/checkout/domain/models/api_response.dart';
import 'package:flutter_grocery/features/checkout/domain/repo/exprees_delivery_status.dart';

class ExpressDeliveryProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _status;
  String? _message;

  bool get isLoading => _isLoading;
  String? get status => _status;
  String? get message => _message;

  Future<void> expressDeliveryStatus() async {
    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await OrderRepo().expressDeliveryStatus();

    if (apiResponse.response != null) {
      var responseData = apiResponse.response;
      _status = responseData['status']?.toString();
      _message = responseData['message'];
      print('---------------stauts $_status');
    } else {
      print('---------------stauts $_status');
      _status = null;
      _message = apiResponse.error ?? "Failed to fetch delivery status.";
    }

    _isLoading = false;
    notifyListeners();
  }
}
