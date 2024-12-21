import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  ProfileRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getAddressTypeList() async {
    try {
      List<String> addressTypeList = [
        'Select Address type',
        'Home',
        'Office',
        'Other',
      ];
      Response response = Response(
          requestOptions: RequestOptions(path: ''),
          data: addressTypeList,
          statusCode: 200);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getUserInfo() async {
    try {
      final response = await dioClient!.get(AppConstants.customerInfoUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<http.Response> updateProfile(UserInfoModel userInfoModel, String pass,
      File? file, String token) async {
    try {
      print('fname : ${userInfoModel.fName!}');
      print('lname : ${userInfoModel.lName!}');
      print('phone : ${userInfoModel.phone!}');
      print('photo : $file');

      // API endpoint
      final uri =
          Uri.parse("${AppConstants.baseUrl}/api/v1/customer/update-profile");

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add form fields
      request.fields['f_name'] = userInfoModel.fName!;
      request.fields['l_name'] = userInfoModel.lName!;
      request.fields['phone'] = userInfoModel.phone!;
      request.fields['password'] = pass;

      // Add the file if provided
      if (file != null) {
        print('Adding file to request...');
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Field name for the image
          file.path,
          //  contentType: MediaType('image', 'jpeg'), // Adjust based on your image type
        ));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile updated successfully.');
        return response;
      } else {
        print('Error response (${response.statusCode}): ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateProfile: $e');
      rethrow;
    }
  }

  // Future<http.Response> updateProfile(UserInfoModel userInfoModel, String pass,
  //     File? file, String token) async {
  //   try {
  //     print('fname : ${userInfoModel.fName!}');
  //     print('lname : ${userInfoModel.lName!}');
  //     print('phone : ${userInfoModel.phone!}');
  //     print('photo : $file');

  //     // API endpoint
  //     final uri =
  //         Uri.parse("${AppConstants.baseUrl}/api/v1/customer/update-profile");

  //     // Build the parameters
  //     Map<String, String> params;

  //     // Add the file as a Base64 string if provided
  //     if (file != null) {
  //       print('Converting file to Base64...');
  //       final bytes = file.readAsBytesSync();
  //       final base64Image = base64Encode(bytes);
  //       print("image : $base64Image");
  //       params = {
  //         'f_name': userInfoModel.fName!,
  //         'l_name': userInfoModel.lName!,
  //         'phone': userInfoModel.phone!,
  //         'password': pass,
  //         'image': base64Image
  //       };
  //       // params['image'] = base64Image; // Add image as a parameter
  //     } else {
  //       params = {
  //         'f_name': userInfoModel.fName!,
  //         'l_name': userInfoModel.lName!,
  //         'phone': userInfoModel.phone!,
  //         'password': pass,
  //       };
  //     }
  //     print('Params: $params');

  //     // Add headers
  //     Map<String, String> headers = {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json', // Send as JSON
  //     };

  //     // Send the request
  //     final response = await http.put(
  //       uri,
  //       headers: headers,
  //       body: jsonEncode(params), // Encode parameters as JSON
  //     );

  //     // Handle the response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print('Profile updated successfully.');
  //       return response;
  //     } else {
  //       print('Error response (${response.statusCode}): ${response.body}');
  //       throw Exception('Failed to update profile: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Exception in updateProfile: $e');
  //     rethrow;
  //   }
  // }
  // Future<http.StreamedResponse> updateProfile(UserInfoModel userInfoModel,
  //     String pass, File? file, PickedFile? data, String token) async {
  //   try {
  //     print('fname : ${userInfoModel.fName!}');
  //     print('lname : ${userInfoModel.lName!}');
  //     print('phone : ${userInfoModel.phone!}');
  //     // API endpoint
  //     final uri =
  //         Uri.parse("http://tamweenfoods.com/api/v1/customer/update-profile");

  //     // Create a multipart request
  //     http.MultipartRequest request = http.MultipartRequest('PUT', uri);

  //     // Add the Authorization header
  //     request.headers.addAll({
  //       'Authorization': 'Bearer $token',
  //     });

  //     // Add required form fields
  //     request.fields.addAll({
  //       'f_name': userInfoModel.fName!,
  //       'l_name': userInfoModel.lName!,
  //       'phone': userInfoModel.phone!,
  //       'password': pass,
  //     });

  //     // Add the file if provided
  //     if (file != null) {
  //       print('Adding file: ${file.path}');
  //       request.files.add(
  //         http.MultipartFile(
  //           'image',
  //           file.readAsBytes().asStream(),
  //           file.lengthSync(),
  //           filename: file.path.split('/').last,
  //         ),
  //       );
  //     }

  //     // Send the request
  //     http.StreamedResponse response = await request.send();

  //     // Handle the response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print('Profile updated successfully.');
  //       return response;
  //     } else {
  //       String responseBody = await response.stream.bytesToString();
  //       print('Error response (${response.statusCode}): $responseBody');
  //       throw Exception('Failed to update profile: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Exception in updateProfile: $e');
  //     rethrow;
  //   }
  // }

  // Future<http.StreamedResponse> updateProfile(UserInfoModel userInfoModel,
  //     String pass, File? file, PickedFile? data, String token) async {
  //   http.MultipartRequest request = http.MultipartRequest('PUT',
  //       Uri.parse('${AppConstants.baseUrl}${AppConstants.updateProfileUri}'));
  //   request.headers.addAll(<String, String>{'Authorization': 'Bearer $token'});
  //   if (file != null) {
  //     request.files.add(http.MultipartFile(
  //         'image', file.readAsBytes().asStream(), file.lengthSync(),
  //         filename: file.path.split('/').last));
  //   } else if (data != null) {
  //     Uint8List list = await data.readAsBytes();
  //     http.MultipartFile part = http.MultipartFile(
  //         'image', data.readAsBytes().asStream(), list.length,
  //         filename: data.path);
  //     request.files.add(part);
  //   }
  //   Map<String, String> fields = {};
  //   fields.addAll(<String, String>{
  //     '_method': 'put',
  //     'f_name': userInfoModel.fName!,
  //     'l_name': userInfoModel.lName!,
  //     'phone': userInfoModel.phone!,
  //     'password': pass
  //   });
  //   request.fields.addAll(fields);
  //   http.StreamedResponse response = await request.send();
  //   print("--------------update response$response");
  //   return response;
  // }
}
