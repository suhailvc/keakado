import 'dart:convert';
import 'package:flutter_grocery/features/order/screens/oder_return_screen.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

Future<void> returnProductApi(
    String orderId, List<Map<String, dynamic>> products, String token) async {
  final String url = '${AppConstants.baseUrl}/api/v1/customer/order/return';
  print('order id : $orderId');
  print('products : $products');
  Dio dio = Dio();
  dio.options.headers["Authorization"] = "Bearer $token";

  try {
    // Preparing form data

    FormData formData = FormData.fromMap({
      "order_id": orderId,
      "products": jsonEncode(products), // Convert the list to a JSON string
    });
    // Sending POST request
    Response response = await dio.post(url, data: formData);

    // Handle response
    if (response.statusCode == 200) {
      print("Order returned successfully: ${response.data}");
    } else {
      print("Failed to return order: ${response.data}");
    }
  } on DioError catch (e) {
    print("Error occurred: ${e.response?.data}");
  }
}


// Future<void> returnProductApi(String orderId,
//     List<Map<String, String>> products, String bearerToken) async {
//   final url = Uri.parse('${AppConstants.baseUrl}/api/v1/customer/order/return');

//   final headers = {
//     'Authorization': 'Bearer $bearerToken',
//     //'Content-Type': 'application/x-www-form-urlencoded',
//   };

//   final body = {
//     'order_id': orderId,
//     'products': jsonEncode(products),
//   };

//   try {
//     final response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );

//     if (response.statusCode == 200) {
//       // Success response handling
//       print('Product return successful: ${response.body}');
//     } else {
//       // Error response handling
//       print('Failed to return product: ${response.body}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
