// class NotificationHelper {
//   static Future<void> initialize(
//       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//     var androidInitialize =
//         const AndroidInitializationSettings('notification_icon');
//     var iOSInitialize = const DarwinInitializationSettings();
//     var initializationsSettings =
//         InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
//     flutterLocalNotificationsPlugin.initialize(
//       initializationsSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) async {
//         int? orderId;
//         String? type = 'general';
//         if (notificationResponse.payload!.isNotEmpty) {
//           orderId = int.tryParse(
//               jsonDecode(notificationResponse.payload!)['order_id']);
//           type = jsonDecode(notificationResponse.payload!)['type'];
//         }
//         try {
//           if (orderId != null) {
//             Get.navigator!.push(
//               MaterialPageRoute(
//                   builder: (context) =>
//                       OrderDetailsScreen(orderModel: null, orderId: orderId)),
//             );
//           } else if (orderId == null && type == 'message') {
//             Get.navigator!.push(
//               MaterialPageRoute(
//                   builder: (context) => const ChatScreen(
//                         orderModel: null,
//                         isAppBar: true,
//                       )),
//             );
//           } else if (type == 'wallet') {
//             Get.navigator!.push(
//               MaterialPageRoute(
//                   builder: (context) => const WalletScreen(status: '')),
//             );
//           } else if (type == 'general') {
//             Get.navigator!.push(
//               MaterialPageRoute(
//                   builder: (context) => const NotificationScreen()),
//             );
//           }
//         } catch (e) {
//           return;
//         }
//         return;
//       },
//     );

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print(
//             "onMessage: ${message.notification?.title}/${message.notification?.body}");
//       }
//       showNotification(message, flutterLocalNotificationsPlugin, kIsWeb);
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print(
//             "onOpenApp: ${message.notification?.title}/${message.notification?.body}");
//       }
//       // Handle navigation directly instead of showing notification
//       handleNotificationNavigation(message);
//     });
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         handleNotificationNavigation(message);
//       }
//     });
//   }

// //------------------------------------------------------------------------------------------------
//   static void handleNotificationNavigation(RemoteMessage message) {
//     try {
//       String? type = message.data['type'] ?? 'general';
//       String? orderId = message.data['order_id'];
//       bool? needRating = message.data['need_rating'] == 'true';

//       if (orderId != null /*&& orderId.isNotEmpty*/) {
//         //if (needRating) {
//         // Show rating dialog first
//         showRatingDialog(orderId);
//         //   handleRatingNavigation(orderId);
//         // } //else {
//         // Navigate to order details
//         // Get.navigator!.push(
//         //   MaterialPageRoute(
//         //     builder: (context) => OrderDetailsScreen(
//         //         orderModel: null, orderId: int.parse(orderId)),
//         //   ),
//         // );
//         //}
//       } else if (type == 'message') {
//         Get.navigator!.push(
//           MaterialPageRoute(
//             builder: (context) => const ChatScreen(
//               orderModel: null,
//               isAppBar: true,
//             ),
//           ),
//         );
//       } else if (type == 'wallet') {
//         Get.navigator!.push(
//           MaterialPageRoute(
//             builder: (context) => const WalletScreen(status: ''),
//           ),
//         );
//       } else if (type == 'general') {
//         Get.navigator!.push(
//           MaterialPageRoute(
//             builder: (context) => const NotificationScreen(),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error in navigation: $e');
//     }
//   }

//   static void showRatingDialog(String orderId) {
//     int selectedStars = 5;
//     String feedback = '';
//     final TextEditingController feedbackController = TextEditingController();

//     showDialog(
//       context: Get.context!,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         final Size size = MediaQuery.of(context).size;

//         return StatefulBuilder(builder: (context, setState) {
//           return WillPopScope(
//             onWillPop: () async => false,
//             child: Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: SingleChildScrollView(
//                 child: Container(
//                   width: size.width * 0.9, // 90% of screen width
//                   padding: EdgeInsets.all(size.width * 0.05), // 5% padding
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         getTranslated('rate your order', context),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: size.height * 0.02),
//                       Container(
//                         height: size.height * 0.08, // Fixed height for stars
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(5, (index) {
//                             return IconButton(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.01,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   selectedStars = index + 1;
//                                 });
//                               },
//                               icon: Icon(
//                                 index < selectedStars
//                                     ? Icons.star
//                                     : Icons.star_border,
//                                 color: Colors.amber,
//                                 size: size.width * 0.08, // 8% of screen width
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.02),
//                       Container(
//                         constraints: BoxConstraints(
//                           maxHeight: size.height * 0.15, // 15% of screen height
//                         ),
//                         child: TextField(
//                           controller: feedbackController,
//                           maxLines: null,
//                           decoration: InputDecoration(
//                             hintText:
//                                 getTranslated('share your feedback', context),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context)
//                                     .primaryColor
//                                     .withOpacity(0.3),
//                               ),
//                             ),
//                             contentPadding: EdgeInsets.all(size.width * 0.03),
//                           ),
//                           onChanged: (value) {
//                             feedback = value;
//                           },
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.02),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Text(
//                               getTranslated('skip', context),
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               final String token = Provider.of<AuthProvider>(
//                                       context,
//                                       listen: false)
//                                   .getUserToken();

//                               Provider.of<RatingProvider>(context,
//                                       listen: false)
//                                   .submitReview(
//                                 orderId: int.parse(orderId),
//                                 rating: selectedStars,
//                                 comment: feedback,
//                                 bearerToken: token,
//                               )
//                                   .then((_) {
//                                 Navigator.pop(context);
//                                 showCustomSnackBarHelper(
//                                   getTranslated(
//                                       'review submitted successfully', context),
//                                   isError: false,
//                                 );
//                                 //  Navigator.pop(context);
//                                 Get.navigator!.push(
//                                   MaterialPageRoute(
//                                     builder: (context) => OrderDetailsScreen(
//                                         orderModel: null,
//                                         orderId: int.parse(orderId)),
//                                   ),
//                                 );
//                               }).catchError((error) {
//                                 showCustomSnackBarHelper(
//                                   getTranslated(
//                                       'review submission failed', context),
//                                   isError: true,
//                                 );
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.04,
//                                 vertical: size.height * 0.01,
//                               ),
//                             ),
//                             child: Text(
//                               getTranslated('submit', context),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   static Future<void> showNotification(RemoteMessage message,
//       FlutterLocalNotificationsPlugin? fln, bool data) async {
//     String? title;
//     String? body;
//     String? orderID;
//     String? image;
//     String? type;

//     // Handle both foreground and background messages
//     if (message.notification != null) {
//       // When app is in background
//       title = message.notification!.title;
//       body = message.notification!.body;
//       orderID = message.notification!.titleLocKey;
//     } else {
//       // When app is in foreground
//       title = message.data['title'];
//       body = message.data['body'];
//       orderID = message.data['order_id'];
//     }

//     // Handle image consistently for both background and foreground
//     if (message.data['image'] != null) {
//       image = message.data['image'];
//     } else if (message.notification?.android?.imageUrl != null) {
//       image = message.notification?.android?.imageUrl;
//     }

//     // Standardize image URL processing
//     if (image != null && image.isNotEmpty) {
//       if (!image.startsWith('http')) {
//         image =
//             '${AppConstants.baseUrl}/storage/app/public/notification/$image';
//       }
//     }

//     type = message.data['type'];

//     if (kDebugMode) {
//       print('Notification Image URL: $image');
//       print('Notification Data: ${message.data}');
//       print('Notification Content: ${message.notification?.toMap()}');
//     }

//     Map<String, String> payloadData = {
//       'title': '$title',
//       'body': '$body',
//       'order_id': '$orderID',
//       'image': '$image',
//       'type': '$type',
//     };

//     if (kIsWeb) {
//       showDialog(
//           context: Get.context!,
//           builder: (context) => Center(
//                 child: NotificationDialogWebWidget(
//                   orderId: int.tryParse(orderID ?? ''),
//                   title: title,
//                   body: body,
//                   image: image,
//                   type: type,
//                 ),
//               ));
//     } else if (image != null && image.isNotEmpty) {
//       try {
//         await showBigPictureNotificationHiddenLargeIcon(payloadData, fln!);
//       } catch (e) {
//         if (kDebugMode) {
//           print('Error showing image notification: $e');
//         }
//         await showBigTextNotification(payloadData, fln!);
//       }
//     } else {
//       await showBigTextNotification(payloadData, fln!);
//     }
//   }

//   static Future<void> showBigTextNotification(
//       Map<String, String> data, FlutterLocalNotificationsPlugin fln) async {
//     BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
//       data['body']!,
//       htmlFormatBigText: true,
//       contentTitle: data['title'],
//       htmlFormatContentTitle: true,
//     );
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       AppConstants.appName,
//       AppConstants.appName,
//       importance: Importance.max,
//       styleInformation: bigTextStyleInformation,
//       priority: Priority.max,
//       playSound: true,
//       sound: const RawResourceAndroidNotificationSound('notification'),
//     );
//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, data['title'], data['body'], platformChannelSpecifics,
//         payload: jsonEncode(data));
//   }

//   static Future<void> showBigPictureNotificationHiddenLargeIcon(
//     Map<String, String> data,
//     FlutterLocalNotificationsPlugin fln,
//   ) async {
//     final String largeIconPath =
//         await _downloadAndSaveFile(data['image']!, 'largeIcon');
//     final String bigPicturePath =
//         await _downloadAndSaveFile(data['image']!, 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath),
//       hideExpandedLargeIcon: true,
//       contentTitle: data['title'],
//       htmlFormatContentTitle: true,
//       summaryText: data['body'],
//       htmlFormatSummaryText: true,
//     );
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       AppConstants.appName,
//       AppConstants.appName,
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//       priority: Priority.max,
//       playSound: true,
//       styleInformation: bigPictureStyleInformation,
//       importance: Importance.max,
//       sound: const RawResourceAndroidNotificationSound('notification'),
//     );
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, data['title'], data['body'], platformChannelSpecifics,
//         payload: jsonEncode(data));
//   }

//   static Future<String> _downloadAndSaveFile(
//       String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final Response response = await Dio()
//         .get(url, options: Options(responseType: ResponseType.bytes));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.data);
//     return filePath;
//   }
// }

// Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
//   if (kDebugMode) {
//     print(
//         "onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
//   }
// }
