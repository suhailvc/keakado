import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';

import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';

import 'package:flutter_grocery/features/order/domain/models/order_model.dart';

import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/order/providers/return_product_provider.dart';
import 'package:flutter_grocery/features/order/widgets/image_picker_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';

import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

class OrderReturnScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final String? phoneNumber;

  const OrderReturnScreen({
    Key? key,
    required this.orderModel,
    required this.orderId,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<OrderReturnScreen> createState() => _OrderReturnScreenState();
}

class _OrderReturnScreenState extends State<OrderReturnScreen> {
  int? maxAllowedQuantity;
  List<bool> selectedProducts = [];
  List<OrderDetailsModel> filteredOrderDetails = [];
  List<TextEditingController> remarksControllers = [];
  TextEditingController text1 = TextEditingController();
  List<String> returnQuantities = [];

  void _loadData(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.getOrderDetails(
      orderID: widget.orderId.toString(),
      phoneNumber: widget.phoneNumber,
    );
// Filter out products that are already returned
    filteredOrderDetails = orderProvider.orderDetails!
        .where((detail) => detail.isReturned != 1)
        .toList();
    // Initialize selection status for each product
    setState(() {
      selectedProducts =
          List<bool>.filled(orderProvider.orderDetails?.length ?? 0, false);
    });
  }

  @override
  void initState() {
    super.initState();
    remarksControllers = List.generate(30, (index) {
      return TextEditingController(); // Create a controller for each item
    }); // Initialize returnImages with null values
    returnImages = List.generate(30, (index) => []);
    returnQuantities = List.generate(
      30,
      (index) => '', // Initialize each element with an empty string
    );
    // Initialize returnImagess with null values
    returnImagess = List.generate(30, (index) => []);

    _loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    print('touched');
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final currencySymbol = splashProvider.configModel?.currencySymbol ?? "";
    final orderReturnProvider = Provider.of<OrderReturnProvider>(context);
    int quantity = 1;
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.chevron_left,
            size: 30,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Order Return',
          style: TextStyle(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          return (orderProvider.orderDetails == null ||
                  orderProvider.trackModel == null)
              ? Center(
                  child:
                      CustomLoaderWidget(color: Theme.of(context).primaryColor),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Product List with Selection Checkboxes
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                              width: MediaQuery.of(context).size.width - 32,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeLarge,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  filteredOrderDetails.length,
                                  (index) {
                                    returnQuantities[index] =
                                        filteredOrderDetails[index]
                                            .quantity
                                            .toString();
                                    int current =
                                        filteredOrderDetails[index].quantity ??
                                            1;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: index == 0 ? 0 : 16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: const Color(0xFFF9F9F9),
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: selectedProducts[index],
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  selectedProducts[index] =
                                                      value ?? false;
                                                });
                                              },
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSizeTen),
                                              child: CustomImageWidget(
                                                placeholder: Images.placeHolder,
                                                image:
                                                    '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${filteredOrderDetails[index].productDetails?.name ?? ""}",
                                                    style: TextStyle(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${filteredOrderDetails[index].price ?? ""} $currencySymbol",
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraLarge,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                        isDismissible: true,
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20)),
                                                        ),
                                                        builder: (context) {
                                                          final provider = Provider
                                                              .of<OrderReturnProvider>(
                                                                  context);
                                                          return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 16.0,
                                                              right: 16.0,
                                                              top: 16.0,
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  'Return Notes',
                                                                  style: poppinsSemiBold
                                                                      .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeLarge,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 16),
                                                                Container(
                                                                  height: 150,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        remarksControllers[
                                                                            index],
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      hintText:
                                                                          'Enter your return notes',
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 16),
                                                                // if (returnImagess[
                                                                //             index] !=
                                                                //         null ||
                                                                //     returnImagess
                                                                //         .isNotEmpty)
                                                                //final file = returnImagess[index];
                                                                if (returnImagess[
                                                                            index] !=
                                                                        null &&
                                                                    returnImagess[
                                                                            index]
                                                                        .isNotEmpty)
                                                                  Column(
                                                                    children: [
                                                                      Stack(
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        children: [
                                                                          Image
                                                                              .file(
                                                                            returnImagess[index][0]!,
                                                                            height:
                                                                                150,
                                                                            width:
                                                                                150,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          // IconButton(
                                                                          //   icon:
                                                                          //       const Icon(
                                                                          //     Icons.cancel,
                                                                          //     color:
                                                                          //         Colors.red,
                                                                          //   ),
                                                                          //   onPressed:
                                                                          //       () {
                                                                          //     // Call provider to remove the image at this index
                                                                          //     provider.removeImageAt(index);
                                                                          //   },
                                                                          // ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              16),
                                                                    ],
                                                                  ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await showImagePickerOptions(
                                                                        context,
                                                                        index);
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            16.0,
                                                                        vertical:
                                                                            12.0),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    getTranslated(
                                                                        "Add Image",
                                                                        context),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                // const SizedBox(
                                                                //     height: 16),
                                                                // ElevatedButton(
                                                                //   onPressed: () {
                                                                //     Navigator.pop(
                                                                //         context);
                                                                //   },
                                                                //   style: ElevatedButton
                                                                //       .styleFrom(
                                                                //     backgroundColor:
                                                                //         Colors
                                                                //             .green,
                                                                //     padding: const EdgeInsets
                                                                //         .symmetric(
                                                                //         horizontal:
                                                                //             16.0,
                                                                //         vertical:
                                                                //             12.0),
                                                                //     shape:
                                                                //         RoundedRectangleBorder(
                                                                //       borderRadius:
                                                                //           BorderRadius.circular(
                                                                //               10),
                                                                //     ),
                                                                //   ),
                                                                //   child:
                                                                //       const Text(
                                                                //     'Save Notes',
                                                                //     style: TextStyle(
                                                                //         color: Colors
                                                                //             .white),
                                                                //   ),
                                                                // ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.01,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      'Return Notes',
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withOpacity(0.2),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column(
                                            //   children: [
                                            //     IconButton(
                                            //       icon: const Icon(Icons.add),
                                            //       onPressed: () {
                                            //         setState(() {
                                            //           // Define maximum quantity
                                            //           int maxQuantity =
                                            //               filteredOrderDetails[
                                            //                           index]
                                            //                       .quantity ??
                                            //                   1;

                                            //           // Increase quantity but do not exceed maxQuantity
                                            //           if (quantity <
                                            //               maxQuantity) {
                                            //             quantity = quantity + 1;
                                            //           }
                                            //         });
                                            //       },
                                            //     ),
                                            //     Text(
                                            //       quantity.toString(),
                                            //       style: TextStyle(
                                            //         fontSize:
                                            //             Dimensions.fontSizeLarge,
                                            //         fontWeight: FontWeight.bold,
                                            //       ),
                                            //     ),
                                            //     IconButton(
                                            //       icon: const Icon(Icons.remove),
                                            //       onPressed: () {
                                            //         setState(() {
                                            //           // Ensure quantity does not go below 1
                                            //           if (quantity > 1) {
                                            //             filteredOrderDetails[
                                            //                         index]
                                            //                     .quantity =
                                            //                 (filteredOrderDetails[
                                            //                                 index]
                                            //                             .quantity ??
                                            //                         1) -
                                            //                     1;
                                            //           }
                                            //         });
                                            //       },
                                            //     ),
                                            //   ],
                                            // ),
                                            // Column(
                                            //   children: [
                                            //     IconButton(
                                            //       icon: const Icon(Icons.add),
                                            //       onPressed: () {
                                            //         setState(() {
                                            //           // Get the current quantity and store it in a variable
                                            //           // int currentQuantity =
                                            //           //     filteredOrderDetails[
                                            //           //                 index]
                                            //           //             .quantity ??
                                            //           //         1;

                                            //           // // Assign maxAllowedQuantity only once when the quantity is first incremented
                                            //           // if (maxAllowedQuantity ==
                                            //           //     null) {
                                            //           //   maxAllowedQuantity =
                                            //           //       filteredOrderDetails[
                                            //           //               index]
                                            //           //           .quantity; // Assign the current quantity
                                            //           // }
                                            //           // print(maxAllowedQuantity);
                                            //           // Safely check if the current quantity is less than the max allowed quantity
                                            //           if (filteredOrderDetails[
                                            //                       index]
                                            //                   .maxQuantity! <
                                            //               maxAllowedQuantity!) {
                                            //             // Increment the quantity
                                            //             filteredOrderDetails[
                                            //                         index]
                                            //                     .quantity =
                                            //                 filteredOrderDetails[
                                            //                             index]
                                            //                         .quantity! +
                                            //                     1;
                                            //           }

                                            //           // Update the returnQuantities list with the new quantity as a string
                                            //           returnQuantities[index] =
                                            //               filteredOrderDetails[
                                            //                       index]
                                            //                   .quantity
                                            //                   .toString();
                                            //         });
                                            //       },
                                            //     ),
                                            //     Text(
                                            //       "${filteredOrderDetails[index].quantity ?? 1}",
                                            //       style: TextStyle(
                                            //         fontSize: Dimensions
                                            //             .fontSizeLarge,
                                            //         fontWeight: FontWeight.bold,
                                            //       ),
                                            //     ),
                                            //     IconButton(
                                            //       icon:
                                            //           const Icon(Icons.remove),
                                            //       onPressed: () {
                                            //         setState(() {
                                            //           // Get the current quantity before decrement
                                            //           int currentQuantity =
                                            //               filteredOrderDetails[
                                            //                           index]
                                            //                       .quantity ??
                                            //                   1;

                                            //           // Decrease the quantity only if it's greater than 1
                                            //           if (currentQuantity > 1) {
                                            //             filteredOrderDetails[
                                            //                         index]
                                            //                     .quantity =
                                            //                 currentQuantity - 1;
                                            //           }

                                            //           // Update the returnQuantities list with the new quantity as a string
                                            //           returnQuantities[index] =
                                            //               filteredOrderDetails[
                                            //                       index]
                                            //                   .quantity
                                            //                   .toString();
                                            //         });
                                            //       },
                                            //     ),
                                            //   ],
                                            // )

                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      // Get the current quantity and store it in a variable
                                                      // int currentQuantity =
                                                      //     filteredOrderDetails[
                                                      //                 index]
                                                      //             .quantity ??
                                                      //         1;
                                                      // print(currentQuantity);
                                                      // // Set the maximum allowed quantity to be the value of currentQuantity
                                                      // int maxAllowedQuantity =
                                                      //     currentQuantity;

                                                      // Safely check if the current quantity is less than the max allowed quantity
                                                      if (filteredOrderDetails[
                                                                  index]
                                                              .quantity! <
                                                          filteredOrderDetails[
                                                                  index]
                                                              .maxQuantity!) {
                                                        // Increment the quantity
                                                        filteredOrderDetails[
                                                                    index]
                                                                .quantity =
                                                            filteredOrderDetails[
                                                                        index]
                                                                    .quantity! +
                                                                1;
                                                        returnQuantities[
                                                                index] =
                                                            filteredOrderDetails[
                                                                    index]
                                                                .quantity
                                                                .toString();
                                                      }

                                                      // Update the returnQuantities list with the new quantity as a string
                                                      // returnQuantities[index] =
                                                      //     filteredOrderDetails[
                                                      //             index]
                                                      //         .quantity
                                                      //         .toString();
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "${filteredOrderDetails[index].quantity ?? 1}",
                                                  style: TextStyle(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: () {
                                                    setState(() {
                                                      if ((filteredOrderDetails[
                                                                      index]
                                                                  .quantity ??
                                                              1) >
                                                          1) {
                                                        filteredOrderDetails[
                                                                    index]
                                                                .quantity =
                                                            (filteredOrderDetails[
                                                                            index]
                                                                        .quantity ??
                                                                    1) -
                                                                1;
                                                        returnQuantities[
                                                                index] =
                                                            filteredOrderDetails[
                                                                    index]
                                                                .quantity
                                                                .toString();
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                        ),
                        // Order Details Section
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              orderSummaryTile(context, 'Order ID',
                                  orderProvider.trackModel!.id.toString()),
                              if (orderProvider.trackModel!.couponCode != null)
                                orderSummaryTile(
                                    context,
                                    'Promo Code',
                                    orderProvider.trackModel!.couponCode
                                        .toString()),
                              if (orderProvider.trackModel!.createdAt != null)
                                orderSummaryTile(
                                  context,
                                  'Ordered At',
                                  DateConverterHelper
                                      .isoStringToOrderDetailsDateTime(
                                          orderProvider.trackModel!.createdAt
                                              .toString()),
                                ),
                              if (orderProvider.trackModel!.deliveryDate !=
                                  null)
                                orderSummaryTile(
                                  context,
                                  'Delivery Date',
                                  DateConverterHelper
                                      .isoStringToOrderDetailsDateTime(
                                          orderProvider.trackModel!.deliveryDate
                                              .toString()),
                                ),
                              if (orderProvider.trackModel!.paymentMethod !=
                                  null)
                                orderSummaryTile(
                                  context,
                                  'Payment Method',
                                  getTranslated(
                                      orderProvider.trackModel!.paymentMethod
                                          .toString(),
                                      context),
                                ),
                              if (orderProvider.trackModel!.paymentStatus !=
                                  null)
                                orderSummaryTile(
                                  context,
                                  'Payment Status',
                                  getTranslated(
                                      orderProvider.trackModel!.paymentStatus
                                          .toString(),
                                      context),
                                ),
                            ],
                          ),
                        ),

                        // Return Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: CustomButtonWidget(
                            buttonText: 'Return',
                            onPressed: orderReturnProvider.isLoading
                                ? null
                                : () async {
                                    List<Map<String, String>>
                                        selectedProductIds = [];
                                    for (int i = 0;
                                        i < selectedProducts.length;
                                        i++) {
                                      if (selectedProducts[i]) {
                                        if (remarksControllers[i]
                                            .text
                                            .isEmpty) {
                                          showCustomSnackBarHelper(
                                              'Need Return Reason');
                                        } else {
                                          selectedProductIds.add({
                                            'product_id': orderProvider
                                                .orderDetails![i]
                                                .productDetails!
                                                .id
                                                .toString(),
                                            'remarks': remarksControllers[i]
                                                    .text
                                                    .isEmpty
                                                ? ''
                                                : remarksControllers[i].text,
                                            'qty': returnQuantities[i],
                                            // 'qty': returnQuantities[i].isEmpty
                                            //     ? ""
                                            //     : returnQuantities[i],
                                            "image": (i < returnImages.length &&
                                                    returnImages[i]
                                                        .isNotEmpty &&
                                                    returnImages[i][0] != null)
                                                ? (returnImages[i][0]!.isEmpty
                                                    ? ""
                                                    : returnImages[i][0]!)
                                                : "",

                                            // "image": returnImages[i][0].isEmpty
                                            //     ? ""
                                            //     : returnImages[i][0]!
                                          });
                                          if (selectedProductIds.isNotEmpty) {
                                            await orderReturnProvider
                                                .returnProducts(
                                                    widget.orderId.toString(),
                                                    selectedProductIds,
                                                    // 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTA1MGZhMzgzNWRmZWQ0ZmQ4YTVhOTllMzIxNTE5NjUyMTczNDgzZWQxZTFmM2FiMzZhOTkyOGY1Y2UzYzM2ZjYyNDRkYTgwNjg5Mjc3NTMiLCJpYXQiOjE3MzM0MDA1NDUuNTgzNTg3LCJuYmYiOjE3MzM0MDA1NDUuNTgzNTg4LCJleHAiOjE3NjQ5MzY1NDUuNTc3MzkxLCJzdWIiOiIxMCIsInNjb3BlcyI6W119.FA4LJSLVFNe0x4iUQLJ27dOYbfoe3Vta2Q_txneV2qbQovP45bNarPw0nJCHKGLsaYa4R7hsc0Kam-KC8ua4V5ZNxrsKmCWO5ubHgKpHmFBY1UKPVyJI6iHuHLXNjB6BUPlrjFUDvqbiqf0JzjFJSyWuPU4VkYEdZfOWy5AwCWr1muDdNENU4HPCGbegHo3Hk4ZhqKsqg1waXPoOLse8jVpEMObHHndqJ1j4YrTtrzLsM9gmn-5nWLIo_MlD8W_PDAYTb4SLJ9Y9ybpo0BhLxRYtjWafwx_dZsWuyf33kJ2K2exF7qhpQ4oL8HQUCoaGP2lPicKM94XntP0P_aImjFfiWZgIoet56NCluDgEN7wPPnruBaBMq13I2sPRXSAn1JwBcyR-fGypuN1Ja2VyMtlAMHSvmp9zVbbAoEUfzkWeZAzvUg8Ei8c9x19TQe8BB33IpVDuW1tQOlVelDwBWVGARYqGht3Dr8kQk-nhOibnSyeiUuEY-p6KKKzdTQNQsc93_DrStyaqwH_BIvaqLplkoeZWyn7BRNqfB1hoBQVlLUX4YTr61oN2VXBtsrxopXpxWoepyMP0dKhRcQQsK6zFKR4KSbb2a4slL5z9GLDp_J3TidAYWZhBg8s-xcPS0n_2dG'
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .getUserToken());

                                            if (orderReturnProvider
                                                    .responseMessage !=
                                                null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        orderReturnProvider
                                                            .responseMessage!)),
                                              );
                                              orderProvider.getOrderDetails(
                                                orderID:
                                                    widget.orderId.toString(),
                                                phoneNumber: widget.phoneNumber,
                                              );
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Please select at least one product to return.")),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget orderSummaryTile(BuildContext context, String title, String data,
      [bool isPrice = false, bool isRed = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            data +
                (!isPrice
                    ? ""
                    : " ${Provider.of<SplashProvider>(context, listen: false).configModel?.currencySymbol ?? ""}"),
            style: TextStyle(
                color: isRed ? Colors.red : null, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// List<String?> returnImages = [];
List<List<String?>> returnImages = [];
// List<File?> returnImagess = [];
List<List<File?>> returnImagess = [];
