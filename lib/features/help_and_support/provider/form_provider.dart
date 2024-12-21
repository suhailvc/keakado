import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/help_and_support/domain/reposotories/form_api.dart';

class ContactFormProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.sendContactMessage(
        name: name,
        email: email,
        phone: phone,
        message: message,
      );

      if (response.statusCode == 200) {
        // Handle success
        print("Message sent successfully: ${response.body}");
      } else {
        // Handle error
        print("Failed to send message: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
