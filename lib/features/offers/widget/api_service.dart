import 'dart:convert';
import 'package:flutter_grocery/common/models/offer_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //static const String baseUrl = "http://tamweenfoods.com/api/v1";

  Future<ProductModel> offerApiService() async {
    final url = Uri.parse("${AppConstants.baseUrl}/api/v1/products/discounted");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('successs');
        final dynamic jsonData = json.decode(response.body);
        print(jsonData.map((data) => ProductModel.fromJson(data)).toList());
        return jsonData.map((data) => ProductModel.fromJson(data)).toList();
      } else {
        throw Exception(
            "Failed to load discounted products: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error occurred: $e");
    }
  }
}
