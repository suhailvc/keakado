import 'dart:convert';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

Future<ProductModel?> fetchRelatedProductService(String? token) async {
  final url = Uri.parse(
      '${AppConstants.baseUrl}/api/v1/products/related-products-cart');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProductModel.fromJson(data);
    } else {
      print('Failed to load product data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
