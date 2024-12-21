import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/features/checkout/domain/models/api_response.dart';
import 'package:flutter_grocery/utill/app_constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderRepo {
  Future<ApiResponse> expressDeliveryStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/v1/customer/order/express-delivery-status'),
        // headers: {'Content-Type': 'application/json'}, // Optional headers
      );

      if (response.statusCode == 200) {
        // Success: Wrap the response in ApiResponse
        return ApiResponse.withSuccess(jsonDecode(response.body));
      } else {
        // Error: Return ApiResponse with error message
        return ApiResponse.withError(
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      // Handle any exceptions and pass to ApiErrorHandler
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
