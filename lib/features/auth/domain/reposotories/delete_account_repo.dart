import 'dart:convert';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

Future<void> deleteAccountApi(String bearerToken) async {
  final url = Uri.parse('${AppConstants.baseUrl}/api/v1/remove-account');

  // Set the headers with the Bearer token
  final headers = {
    'Authorization': 'Bearer $bearerToken',
    // 'Content-Type': 'application/json',
  };

  // Send the DELETE request
  final response = await http.delete(url, headers: headers);

  // Check if the request was successful
  if (response.statusCode == 200) {
    print('Account successfully deleted');
  } else {
    print('Failed to delete account. Status code: ${response.statusCode}');
    print('Response: ${response.body}');
  }
}
