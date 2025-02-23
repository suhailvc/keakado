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

  List<String?> validationErrors = [];
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
    validationErrors = List.generate(30, (index) => null);
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
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: const Color(0xFFF9F9F9),
                                            ),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value:
                                                      selectedProducts[index],
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
                                                          Dimensions
                                                              .radiusSizeTen),
                                                  child: CustomImageWidget(
                                                    placeholder:
                                                        Images.placeHolder,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${filteredOrderDetails[index].productDetails?.name ?? ""}",
                                                        style: TextStyle(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                      if (remarksControllers[
                                                              index]
                                                          .text
                                                          .isNotEmpty)
                                                        Text(
                                                          "${remarksControllers[index].text}",
                                                          style: poppinsMedium
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor,
                                                            fontSize: 13,
                                                          ),
                                                          maxLines:
                                                              2, // Limit the text to 2 lines
                                                          overflow: TextOverflow
                                                              .ellipsis, // Append "..." if the text overflows
                                                        ),
                                                      // : SizedBox(),
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
                                                              final provider =
                                                                  Provider.of<
                                                                          OrderReturnProvider>(
                                                                      context);
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 16.0,
                                                                  right: 16.0,
                                                                  top: 16.0,
                                                                  bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom,
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Row(
                                                                      // mainAxisAlignment:
                                                                      //     MainAxisAlignment
                                                                      //         .center, // This spreads out the children
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.3,
                                                                        ),
                                                                        Text(
                                                                          'Return Notes',
                                                                          style:
                                                                              poppinsSemiBold.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.27,
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context); // This will close the current screen/dialog
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(4),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.red.shade50, // Light red background
                                                                            ),
                                                                            child:
                                                                                Icon(
                                                                              Icons.close,
                                                                              color: Colors.red.shade600, // Darker red for the X icon
                                                                              size: 20,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16),
                                                                    Container(
                                                                      height:
                                                                          150,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            remarksControllers[index],
                                                                        maxLines:
                                                                            null,
                                                                        expands:
                                                                            true,
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          hintText:
                                                                              'Enter your return notes',
                                                                          border:
                                                                              InputBorder.none,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16),
                                                                    // if (returnImagess[index] !=
                                                                    //         null &&
                                                                    //     returnImagess[index]
                                                                    //         .isNotEmpty)
                                                                    //   Column(
                                                                    //     children: [
                                                                    //       Stack(
                                                                    //         alignment:
                                                                    //             Alignment.topRight,
                                                                    //         children: [
                                                                    //           Container(
                                                                    //             height: MediaQuery.of(context).size.height * 0.2, // 20% of screen height
                                                                    //             width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                                                                    //             child: Image.file(
                                                                    //               returnImagess[index][0]!,
                                                                    //               fit: BoxFit.cover,
                                                                    //             ),
                                                                    //           ),
                                                                    //           Positioned(
                                                                    //             top: -MediaQuery.of(context).size.width * 0.007, // 2% of screen width
                                                                    //             right: -MediaQuery.of(context).size.width * 0.007,
                                                                    //             child: InkWell(
                                                                    //               onTap: () {
                                                                    //                 setState(() {
                                                                    //                   returnImagess[index].clear();
                                                                    //                   returnImages[index].clear();
                                                                    //                 });
                                                                    //               },
                                                                    //               child: Container(
                                                                    //                 padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01), // 1% of screen width
                                                                    //                 decoration: BoxDecoration(
                                                                    //                   shape: BoxShape.circle,
                                                                    //                   color: Colors.red.shade50,
                                                                    //                 ),
                                                                    //                 child: Icon(
                                                                    //                   Icons.close,
                                                                    //                   color: Colors.red.shade600,
                                                                    //                   size: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
                                                                    //                 ),
                                                                    //               ),
                                                                    //             ),
                                                                    //           ),
                                                                    //         ],
                                                                    //       ),
                                                                    //       SizedBox(
                                                                    //           height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
                                                                    //     ],
                                                                    //   ),
                                                                    if (returnImagess[index] !=
                                                                            null &&
                                                                        returnImagess[index]
                                                                            .isNotEmpty)
                                                                      Column(
                                                                        children: [
                                                                          Stack(
                                                                            alignment:
                                                                                Alignment.topRight,
                                                                            children: [
                                                                              Image.file(
                                                                                returnImagess[index][0]!,
                                                                                height: 150,
                                                                                width: 150,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 16),
                                                                        ],
                                                                      ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            await showImagePickerOptions(context,
                                                                                index);
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Theme.of(context).primaryColor,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            getTranslated("Add Image",
                                                                                context),
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.04,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              MediaQuery.of(context).size.width * 0.114,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.25,
                                                                          child:
                                                                              ElevatedButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (remarksControllers[index].text.isEmpty) {
                                                                                ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snack bars
                                                                                Navigator.pop(context); // Close bottom sheet first
                                                                                Future.delayed(Duration(milliseconds: 100), () {
                                                                                  // Small delay to ensure bottom sheet is closed
                                                                                  showCustomSnackBarHelper('Add return notes', isError: true);
                                                                                });
                                                                                return;
                                                                              }
                                                                              if (returnImagess[index].isEmpty) {
                                                                                ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snack bars
                                                                                Navigator.pop(context); // Close bottom sheet first
                                                                                Future.delayed(Duration(milliseconds: 100), () {
                                                                                  // Small delay to ensure bottom sheet is closed
                                                                                  showCustomSnackBarHelper('Add return image', isError: true);
                                                                                });
                                                                                return;
                                                                              }

                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Theme.of(context).primaryColor,
                                                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              getTranslated("Save", context),
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: MediaQuery.of(context)
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
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Return Notes',
                                                              style:
                                                                  poppinsSemiBold
                                                                      .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor
                                                                    .withOpacity(
                                                                        0.2),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.01),
                                                            Icon(
                                                              Icons.edit,
                                                              size: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02,
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor
                                                                  .withOpacity(
                                                                      0.2),
                                                            ),
                                                          ],
                                                        ),
                                                        // child: Row(
                                                        //   children: [
                                                        //     Text(
                                                        //       'Return Notes',
                                                        //       style:
                                                        //           poppinsSemiBold
                                                        //               .copyWith(
                                                        //         fontSize: Dimensions
                                                        //             .fontSizeDefault,
                                                        //         color: Theme.of(
                                                        //                 context)
                                                        //             .disabledColor
                                                        //             .withOpacity(
                                                        //                 0.2),
                                                        //       ),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          // Get the current quantity and store it in a variable

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
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      "${filteredOrderDetails[index].quantity ?? 1}",
                                                      style: TextStyle(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
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
                                                                (filteredOrderDetails[index]
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
                                          if (selectedProducts[index] &&
                                              validationErrors[index] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 8.0),
                                              child: Text(
                                                validationErrors[index]!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                            ),
                                        ],
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
                            isLoading: orderReturnProvider.isLoading,
                            buttonText: 'Return',
                            onPressed: orderReturnProvider.isLoading
                                ? null
                                : () async {
                                    // await Provider.of<OrderProvider>(context,
                                    //         listen: false)
                                    //     .getOrderList(context);
                                    bool hasError = false;

                                    setState(() {
                                      // Reset all validation errors
                                      validationErrors =
                                          List.generate(30, (index) => null);

                                      // Check each selected product
                                      for (int i = 0;
                                          i < selectedProducts.length;
                                          i++) {
                                        if (selectedProducts[i]) {
                                          if (remarksControllers[i]
                                                  .text
                                                  .isEmpty &&
                                              returnImages[i].isEmpty) {
                                            validationErrors[i] =
                                                'Please add both return notes and image';
                                            hasError = true;
                                          } else if (remarksControllers[i]
                                              .text
                                              .isEmpty) {
                                            validationErrors[i] =
                                                'Please add return notes';
                                            hasError = true;
                                          } else if (returnImages[i].isEmpty) {
                                            validationErrors[i] =
                                                'Please add return image';
                                            hasError = true;
                                          }
                                        }
                                      }
                                    });

                                    if (hasError) {
                                      return;
                                    }

                                    List<Map<String, String>>
                                        selectedProductIds = [];
                                    for (int i = 0;
                                        i < selectedProducts.length;
                                        i++) {
                                      if (selectedProducts[i]) {
                                        if (remarksControllers[i]
                                            .text
                                            .isEmpty) {
                                          return showCustomSnackBarHelper(
                                              'Need Return Reason');
                                        } else if (returnImages[i].isEmpty) {
                                          return showCustomSnackBarHelper(
                                              'Need Return Image');
                                        } else {
                                          print(
                                              '${remarksControllers[i].text}-----------');
                                          print('${i}------id-----');
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
                                            "image": (i < returnImages.length &&
                                                    returnImages[i]
                                                        .isNotEmpty &&
                                                    returnImages[i][0] != null)
                                                ? (returnImages[i][0]!.isEmpty
                                                    ? ""
                                                    : returnImages[i][0]!)
                                                : "",
                                          });
                                        }
                                      }
                                    }
                                    if (selectedProductIds.isNotEmpty) {
                                      await orderReturnProvider.returnProducts(
                                          widget.orderId.toString(),
                                          selectedProductIds,
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .getUserToken());

                                      if (orderReturnProvider.responseMessage !=
                                          null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(orderReturnProvider
                                                  .responseMessage!)),
                                        );
                                        orderProvider.getOrderDetails(
                                          orderID: widget.orderId.toString(),
                                          phoneNumber: widget.phoneNumber,
                                        );
                                        print(
                                            "${selectedProductIds.length}---------------------");
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
                                    //  }
                                    // }
                                    // }
                                    // }
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
