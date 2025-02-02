import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;
// // Define the API service method

Future<void> ratingService({
  required int orderId,
  required int rating,
  required String comment,
  required String bearerToken,
}) async {
  print('----------orderid---$orderId');
  print('----------rating---$rating');
  // Example API call implementation
  final String url =
      '${AppConstants.baseUrl}/api/v1/customer/order/submit-review?order_id=$orderId&rating=$rating&comment=$comment';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $bearerToken',
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    // body: {
    //   'order_id': orderId.toString(),
    //   'rating': rating.toString(),
    //   'comment': comment,
    // },
  );

  if (response.statusCode == 200) {
    // Handle success
    print('Review submitted successfully');
  } else {
    print('rating error');
    throw Exception('Failed to submit review');
  }
}
