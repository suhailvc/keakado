import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

Future<bool> orderCancelService({
  required int orderId,
  required String reason,
  required String bearerToken,
}) async {
  print('order id $orderId');
  print('reson $reason');
  print(' token $bearerToken');
  final url = Uri.parse(
      '${AppConstants.baseUrl}/api/v1/customer/order/cancel-order?order_id=$orderId&reason=$reason');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        // 'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('true');
      print(response.body);
      // Successfully canceled the order
      return true;
    } else {
      print('false------------');
      // Handle the failure case
      return false;
    }
  } catch (e) {
    print(' catch $e');
    // Handle any network or other errors
    return false;
  }
}
