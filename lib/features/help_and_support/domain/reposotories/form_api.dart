import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<http.Response> sendContactMessage({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/v1/contact-message?id=&name=$name&email=$email&phone=$phone&message=$message');

    final response = await http.post(url);

    return response;
  }
}
