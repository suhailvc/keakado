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
//   Future<void> pickImage(ImageSource source, int index) async {
//     final picker = ImagePicker();
//     try {
//       final XFile? pickedFile = await picker.pickImage(source: source);
//       if (pickedFile != null) {
//         // Convert XFile to File
//         final file = File(pickedFile.path);

//         // Ensure the returnImagess list exists at the index
//         if (returnImagess[index] == null) {
//           returnImagess[index] = []; // Initialize the list if null
//         }

//         // Compress the image to be below 5 MB
//         File? compressedFile = await _compressImage(file);

//         // Ensure the returnImages list exists at the index
//         if (returnImages[index] == null) {
//           returnImages[index] = []; // Initialize the list if null
//         }

//         // Convert the compressed image file to a Base64 string
//         final bytes = await compressedFile.readAsBytes();
//         final base64String = base64Encode(bytes);

//         // Add the compressed file and Base64 string to the respective lists
//         returnImagess[index].add(compressedFile);
//         returnImages[index].add(base64String);

//         notifyListeners();
//       }
//     } catch (error) {
//       _responseMessage = 'Failed to pick image: $error';
//       notifyListeners();
//     }
//   }

// // Method to compress the image to be under 5 MB
//   Future<File> _compressImage(File file) async {
//     File tempImage = file;
//     int imageSizeInBytes = await tempImage.length();
//     int maxSizeInBytes = 5 * 1024 * 1024; // 5 MB in bytes

//     // Compress the image and check the size
//     while (imageSizeInBytes > maxSizeInBytes) {
//       tempImage = await _compressFile(tempImage);
//       imageSizeInBytes = await tempImage.length();
//     }

//     return tempImage;
//   }

// // Method to perform compression using flutter_image_compress
//   Future<File> _compressFile(File file) async {
//     final result = await FlutterImageCompress.compressWithFile(
//       file.path,
//       minWidth: 800,
//       minHeight: 800,
//       quality: 70, // Adjust the quality if necessary
//       rotate: 0,
//     );

//     // Save the compressed image to a temporary file
//     final tempDir = Directory.systemTemp;
//     final compressedImage = File('${tempDir.path}/compressed_image.jpg');
//     compressedImage.writeAsBytesSync(result!);

//     return compressedImage;
//   }
  Future<void> pickImage(ImageSource source, int index) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        // Convert XFile to File
        final file = File(pickedFile.path);

        // Ensure the returnImagess list exists at the index
        if (returnImagess[index] == null) {
          returnImagess[index] = []; // Initialize the list if null
        }

        // Add the file to returnImagess
        returnImagess[index].add(file);

        // Convert the image file to a Base64 string
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        if (returnImages[index] == null) {
          returnImages[index] = []; // Initialize the list if null
        }
        print("---------base64---$base64String");
        print("Base64 length: ${base64String.length}");
        returnImages[index].add(base64String);

        notifyListeners();
      }
    } catch (error) {
      _responseMessage = 'Failed to pick image: $error';
      notifyListeners();
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

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

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
