// import 'package:flutter/material.dart';
// import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
// import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';

// import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
// import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';

// import 'package:flutter_grocery/features/order/domain/models/order_model.dart';

// import 'package:flutter_grocery/features/order/providers/order_provider.dart';
// import 'package:flutter_grocery/features/order/providers/return_product_provider.dart';
// import 'package:flutter_grocery/features/order/widgets/image_picker_widget.dart';
// import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
// import 'package:flutter_grocery/helper/date_converter_helper.dart';
// import 'package:flutter_grocery/localization/language_constraints.dart';
// import 'package:flutter_grocery/utill/color_resources.dart';

// import 'package:flutter_grocery/utill/dimensions.dart';
// import 'package:flutter_grocery/utill/images.dart';
// import 'package:flutter_grocery/utill/styles.dart';

// import 'package:provider/provider.dart';

// class OrderReturnScreen extends StatefulWidget {
//   final OrderModel? orderModel;
//   final int? orderId;
//   final String? phoneNumber;

//   const OrderReturnScreen({
//     Key? key,
//     required this.orderModel,
//     required this.orderId,
//     this.phoneNumber,
//   }) : super(key: key);

//   @override
//   State<OrderReturnScreen> createState() => _OrderReturnScreenState();
// }

// class _OrderReturnScreenState extends State<OrderReturnScreen> {
//   List<bool> selectedProducts = [];
//   List<OrderDetailsModel> filteredOrderDetails = [];

//   void _loadData(BuildContext context) async {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     await orderProvider.getOrderDetails(
//       orderID: widget.orderId.toString(),
//       phoneNumber: widget.phoneNumber,
//     );
// // Filter out products that are already returned
//     filteredOrderDetails = orderProvider.orderDetails!
//         .where((detail) => detail.isReturned != 1)
//         .toList();
//     // Initialize selection status for each product
//     setState(() {
//       selectedProducts =
//           List<bool>.filled(orderProvider.orderDetails?.length ?? 0, false);
//     });
//   }

//   double _calculateReturnTotal(OrderProvider orderProvider) {
//     double total = 0.0;
//     for (int i = 0; i < selectedProducts.length; i++) {
//       if (selectedProducts[i]) {
//         total += (orderProvider.orderDetails![i].price ?? 0) *
//             (orderProvider.orderDetails![i].quantity ?? 1);
//       }
//     }
//     return total;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadData(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     final currencySymbol = splashProvider.configModel?.currencySymbol ?? "";
//     final orderReturnProvider = Provider.of<OrderReturnProvider>(context);

//     return Scaffold(
//       backgroundColor: ColorResources.scaffoldGrey,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).cardColor,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//           child: const Icon(
//             Icons.chevron_left,
//             size: 30,
//           ),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Order Return',
//           style: TextStyle(
//             fontSize: Dimensions.fontSizeExtraLarge,
//             color: Theme.of(context).textTheme.bodyLarge!.color,
//           ),
//         ),
//       ),
//       body: Consumer<OrderProvider>(
//         builder: (context, orderProvider, _) {
//           return (orderProvider.orderDetails == null ||
//                   orderProvider.trackModel == null)
//               ? Center(
//                   child:
//                       CustomLoaderWidget(color: Theme.of(context).primaryColor),
//                 )
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       children: [
//                         // Product List with Selection Checkboxes
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16.0),
//                           child: Container(
//                               width: MediaQuery.of(context).size.width - 32,
//                               decoration: const BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(12),
//                                   topRight: Radius.circular(12),
//                                 ),
//                                 color: Colors.white,
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeDefault,
//                                 vertical: Dimensions.paddingSizeLarge,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: List.generate(
//                                   filteredOrderDetails.length,
//                                   (index) => Padding(
//                                     padding: EdgeInsets.only(
//                                         top: index == 0 ? 0 : 16.0),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: const Color(0xFFF9F9F9),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Checkbox(
//                                             value: selectedProducts[index],
//                                             onChanged: (bool? value) {
//                                               setState(() {
//                                                 selectedProducts[index] =
//                                                     value ?? false;
//                                               });
//                                             },
//                                           ),
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                                 Dimensions.radiusSizeTen),
//                                             child: CustomImageWidget(
//                                               placeholder: Images.placeHolder,
//                                               image:
//                                                   '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
//                                               height: 80,
//                                               width: 80,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "${filteredOrderDetails[index].productDetails?.name ?? ""}",
//                                                   style: TextStyle(
//                                                       fontSize: Dimensions
//                                                           .fontSizeLarge),
//                                                   maxLines: 2,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   "${filteredOrderDetails[index].price ?? ""} $currencySymbol",
//                                                   style: TextStyle(
//                                                     fontSize: Dimensions
//                                                         .fontSizeExtraLarge,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     showModalBottomSheet(
//                                                       isDismissible: true,
//                                                       context: context,
//                                                       isScrollControlled: true,
//                                                       shape:
//                                                           const RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.vertical(
//                                                                 top: Radius
//                                                                     .circular(
//                                                                         20)),
//                                                       ),
//                                                       builder: (context) {
//                                                         final provider = Provider
//                                                             .of<OrderReturnProvider>(
//                                                                 context);
//                                                         return Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                             left: 16.0,
//                                                             right: 16.0,
//                                                             top: 16.0,
//                                                             bottom:
//                                                                 MediaQuery.of(
//                                                                         context)
//                                                                     .viewInsets
//                                                                     .bottom,
//                                                           ),
//                                                           child: Column(
//                                                             mainAxisSize:
//                                                                 MainAxisSize
//                                                                     .min,
//                                                             children: [
//                                                               Text(
//                                                                 'Return Notes',
//                                                                 style:
//                                                                     poppinsSemiBold
//                                                                         .copyWith(
//                                                                   fontSize:
//                                                                       Dimensions
//                                                                           .fontSizeLarge,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               Container(
//                                                                 height: 150,
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         8.0),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                           .grey[
//                                                                       200],
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                 ),
//                                                                 child:
//                                                                     const TextField(
//                                                                   maxLines:
//                                                                       null,
//                                                                   expands: true,
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     hintText:
//                                                                         'Enter your return notes',
//                                                                     border:
//                                                                         InputBorder
//                                                                             .none,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               if (provider
//                                                                       .selectedImage !=
//                                                                   null)
//                                                                 Column(
//                                                                   children: [
//                                                                     Stack(
//                                                                       alignment:
//                                                                           Alignment
//                                                                               .topRight,
//                                                                       children: [
//                                                                         Image
//                                                                             .file(
//                                                                           provider
//                                                                               .selectedImage!,
//                                                                           height:
//                                                                               150,
//                                                                           width:
//                                                                               150,
//                                                                           fit: BoxFit
//                                                                               .cover,
//                                                                         ),
//                                                                         IconButton(
//                                                                           icon:
//                                                                               const Icon(
//                                                                             Icons.cancel,
//                                                                             color:
//                                                                                 Colors.red,
//                                                                           ),
//                                                                           onPressed:
//                                                                               () {
//                                                                             provider.removeImage();
//                                                                           },
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                     const SizedBox(
//                                                                         height:
//                                                                             16),
//                                                                   ],
//                                                                 ),
//                                                               ElevatedButton(
//                                                                 onPressed:
//                                                                     () async {
//                                                                   await showImagePickerOptions(
//                                                                       context);
//                                                                 },
//                                                                 style: ElevatedButton
//                                                                     .styleFrom(
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .blue,
//                                                                   padding: const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           16.0,
//                                                                       vertical:
//                                                                           12.0),
//                                                                   shape:
//                                                                       RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                   ),
//                                                                 ),
//                                                                 child:
//                                                                     const Text(
//                                                                   'Add Image',
//                                                                   style: TextStyle(
//                                                                       color: Colors
//                                                                           .white),
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               ElevatedButton(
//                                                                 onPressed: () {
//                                                                   Navigator.pop(
//                                                                       context);
//                                                                 },
//                                                                 style: ElevatedButton
//                                                                     .styleFrom(
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .green,
//                                                                   padding: const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           16.0,
//                                                                       vertical:
//                                                                           12.0),
//                                                                   shape:
//                                                                       RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                   ),
//                                                                 ),
//                                                                 child:
//                                                                     const Text(
//                                                                   'Save Notes',
//                                                                   style: TextStyle(
//                                                                       color: Colors
//                                                                           .white),
//                                                                 ),
//                                                               ),
//                                                               SizedBox(
//                                                                 height: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .height *
//                                                                     0.01,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         );
//                                                       },
//                                                     );
//                                                   },
//                                                   child: Text(
//                                                     'Return Notes',
//                                                     style: poppinsSemiBold
//                                                         .copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeDefault,
//                                                       color: Theme.of(context)
//                                                           .disabledColor
//                                                           .withOpacity(0.2),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Column(
//                                             children: [
//                                               IconButton(
//                                                 icon: const Icon(Icons.add),
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     if ((filteredOrderDetails[
//                                                                     index]
//                                                                 .quantity ??
//                                                             1) <
//                                                         (filteredOrderDetails[
//                                                                     index]
//                                                                 .quantity ??
//                                                             1)) {
//                                                       filteredOrderDetails[
//                                                                   index]
//                                                               .quantity =
//                                                           (filteredOrderDetails[
//                                                                           index]
//                                                                       .quantity ??
//                                                                   1) +
//                                                               1;
//                                                     }
//                                                   });
//                                                 },
//                                               ),
//                                               Text(
//                                                 "${filteredOrderDetails[index].quantity ?? 1}",
//                                                 style: TextStyle(
//                                                   fontSize:
//                                                       Dimensions.fontSizeLarge,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               IconButton(
//                                                 icon: const Icon(Icons.remove),
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     if ((filteredOrderDetails[
//                                                                     index]
//                                                                 .quantity ??
//                                                             1) >
//                                                         1) {
//                                                       filteredOrderDetails[
//                                                                   index]
//                                                               .quantity =
//                                                           (filteredOrderDetails[
//                                                                           index]
//                                                                       .quantity ??
//                                                                   1) -
//                                                               1;
//                                                     }
//                                                   });
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )

//                               // child: Column(
//                               //   crossAxisAlignment: CrossAxisAlignment.start,
//                               //   children: List.generate(
//                               //     filteredOrderDetails.length,
//                               //     (index) => Padding(
//                               //       padding: EdgeInsets.only(
//                               //           top: index == 0 ? 0 : 16.0),
//                               //       child: Container(
//                               //         decoration: BoxDecoration(
//                               //           borderRadius: BorderRadius.circular(12),
//                               //           color: const Color(0xFFF9F9F9),
//                               //         ),
//                               //         child: Row(
//                               //           children: [
//                               //             Checkbox(
//                               //               value: selectedProducts[index],
//                               //               onChanged: (bool? value) {
//                               //                 setState(() {
//                               //                   selectedProducts[index] =
//                               //                       value ?? false;
//                               //                 });
//                               //               },
//                               //             ),
//                               //             ClipRRect(
//                               //               borderRadius: BorderRadius.circular(
//                               //                   Dimensions.radiusSizeTen),
//                               //               child: CustomImageWidget(
//                               //                 placeholder: Images.placeHolder,
//                               //                 image:
//                               //                     '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
//                               //                 height: 80,
//                               //                 width: 80,
//                               //                 fit: BoxFit.cover,
//                               //               ),
//                               //             ),
//                               //             const SizedBox(width: 16),
//                               //             Expanded(
//                               //               child: Column(
//                               //                 crossAxisAlignment:
//                               //                     CrossAxisAlignment.start,
//                               //                 children: [
//                               //                   Text(
//                               //                     "${filteredOrderDetails[index].productDetails?.name ?? ""} x ${filteredOrderDetails[index].quantity ?? ""}",
//                               //                     style: TextStyle(
//                               //                         fontSize: Dimensions
//                               //                             .fontSizeLarge),
//                               //                     maxLines: 2,
//                               //                     overflow: TextOverflow.ellipsis,
//                               //                   ),
//                               //                   const SizedBox(height: 4),
//                               //                   GestureDetector(
//                               //                     onTap: () {
//                               //                       showModalBottomSheet(
//                               //                         isDismissible: true,
//                               //                         context: context,
//                               //                         isScrollControlled: true,
//                               //                         shape:
//                               //                             const RoundedRectangleBorder(
//                               //                           borderRadius:
//                               //                               BorderRadius.vertical(
//                               //                                   top: Radius
//                               //                                       .circular(
//                               //                                           20)),
//                               //                         ),
//                               //                         builder: (context) {
//                               //                           final provider = Provider
//                               //                               .of<OrderReturnProvider>(
//                               //                                   context);
//                               //                           return Padding(
//                               //                             padding:
//                               //                                 EdgeInsets.only(
//                               //                               left: 16.0,
//                               //                               right: 16.0,
//                               //                               top: 16.0,
//                               //                               bottom: MediaQuery.of(
//                               //                                       context)
//                               //                                   .viewInsets
//                               //                                   .bottom,
//                               //                             ),
//                               //                             child: Column(
//                               //                               mainAxisSize:
//                               //                                   MainAxisSize.min,
//                               //                               children: [
//                               //                                 Text(
//                               //                                   'Return Notes',
//                               //                                   style:
//                               //                                       poppinsSemiBold
//                               //                                           .copyWith(
//                               //                                     fontSize: Dimensions
//                               //                                         .fontSizeLarge,
//                               //                                   ),
//                               //                                 ),
//                               //                                 const SizedBox(
//                               //                                     height: 16),
//                               //                                 Container(
//                               //                                   height: 150,
//                               //                                   padding:
//                               //                                       const EdgeInsets
//                               //                                           .all(8.0),
//                               //                                   decoration:
//                               //                                       BoxDecoration(
//                               //                                     color: Colors
//                               //                                         .grey[200],
//                               //                                     borderRadius:
//                               //                                         BorderRadius
//                               //                                             .circular(
//                               //                                                 10),
//                               //                                   ),
//                               //                                   child:
//                               //                                       const TextField(
//                               //                                     maxLines: null,
//                               //                                     expands: true,
//                               //                                     decoration:
//                               //                                         InputDecoration(
//                               //                                       hintText:
//                               //                                           'Enter your return notes',
//                               //                                       border:
//                               //                                           InputBorder
//                               //                                               .none,
//                               //                                     ),
//                               //                                   ),
//                               //                                 ),
//                               //                                 const SizedBox(
//                               //                                     height: 16),
//                               //                                 if (provider
//                               //                                         .selectedImage !=
//                               //                                     null)
//                               //                                   Column(
//                               //                                     children: [
//                               //                                       Stack(
//                               //                                         alignment:
//                               //                                             Alignment
//                               //                                                 .topRight,
//                               //                                         children: [
//                               //                                           Image
//                               //                                               .file(
//                               //                                             provider
//                               //                                                 .selectedImage!,
//                               //                                             height:
//                               //                                                 150,
//                               //                                             width:
//                               //                                                 150,
//                               //                                             fit: BoxFit
//                               //                                                 .cover,
//                               //                                           ),
//                               //                                           IconButton(
//                               //                                             icon: const Icon(
//                               //                                                 Icons
//                               //                                                     .cancel,
//                               //                                                 color:
//                               //                                                     Colors.red),
//                               //                                             onPressed:
//                               //                                                 () {
//                               //                                               provider
//                               //                                                   .removeImage();
//                               //                                             },
//                               //                                           ),
//                               //                                         ],
//                               //                                       ),
//                               //                                       const SizedBox(
//                               //                                           height:
//                               //                                               16),
//                               //                                     ],
//                               //                                   ),
//                               //                                 ElevatedButton(
//                               //                                   onPressed:
//                               //                                       () async {
//                               //                                     await showImagePickerOptions(
//                               //                                         context);
//                               //                                   },
//                               //                                   style:
//                               //                                       ElevatedButton
//                               //                                           .styleFrom(
//                               //                                     backgroundColor:
//                               //                                         Colors.blue,
//                               //                                     padding: const EdgeInsets
//                               //                                         .symmetric(
//                               //                                         horizontal:
//                               //                                             16.0,
//                               //                                         vertical:
//                               //                                             12.0),
//                               //                                     shape:
//                               //                                         RoundedRectangleBorder(
//                               //                                       borderRadius:
//                               //                                           BorderRadius
//                               //                                               .circular(
//                               //                                                   10),
//                               //                                     ),
//                               //                                   ),
//                               //                                   child: const Text(
//                               //                                     'Add Image',
//                               //                                     style: TextStyle(
//                               //                                         color: Colors
//                               //                                             .white),
//                               //                                   ),
//                               //                                 ),
//                               //                                 const SizedBox(
//                               //                                     height: 16),
//                               //                                 ElevatedButton(
//                               //                                   onPressed: () {
//                               //                                     Navigator.pop(
//                               //                                         context);
//                               //                                   },
//                               //                                   style:
//                               //                                       ElevatedButton
//                               //                                           .styleFrom(
//                               //                                     backgroundColor:
//                               //                                         Colors
//                               //                                             .green,
//                               //                                     padding: const EdgeInsets
//                               //                                         .symmetric(
//                               //                                         horizontal:
//                               //                                             16.0,
//                               //                                         vertical:
//                               //                                             12.0),
//                               //                                     shape:
//                               //                                         RoundedRectangleBorder(
//                               //                                       borderRadius:
//                               //                                           BorderRadius
//                               //                                               .circular(
//                               //                                                   10),
//                               //                                     ),
//                               //                                   ),
//                               //                                   child: const Text(
//                               //                                     'Save Notes',
//                               //                                     style: TextStyle(
//                               //                                         color: Colors
//                               //                                             .white),
//                               //                                   ),
//                               //                                 ),
//                               //                                 SizedBox(
//                               //                                   height: MediaQuery.of(
//                               //                                               context)
//                               //                                           .size
//                               //                                           .height *
//                               //                                       0.01,
//                               //                                 ),
//                               //                               ],
//                               //                             ),
//                               //                           );
//                               //                         },
//                               //                       );
//                               //                     },
//                               //                     child: Text(
//                               //                       'Return Notes',
//                               //                       style:
//                               //                           poppinsSemiBold.copyWith(
//                               //                         fontSize: Dimensions
//                               //                             .fontSizeDefault,
//                               //                         color: Theme.of(context)
//                               //                             .disabledColor
//                               //                             .withOpacity(0.2),
//                               //                       ),
//                               //                     ),
//                               //                   ),
//                               //                   const SizedBox(height: 4),
//                               //                   Row(
//                               //                     children: [
//                               //                       Text(
//                               //                         "${filteredOrderDetails[index].price ?? ""} $currencySymbol",
//                               //                         style: TextStyle(
//                               //                           fontSize: Dimensions
//                               //                               .fontSizeExtraLarge,
//                               //                           fontWeight:
//                               //                               FontWeight.bold,
//                               //                         ),
//                               //                       ),
//                               //                     ],
//                               //                   ),
//                               //                 ],
//                               //               ),
//                               //             ),
//                               //           ],
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               ),
//                         ),
//                         // Order Details Section
//                         Container(
//                           margin:
//                               const EdgeInsets.only(top: 16.0, bottom: 16.0),
//                           padding: const EdgeInsets.all(
//                               Dimensions.paddingSizeDefault),
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(12)),
//                             color: Colors.white,
//                           ),
//                           child: Column(
//                             children: [
//                               orderSummaryTile(context, 'Order ID',
//                                   orderProvider.trackModel!.id.toString()),
//                               if (orderProvider.trackModel!.couponCode != null)
//                                 orderSummaryTile(
//                                     context,
//                                     'Promo Code',
//                                     orderProvider.trackModel!.couponCode
//                                         .toString()),
//                               if (orderProvider.trackModel!.createdAt != null)
//                                 orderSummaryTile(
//                                   context,
//                                   'Ordered At',
//                                   DateConverterHelper
//                                       .isoStringToOrderDetailsDateTime(
//                                           orderProvider.trackModel!.createdAt
//                                               .toString()),
//                                 ),
//                               if (orderProvider.trackModel!.deliveryDate !=
//                                   null)
//                                 orderSummaryTile(
//                                   context,
//                                   'Delivery Date',
//                                   DateConverterHelper
//                                       .isoStringToOrderDetailsDateTime(
//                                           orderProvider.trackModel!.deliveryDate
//                                               .toString()),
//                                 ),
//                               if (orderProvider.trackModel!.paymentMethod !=
//                                   null)
//                                 orderSummaryTile(
//                                   context,
//                                   'Payment Method',
//                                   getTranslated(
//                                       orderProvider.trackModel!.paymentMethod
//                                           .toString(),
//                                       context),
//                                 ),
//                               if (orderProvider.trackModel!.paymentStatus !=
//                                   null)
//                                 orderSummaryTile(
//                                   context,
//                                   'Payment Status',
//                                   getTranslated(
//                                       orderProvider.trackModel!.paymentStatus
//                                           .toString(),
//                                       context),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         // Total amount for selected return items
//                         // Padding(
//                         //   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                         //   child: Container(
//                         //     width: MediaQuery.of(context).size.width - 32,
//                         //     decoration: const BoxDecoration(
//                         //       borderRadius:
//                         //           BorderRadius.all(Radius.circular(12)),
//                         //       color: Colors.white,
//                         //     ),
//                         //     padding: const EdgeInsets.all(
//                         //         Dimensions.paddingSizeDefault),
//                         //     child: Column(
//                         //       children: [
//                         //         const Divider(),
//                         //         Padding(
//                         //           padding: const EdgeInsets.only(top: 8.0),
//                         //           child: Row(
//                         //             mainAxisAlignment:
//                         //                 MainAxisAlignment.spaceBetween,
//                         //             children: [
//                         //               Text(
//                         //                 'Return Total',
//                         //                 style: TextStyle(
//                         //                     fontSize:
//                         //                         Dimensions.fontSizeExtraLarge,
//                         //                     fontWeight: FontWeight.bold),
//                         //               ),
//                         //               Text(
//                         //                 "${_calculateReturnTotal(orderProvider).toStringAsFixed(2)} $currencySymbol",
//                         //                 style: TextStyle(
//                         //                     fontSize:
//                         //                         Dimensions.fontSizeExtraLarge,
//                         //                     fontWeight: FontWeight.bold),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ),
//                         // ),
//                         // Return Button
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           child: CustomButtonWidget(
//                             buttonText: 'Return',
//                             onPressed: orderReturnProvider.isLoading
//                                 ? null
//                                 : () async {
//                                     List<Map<String, String>>
//                                         selectedProductIds = [];
//                                     for (int i = 0;
//                                         i < selectedProducts.length;
//                                         i++) {
//                                       if (selectedProducts[i]) {
//                                         selectedProductIds.add({
//                                           'product_id': orderProvider
//                                               .orderDetails![i]
//                                               .productDetails!
//                                               .id
//                                               .toString()
//                                         });
//                                       }
//                                     }

//                                     if (selectedProductIds.isNotEmpty) {
//                                       await orderReturnProvider.returnProducts(
//                                         widget.orderId.toString(),
//                                         selectedProductIds,
//                                         'your_bearer_token_here',
//                                       );

//                                       if (orderReturnProvider.responseMessage !=
//                                           null) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content: Text(orderReturnProvider
//                                                   .responseMessage!)),
//                                         );
//                                         orderProvider.getOrderDetails(
//                                           orderID: widget.orderId.toString(),
//                                           phoneNumber: widget.phoneNumber,
//                                         );
//                                         Navigator.pop(context);
//                                       }
//                                     } else {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                             content: Text(
//                                                 "Please select at least one product to return.")),
//                                       );
//                                     }
//                                   },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//         },
//       ),
//     );
//   }

//   Widget orderSummaryTile(BuildContext context, String title, String data,
//       [bool isPrice = false, bool isRed = false]) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
//           Text(
//             data +
//                 (!isPrice
//                     ? ""
//                     : " ${Provider.of<SplashProvider>(context, listen: false).configModel?.currencySymbol ?? ""}"),
//             style: TextStyle(
//                 color: isRed ? Colors.red : null, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class OrderReturnScreen extends StatefulWidget {
// //   final OrderModel? orderModel;
// //   final int? orderId;
// //   final String? phoneNumber;

// //   const OrderReturnScreen({
// //     Key? key,
// //     required this.orderModel,
// //     required this.orderId,
// //     this.phoneNumber,
// //   }) : super(key: key);

// //   @override
// //   State<OrderReturnScreen> createState() => _OrderReturnScreenState();
// // }

// // class _OrderReturnScreenState extends State<OrderReturnScreen> {
// //   List<bool> selectedProducts = [];

// //   void _loadData(BuildContext context) async {
// //     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
// //     await orderProvider.getOrderDetails(
// //       orderID: widget.orderId.toString(),
// //       phoneNumber: widget.phoneNumber,
// //     );

// //     setState(() {
// //       selectedProducts =
// //           List<bool>.filled(orderProvider.orderDetails?.length ?? 0, false);
// //     });
// //   }

// //   double _calculateReturnTotal(OrderProvider orderProvider) {
// //     double total = 0.0;
// //     for (int i = 0; i < selectedProducts.length; i++) {
// //       if (selectedProducts[i]) {
// //         total += (orderProvider.orderDetails![i].price ?? 0) *
// //             (orderProvider.orderDetails![i].quantity ?? 1);
// //       }
// //     }
// //     return total;
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData(context);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
// //     final currencySymbol = splashProvider.configModel?.currencySymbol ?? "";
// //     final orderReturnProvider = Provider.of<OrderReturnProvider>(context);

// //     return Scaffold(
// //       backgroundColor: Colors.grey[200],
// //       appBar: AppBar(
// //         backgroundColor: Theme.of(context).cardColor,
// //         leading: GestureDetector(
// //           onTap: () => Navigator.of(context).pop(),
// //           child: const Icon(Icons.chevron_left, size: 30),
// //         ),
// //         centerTitle: true,
// //         title: Text(
// //           'Order Return',
// //           style: TextStyle(
// //             fontSize: Dimensions.fontSizeExtraLarge,
// //             color: Theme.of(context).textTheme.bodyLarge!.color,
// //           ),
// //         ),
// //       ),
// //       body: Consumer<OrderProvider>(
// //         builder: (context, orderProvider, _) {
// //           return (orderProvider.orderDetails == null ||
// //                   orderProvider.trackModel == null)
// //               ? Center(
// //                   child:
// //                       CustomLoaderWidget(color: Theme.of(context).primaryColor))
// //               : SingleChildScrollView(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Column(
// //                       children: [
// //                         // Product List with Selection Checkboxes
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 16.0),
// //                           child: Container(
// //                             width: MediaQuery.of(context).size.width - 32,
// //                             decoration: const BoxDecoration(
// //                               borderRadius: BorderRadius.only(
// //                                 topLeft: Radius.circular(12),
// //                                 topRight: Radius.circular(12),
// //                               ),
// //                               color: Colors.white,
// //                             ),
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: Dimensions.paddingSizeDefault,
// //                               vertical: Dimensions.paddingSizeLarge,
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: List.generate(
// //                                 orderProvider.orderDetails!.length,
// //                                 (index) => Padding(
// //                                   padding: EdgeInsets.only(
// //                                       top: index == 0 ? 0 : 16.0),
// //                                   child: Container(
// //                                     decoration: BoxDecoration(
// //                                       borderRadius: BorderRadius.circular(12),
// //                                       color: const Color(0xFFF9F9F9),
// //                                     ),
// //                                     child: Row(
// //                                       children: [
// //                                         Checkbox(
// //                                           value: selectedProducts[index],
// //                                           onChanged: (bool? value) {
// //                                             setState(() {
// //                                               selectedProducts[index] =
// //                                                   value ?? false;
// //                                             });
// //                                           },
// //                                         ),
// //                                         ClipRRect(
// //                                           borderRadius:
// //                                               BorderRadius.circular(10),
// //                                           child: CustomImageWidget(
// //                                             placeholder:
// //                                                 'assets/placeholder.png',
// //                                             image:
// //                                                 '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image![0]}',
// //                                             height: 80,
// //                                             width: 80,
// //                                             fit: BoxFit.cover,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 16),
// //                                         Expanded(
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                                 CrossAxisAlignment.start,
// //                                             children: [
// //                                               Text(
// //                                                 "${orderProvider.orderDetails![index].productDetails?.name ?? ""} x ${orderProvider.orderDetails![index].quantity ?? ""}",
// //                                                 style: TextStyle(
// //                                                     fontSize: Dimensions
// //                                                         .fontSizeLarge),
// //                                                 maxLines: 2,
// //                                                 overflow: TextOverflow.ellipsis,
// //                                               ),
// //                                               const SizedBox(height: 4),
// //                                               Row(
// //                                                 children: [
// //                                                   Text(
// //                                                     "${orderProvider.orderDetails![index].price ?? ""} $currencySymbol",
// //                                                     style: TextStyle(
// //                                                         fontSize: Dimensions
// //                                                             .fontSizeExtraLarge,
// //                                                         fontWeight:
// //                                                             FontWeight.bold),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         // Total amount for selected return items
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                           child: Container(
// //                             width: MediaQuery.of(context).size.width - 32,
// //                             decoration: const BoxDecoration(
// //                               borderRadius:
// //                                   BorderRadius.all(Radius.circular(12)),
// //                               color: Colors.white,
// //                             ),
// //                             padding: const EdgeInsets.all(
// //                                 Dimensions.paddingSizeDefault),
// //                             child: Column(
// //                               children: [
// //                                 const Divider(),
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(top: 8.0),
// //                                   child: Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text(
// //                                         'Return Total',
// //                                         style: TextStyle(
// //                                             fontSize:
// //                                                 Dimensions.fontSizeExtraLarge,
// //                                             fontWeight: FontWeight.bold),
// //                                       ),
// //                                       Text(
// //                                         "${_calculateReturnTotal(orderProvider).toStringAsFixed(2)} $currencySymbol",
// //                                         style: TextStyle(
// //                                             fontSize:
// //                                                 Dimensions.fontSizeExtraLarge,
// //                                             fontWeight: FontWeight.bold),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                         // Return Button
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                           child: CustomButtonWidget(
// //                             buttonText: 'Return',
// //                             onPressed: orderReturnProvider.isLoading
// //                                 ? null
// //                                 : () async {
// //                                     List<Map<String, String>>
// //                                         selectedProductIds = [];
// //                                     for (int i = 0;
// //                                         i < selectedProducts.length;
// //                                         i++) {
// //                                       if (selectedProducts[i]) {
// //                                         selectedProductIds.add({
// //                                           'product_id': orderProvider
// //                                               .orderDetails![i]
// //                                               .productDetails!
// //                                               .id
// //                                               .toString()
// //                                         });
// //                                       }
// //                                     }

// //                                     if (selectedProductIds.isNotEmpty) {
// //                                       await orderReturnProvider.returnProducts(
// //                                         widget.orderId.toString(),
// //                                         selectedProductIds,
// //                                         'your_bearer_token_here',
// //                                       );

// //                                       if (orderReturnProvider.responseMessage !=
// //                                           null) {
// //                                         ScaffoldMessenger.of(context)
// //                                             .showSnackBar(
// //                                           SnackBar(
// //                                               content: Text(orderReturnProvider
// //                                                   .responseMessage!)),
// //                                         );
// //                                       }
// //                                     } else {
// //                                       ScaffoldMessenger.of(context)
// //                                           .showSnackBar(
// //                                         const SnackBar(
// //                                             content: Text(
// //                                                 "Please select at least one product to return.")),
// //                                       );
// //                                     }
// //                                   },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //         },
// //       ),
// //     );
// //   }
// // }

// // class OrderReturnScreen extends StatefulWidget {
// //   final OrderModel? orderModel;
// //   final int? orderId;
// //   final String? phoneNumber;

// //   const OrderReturnScreen({
// //     Key? key,
// //     required this.orderModel,
// //     required this.orderId,
// //     this.phoneNumber,
// //   }) : super(key: key);

// //   @override
// //   State<OrderReturnScreen> createState() => _OrderReturnScreenState();
// // }

// // class _OrderReturnScreenState extends State<OrderReturnScreen> {
// //   List<bool> selectedProducts = [];

// //   void _loadData(BuildContext context) async {
// //     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
// //     await orderProvider.getOrderDetails(
// //       orderID: widget.orderId.toString(),
// //       phoneNumber: widget.phoneNumber,
// //     );

// //     // Initialize selection status for each product
// //     setState(() {
// //       selectedProducts =
// //           List<bool>.filled(orderProvider.orderDetails?.length ?? 0, false);
// //     });
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData(context);
// //   }

// //   double _calculateReturnTotal(OrderProvider orderProvider) {
// //     double total = 0.0;
// //     for (int i = 0; i < selectedProducts.length; i++) {
// //       if (selectedProducts[i]) {
// //         total += (orderProvider.orderDetails![i].price ?? 0) *
// //             (orderProvider.orderDetails![i].quantity ?? 1);
// //       }
// //     }
// //     return total;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
// //     final currencySymbol = splashProvider.configModel?.currencySymbol ?? "";

// //     return Scaffold(
// //       backgroundColor: ColorResources.scaffoldGrey,
// //       appBar: AppBar(
// //         backgroundColor: Theme.of(context).cardColor,
// //         leading: GestureDetector(
// //           onTap: () {
// //             Navigator.of(context).pop();
// //           },
// //           child: const Icon(
// //             Icons.chevron_left,
// //             size: 30,
// //           ),
// //         ),
// //         centerTitle: true,
// //         title: Text(
// //           'Order Return',
// //           style: poppinsSemiBold.copyWith(
// //             fontSize: Dimensions.fontSizeExtraLarge,
// //             color: Theme.of(context).textTheme.bodyLarge!.color,
// //           ),
// //         ),
// //       ),
// //       body: Consumer<OrderProvider>(
// //         builder: (context, orderProvider, _) {
// //           return (orderProvider.orderDetails == null ||
// //                   orderProvider.trackModel == null)
// //               ? Center(
// //                   child:
// //                       CustomLoaderWidget(color: Theme.of(context).primaryColor),
// //                 )
// //               : SingleChildScrollView(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Column(
// //                       children: [
// //                         // Product List with Selection Checkboxes
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 16.0),
// //                           child: Container(
// //                             width: MediaQuery.of(context).size.width - 32,
// //                             decoration: const BoxDecoration(
// //                               borderRadius: BorderRadius.only(
// //                                 topLeft: Radius.circular(12),
// //                                 topRight: Radius.circular(12),
// //                               ),
// //                               color: Colors.white,
// //                             ),
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: Dimensions.paddingSizeDefault,
// //                               vertical: Dimensions.paddingSizeLarge,
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: List.generate(
// //                                 orderProvider.orderDetails!.length,
// //                                 (index) => Padding(
// //                                   padding: EdgeInsets.only(
// //                                       top: index == 0 ? 0 : 16.0),
// //                                   child: Container(
// //                                     decoration: BoxDecoration(
// //                                       borderRadius: BorderRadius.circular(12),
// //                                       color: const Color(0xFFF9F9F9),
// //                                     ),
// //                                     child: Row(
// //                                       children: [
// //                                         Checkbox(
// //                                           value: selectedProducts[index],
// //                                           onChanged: (bool? value) {
// //                                             setState(() {
// //                                               selectedProducts[index] =
// //                                                   value ?? false;
// //                                             });
// //                                           },
// //                                         ),
// //                                         ClipRRect(
// //                                           borderRadius: BorderRadius.circular(
// //                                               Dimensions.radiusSizeTen),
// //                                           child: CustomImageWidget(
// //                                             placeholder: Images.placeHolder,
// //                                             image:
// //                                                 '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
// //                                             height: 80,
// //                                             width: 80,
// //                                             fit: BoxFit.cover,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 16),
// //                                         Expanded(
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                                 CrossAxisAlignment.start,
// //                                             children: [
// //                                               Text(
// //                                                 "${orderProvider.orderDetails![index].productDetails?.name ?? ""} x ${orderProvider.orderDetails![index].quantity ?? ""}",
// //                                                 style: poppinsMedium.copyWith(
// //                                                     fontSize: Dimensions
// //                                                         .fontSizeLarge),
// //                                                 maxLines: 2,
// //                                                 overflow: TextOverflow.ellipsis,
// //                                               ),
// //                                               const SizedBox(height: 4),
// //                                               Row(
// //                                                 children: [
// //                                                   Text(
// //                                                     "${orderProvider.orderDetails![index].price ?? ""} $currencySymbol",
// //                                                     style: poppinsBold.copyWith(
// //                                                       fontSize: Dimensions
// //                                                           .fontSizeExtraLarge,
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),

// //                         // Order Details Section
// //                         Container(
// //                           margin:
// //                               const EdgeInsets.only(top: 16.0, bottom: 16.0),
// //                           padding: const EdgeInsets.all(
// //                               Dimensions.paddingSizeDefault),
// //                           decoration: const BoxDecoration(
// //                             borderRadius: BorderRadius.all(Radius.circular(12)),
// //                             color: Colors.white,
// //                           ),
// //                           child: Column(
// //                             children: [
// //                               orderSummaryTile(context, 'Order ID',
// //                                   orderProvider.trackModel!.id.toString()),
// //                               if (orderProvider.trackModel!.couponCode != null)
// //                                 orderSummaryTile(
// //                                     context,
// //                                     'Promo Code',
// //                                     orderProvider.trackModel!.couponCode
// //                                         .toString()),
// //                               if (orderProvider.trackModel!.createdAt != null)
// //                                 orderSummaryTile(
// //                                   context,
// //                                   'Ordered At',
// //                                   DateConverterHelper
// //                                       .isoStringToOrderDetailsDateTime(
// //                                           orderProvider.trackModel!.createdAt
// //                                               .toString()),
// //                                 ),
// //                               if (orderProvider.trackModel!.deliveryDate !=
// //                                   null)
// //                                 orderSummaryTile(
// //                                   context,
// //                                   'Delivery Date',
// //                                   DateConverterHelper
// //                                       .isoStringToOrderDetailsDateTime(
// //                                           orderProvider.trackModel!.deliveryDate
// //                                               .toString()),
// //                                 ),
// //                               if (orderProvider.trackModel!.paymentMethod !=
// //                                   null)
// //                                 orderSummaryTile(
// //                                   context,
// //                                   'Payment Method',
// //                                   getTranslated(
// //                                       orderProvider.trackModel!.paymentMethod
// //                                           .toString(),
// //                                       context),
// //                                 ),
// //                               if (orderProvider.trackModel!.paymentStatus !=
// //                                   null)
// //                                 orderSummaryTile(
// //                                   context,
// //                                   'Payment Status',
// //                                   getTranslated(
// //                                       orderProvider.trackModel!.paymentStatus
// //                                           .toString(),
// //                                       context),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),

// //                         // Total amount for selected return items
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                           child: Container(
// //                             width: MediaQuery.of(context).size.width - 32,
// //                             decoration: const BoxDecoration(
// //                               borderRadius:
// //                                   BorderRadius.all(Radius.circular(12)),
// //                               color: Colors.white,
// //                             ),
// //                             padding: const EdgeInsets.all(
// //                                 Dimensions.paddingSizeDefault),
// //                             child: Column(
// //                               children: [
// //                                 const Divider(),
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(top: 8.0),
// //                                   child: Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text(
// //                                         'Return Total',
// //                                         style: poppinsBold.copyWith(
// //                                             fontSize:
// //                                                 Dimensions.fontSizeExtraLarge),
// //                                       ),
// //                                       Text(
// //                                         "${_calculateReturnTotal(orderProvider).toStringAsFixed(2)} $currencySymbol",
// //                                         style: poppinsBold.copyWith(
// //                                             fontSize:
// //                                                 Dimensions.fontSizeExtraLarge),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),

// //                         // Return Button
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                           child: CustomButtonWidget(
// //                             buttonText: 'Return',
// //                             onPressed: () {
// //                               // Implement return action here
// //                               // Example: Show a confirmation dialog
// //                               showDialog(
// //                                 context: context,
// //                                 builder: (context) => AlertDialog(
// //                                   title: Text('Return Confirmation'),
// //                                   content: Text(
// //                                       'Are you sure you want to return the selected items?'),
// //                                   actions: [
// //                                     TextButton(
// //                                       onPressed: () =>
// //                                           Navigator.of(context).pop(),
// //                                       child: Text('Cancel'),
// //                                     ),
// //                                     TextButton(
// //                                       onPressed: () {
// //                                         // Perform the return action here
// //                                         Navigator.of(context).pop();
// //                                         // Add your return logic
// //                                       },
// //                                       child: Text('Confirm'),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //         },
// //       ),
// //     );
// //   }

// //   Widget orderSummaryTile(BuildContext context, String title, String data,
// //       [bool isPrice = false, bool isRed = false]) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(title, style: poppinsSemiBold),
// //           Text(
// //             data +
// //                 (!isPrice
// //                     ? ""
// //                     : " ${Provider.of<SplashProvider>(context, listen: false).configModel?.currencySymbol ?? ""}"),
// //             style: poppinsSemiBold.copyWith(color: isRed ? Colors.red : null),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
