import 'dart:convert';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<String> returnStatusService() async {
  try {
    final response = await http.get(
      Uri.parse(
          '${AppConstants.baseUrl}/api/v1/customer/order/get-return-status'),
      // headers: {
      //   'Accept': 'application/json',
      //   // Add any other required headers here
      // },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'].toString();
    } else {
      throw Exception(
          'Failed to load return status. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error in returnStatusService: $e');
    throw Exception('Failed to load return status');
  }
}