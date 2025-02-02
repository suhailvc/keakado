import 'dart:convert';
import 'package:flutter_grocery/features/checkout/domain/models/express_delivery_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

Future<DeliveryChargeResponse> expressDeliveryChargeApi(
    {required String zone, required bool isExpress}) async {
  try {
    print('------------zone $zone');
    final Uri url = Uri.parse(
        '${AppConstants.baseUrl}/api/v1/check-express-delivery?zone=$zone&is_express=1');
    //         .replace(queryParameters: {
    //   'zone': zone,
    //   'is_express': isExpress ? '1' : '0',
    // });

    final response = await http.get(url);
    print('------------response code ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'success') {
        print('----------ex deliver charge api ${data['delivery_charge']}');
        return DeliveryChargeResponse(
            deliveryCharge: double.parse(data['delivery_charge']),
            status: data['status']);
      } else {
        return DeliveryChargeResponse(
            deliveryCharge: double.parse(data['delivery_charge']),
            status: 'failed');
      }
    } else {
      throw Exception('Failed to load delivery charge');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
