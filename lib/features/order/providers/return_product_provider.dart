import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/order_return_repo.dart';
import 'package:flutter_grocery/features/order/screens/oder_return_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class OrderReturnProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _responseMessage;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get responseMessage => _responseMessage;
  void removeImage(int index) {
    if (returnImagess.length > index) {
      returnImagess[index].clear();
      returnImages[index].clear();
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source, int index) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        // Clear existing images before adding new one
        returnImagess[index].clear();
        returnImages[index].clear();

        final file = File(pickedFile.path);
        final compressedFile = await compressImage(file);

        returnImagess[index].add(compressedFile);

        final bytes = await compressedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        returnImages[index].add(base64String);

        notifyListeners();
      }
    } catch (e) {
      _responseMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  // Future<void> pickImage(ImageSource source, int index) async {
  //   final picker = ImagePicker();
  //   try {
  //     final XFile? pickedFile = await picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       // Convert XFile to File
  //       final file = File(pickedFile.path);

  //       // Compress the image before processing
  //       final compressedFile = await compressImage(file);

  //       // Ensure the returnImagess list exists at the index
  //       returnImagess[index] ??= [];
  //       returnImagess[index].add(compressedFile);

  //       // Convert the image file to a Base64 string
  //       final bytes = await compressedFile.readAsBytes();
  //       final base64String = base64Encode(bytes);

  //       // Ensure the returnImages list exists at the index
  //       returnImages[index] ??= [];
  //       returnImages[index].add(base64String);

  //       print("---------Base64 Encoded Image: $base64String");
  //       print("Base64 length: ${base64String.length}");

  //       notifyListeners();
  //     } else {
  //       _responseMessage = 'No image selected.';
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     _responseMessage = 'Failed to pick image: $e';
  //     notifyListeners();
  //   }
  // }

// Compress the image
  Future<File> compressImage(File file) async {
    final filePath = file.absolute.path;
    final targetPath =
        "${filePath.substring(0, filePath.lastIndexOf('.'))}_compressed.jpg";

    // Compress the image
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 85, // Adjust quality as needed
    );

    // If the result is not null, convert it to File and return
    if (result != null) {
      return File(result.path); // Convert XFile to File
    } else {
      return file; // Return the original file if compression fails
    }
  }

  // Future<void> pickImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   try {
  //     final pickedFile = await picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       _selectedImage = File(pickedFile.path);
  //       notifyListeners();
  //     }
  //   } catch (error) {
  //     _responseMessage = 'Failed to pick image: $error';
  //     notifyListeners();
  //   }
  // }

  // void removeImage() {
  //   _selectedImage = null;
  //   notifyListeners();
  // }

  Future<void> returnProducts(String orderId,
      List<Map<String, String>> products, String bearerToken) async {
    _isLoading = true;
    _responseMessage = null;
    notifyListeners();

    try {
      await returnProductApi(orderId, products, bearerToken);
      _responseMessage = 'Product return successful';
    } catch (error) {
      _responseMessage = 'Failed to return product: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
