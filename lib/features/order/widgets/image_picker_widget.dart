import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/return_product_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:provider/provider.dart';

Future<void> showImagePickerOptions(BuildContext context, int index) async {
  final provider = Provider.of<OrderReturnProvider>(context, listen: false);

  try {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  await provider.pickImage(ImageSource.camera, index);
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.photo_library),
              //   title: const Text('Choose from Gallery'),
              //   onTap: () async {
              //     await provider.pickImage(ImageSource.gallery, index);
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  } catch (error) {
    log(error.toString());
  }
}
