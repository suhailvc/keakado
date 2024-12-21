import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/offer_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/features/offers/widget/api_service.dart';

class OfferProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  ProductModel? _offers;
  bool _isLoading = false;
  String? _errorMessage;

  ProductModel? get offers => _offers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOffers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOffers = await _apiService.offerApiService();
      _offers = fetchedOffers;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
