import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/place_order_model.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/domain/models/distance_model.dart';
import 'package:flutter_grocery/features/order/domain/models/offline_payment_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/models/response_model.dart';
import 'package:flutter_grocery/features/order/domain/models/timeslote_model.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/order_cancel_status_repo.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/order_repo.dart';
import 'package:flutter_grocery/features/order/providers/image_note_provider.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:flutter_grocery/features/order/domain/models/delivery_man_model.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends ChangeNotifier {
  String _returnStatus = '';

  String? _error;

  String get returnStatus => _returnStatus;

  String? get error => _error;
  final OrderRepo? orderRepo;
  final SharedPreferences? sharedPreferences;
  OrderProvider({required this.sharedPreferences, required this.orderRepo});
  DateTime? _selectedDate;
  String payUrl = "";
  String orderId = "";

  DateTime? get selectedDate => _selectedDate;
  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  int? _paymentMethodIndex;
  OrderModel? _trackModel;
  int _addressIndex = -1;
  bool _isLoading = false;
  bool _showCancelled = false;
  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? _allTimeSlots;
  bool _isActiveOrder = true;
  int _branchIndex = 0;
  String? _orderType = 'delivery';
  ResponseModel? _responseModel;
  DeliveryManModel? _deliveryManModel;
  double _distance = -1;
  PaymentMethod? _paymentMethod;
  PaymentMethod? _selectedPaymentMethod;
  double? _partialAmount;
  OfflinePaymentModel? _selectedOfflineMethod;
  List<Map<String, String>>? _selectedOfflineValue;
  bool _isOfflineSelected = false;
  CheckOutModel? _checkOutData;
  int? _reOrderIndex;

  List<TimeSlotModel>? get timeSlots => _timeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;
  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  int? get paymentMethodIndex => _paymentMethodIndex;
  OrderModel? get trackModel => _trackModel;
  int get addressIndex => _addressIndex;
  bool get isLoading => _isLoading;
  bool get showCancelled => _showCancelled;
  bool get isActiveOrder => _isActiveOrder;
  int get branchIndex => _branchIndex;
  String? get orderType => _orderType;
  ResponseModel? get responseModel => _responseModel;
  DeliveryManModel? get deliveryManModel => _deliveryManModel;
  double get distance => _distance;
  PaymentMethod? get paymentMethod => _paymentMethod;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  double? get partialAmount => _partialAmount;
  OfflinePaymentModel? get selectedOfflineMethod => _selectedOfflineMethod;
  List<Map<String, String>>? get selectedOfflineValue => _selectedOfflineValue;
  bool get isOfflineSelected => _isOfflineSelected;
  CheckOutModel? get getCheckOutData => _checkOutData;
  int? get getReOrderIndex => _reOrderIndex;

  Map<String, TextEditingController> field = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String status = '0'; // Default status (0 = not available, 1 = available)
  List<TimeSlotModel> expressDeliverySlots =
      []; // List of express delivery slots

  bool isFetching = false; // Flag to track ongoing fetch request

  Future<void> fetchExpressDeliverySlots() async {
    // Prevent multiple API calls if already fetching
    if (isFetching) return;
    isFetching = true;

    print(
        '------------exp time before API call: ${expressDeliverySlots.length}');

    try {
      final response = await http.get(Uri.parse(
          "${AppConstants.baseUrl}/api/v1/customer/order/express-delivery-slots"));

      print(
          '------------exp time after API call: ${expressDeliverySlots.length}');

      if (response.statusCode == 200) {
        print(
            '------------exp time response received: ${expressDeliverySlots.length}');

        final data = jsonDecode(response.body);
        print(
            '------------exp time response decoded: ${expressDeliverySlots.length}');

        // Check if the data is a Map (since the response is an object with dynamic keys)
        if (data is Map) {
          expressDeliverySlots = [];

          // Loop through each value in the map and convert to TimeSlotModel
          data.forEach((key, value) {
            expressDeliverySlots.add(TimeSlotModel.fromJson(value));
          });

          print(
              '------------exp time after mapping: ${expressDeliverySlots.length}');
          status = '1'; // Mark status as available
        } else {
          print('Error: Response is not a map');
          status = '0'; // Mark status as unavailable
        }
      } else {
        print('Error: API response not successful');
        status = '0'; // Mark status as unavailable
      }
    } catch (e) {
      print('Error fetching express delivery slots: $e');
      status = '0'; // Mark status as unavailable on error
    } finally {
      print('------------exp time finally: ${expressDeliverySlots.length}');
      isFetching = false;
      notifyListeners();
    }
  }

  set setCheckOutData(CheckOutModel value) {
    _checkOutData = value;
  }

  set setReorderIndex(int value) {
    _reOrderIndex = value;
  }

  Future<void> getOrderList(BuildContext context) async {
    ApiResponseModel apiResponse = await orderRepo!.getOrderList();
    if (apiResponse.response?.statusCode == 200) {
      _runningOrderList = [];
      _historyOrderList = [];
      apiResponse.response?.data.forEach((order) {
        OrderModel orderModel = OrderModel.fromJson(order);
        if (orderModel.orderStatus == 'pending' ||
            orderModel.orderStatus == 'processing' ||
            orderModel.orderStatus == 'out_for_delivery' ||
            orderModel.orderStatus == 'confirmed') {
          _runningOrderList!.add(orderModel);
        } else if (orderModel.orderStatus == 'delivered' ||
            orderModel.orderStatus == 'returned' ||
            orderModel.orderStatus == 'failed' ||
            orderModel.orderStatus == 'canceled') {
          _historyOrderList!.add(orderModel);
        }
      });
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> initializeTimeSlot() async {
    _distance = -1;
    ApiResponseModel apiResponse = await orderRepo!.getTimeSlot();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _timeSlots = [];
      _allTimeSlots = [];
      apiResponse.response!.data.forEach((timeSlot) {
        _timeSlots!.add(TimeSlotModel.fromJson(timeSlot));

        _allTimeSlots!.add(TimeSlotModel.fromJson(timeSlot));
      });
      validateSlot(_allTimeSlots, 0);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  List<String> getDateList() {
    return orderRepo!.getDateList();
  }

  int _selectDateSlot = -1;
  int _selectTimeSlot = -1;

  int get selectDateSlot => _selectDateSlot;
  int get selectTimeSlot => _selectTimeSlot;

  void resetTimeSelections() {
    _selectDateSlot = -1;
    _selectTimeSlot = -1;
    notifyListeners();
  }

  void updateTimeSlot(int index) {
    _selectTimeSlot = index;
    notifyListeners();
  }

  void updateDateSlot(int index) {
    _selectDateSlot = index;
    if (_allTimeSlots != null) {
      validateSlot(_allTimeSlots, index);
    }
    _selectTimeSlot = -1;
    //_selectTimeSlot = index;
    notifyListeners();
  }

  void validateSlot(List<TimeSlotModel>? slots, int dateIndex) {
    _timeSlots = [];
    if (dateIndex == 0) {
      DateTime date = DateTime.now();
      for (var slot in slots!) {
        DateTime time = DateConverterHelper.stringTimeToDateTime(slot.endTime!);
        //  .subtract(const Duration(/*hours: 1*/ minutes: 30));
        DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour,
            time.minute, time.second);
        if (dateTime.isAfter(DateTime.now())) {
          _timeSlots!.add(slot);
        }
      }
    } else {
      _timeSlots!.addAll(_allTimeSlots!);
    }
  }

  double subTotal = 0;
  double discount = 0;
  double totalPrice = 0;

  Future<List<OrderDetailsModel>?> getOrderDetails(
      {required String orderID, String? phoneNumber}) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;
    subTotal = 0;
    discount = 0;
    totalPrice = 0;
    notifyListeners();
    ApiResponseModel apiResponse =
        await orderRepo!.getOrderDetails(orderID, phoneNumber);
    _isLoading = false;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _orderDetails = [];
      apiResponse.response?.data.forEach((orderDetail) =>
          _orderDetails?.add(OrderDetailsModel.fromJson(orderDetail)));
      for (var element in _orderDetails!) {
        try {
          subTotal += double.parse(element.productDetails!.price.toString());
          discount += double.parse(element.productDetails!.discount.toString());
          totalPrice += double.parse(element.price.toString());
        } catch (e) {
          subTotal = 0;
          discount = 0;
          totalPrice = 0;
        }
      }
    } else {
      _orderDetails = [];
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return _orderDetails;
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void changeActiveOrderStatus(bool status, {bool isUpdate = true}) {
    _isActiveOrder = status;

    if (isUpdate) {
      notifyListeners();
    }
  }

  Future<void> getDeliveryManData(String? orderID, BuildContext context) async {
    ApiResponseModel apiResponse = await orderRepo!.getDeliveryManData(orderID);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _deliveryManModel = DeliveryManModel.fromJson(apiResponse.response!.data);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<ResponseModel> trackOrder(String? orderID, OrderModel? orderModel,
      BuildContext context, bool fromTracking,
      {String? phoneNumber, bool isUpdate = true}) async {
    _trackModel = null;
    ResponseModel responseModel;
    if (!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if (orderModel == null) {
      _isLoading = true;
      if (isUpdate) {
        notifyListeners();
      }

      ApiResponseModel apiResponse =
          await orderRepo!.trackOrder(orderID, phoneNumber);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _trackModel = OrderModel.fromJson(apiResponse.response!.data);
        responseModel =
            ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        _orderDetails = [];
        _trackModel = OrderModel();
        responseModel = ResponseModel(false,
            ApiCheckerHelper.getError(apiResponse).errors?.first.message);
        ApiCheckerHelper.checkApi(apiResponse);
      }
      _isLoading = false;
      notifyListeners();
    } else {
      _trackModel = orderModel;
      responseModel = ResponseModel(true, 'Successful');
    }
    return responseModel;
  }

  Future<void> placeOrder(
      PlaceOrderModel placeOrderBody, Function callback) async {
    final OrderImageNoteProvider imageNoteProvider =
        Provider.of<OrderImageNoteProvider>(Get.context!, listen: false);
    print('--------is partial ${placeOrderBody.isPartial}');
    //  print('--------is partial${placeOrderBody.paymentInfo}');
    print('-------payment by ${placeOrderBody.paymentBy}');
    print('-------payment method ${placeOrderBody.paymentMethod}');
    print('-------payment info${placeOrderBody.paymentInfo}');
    print('-------payment note${placeOrderBody.paymentNote}');
    // print('-------order amount${placeOrderBody.orderAmount}');
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await orderRepo!.placeOrder(placeOrderBody,
        imageNote: imageNoteProvider.imageFiles ?? []);
    _isLoading = false;
    //   print('-----------api response ${apiResponse.response!.statusCode}');
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      String? message = apiResponse.response!.data['message'];
      String orderID = apiResponse.response!.data['order_id'].toString();
      callback(true, message, orderID);
      debugPrint('-------- Order placed successfully $orderID ----------');
    } else {
      callback(false, ApiCheckerHelper.getError(apiResponse).errors![0].message,
          '-1');
    }
    notifyListeners();
  }

  Future<void> placeOrderSkip(PlaceOrderModel placeOrderBody, Function callback,
      {bool isUpdate = true}) async {
    final OrderImageNoteProvider imageNoteProvider =
        Provider.of<OrderImageNoteProvider>(Get.context!, listen: false);
    print("test api 1");
    try {
      _isLoading = true;
      if (isUpdate) {
        notifyListeners();
        print("test api 2");
      }
      ApiResponseModel apiResponse = await orderRepo!.placeOrder(placeOrderBody,
          imageNote: imageNoteProvider.imageFiles ?? []);
      print("test api 3");
      _isLoading = false;

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        // Handle the response data correctly
        var responseData = apiResponse.response!.data;
        print(responseData.toString() + " dataaa");

        try {
          // Ensure responseData is parsed into a Map<String, dynamic>
          Map<String, dynamic> parsedJson;

          if (responseData is String) {
            // Check if the responseData contains a JSON part
            List<String> parts = responseData.split('\n'); // Split by newline
            String jsonPart =
                parts.last.trim(); // Get the last part assuming it's JSON

            // Parse the JSON part if it starts with '{' and ends with '}'
            if (jsonPart.startsWith('{') && jsonPart.endsWith('}')) {
              parsedJson = jsonDecode(jsonPart);
            } else {
              throw Exception('Invalid JSON format in the response');
            }
          } else if (responseData is Map<String, dynamic>) {
            parsedJson = responseData; // Directly assign if already a Map
          } else {
            throw Exception('Unexpected response format');
          }

          // Extract the required fields with null checks
          String? message = parsedJson['message'] as String?;
          String? orderID =
              parsedJson['order_id']?.toString(); // Convert to string if needed
          String paymentUrl = parsedJson['url'] as String? ??
              ''; // Set to empty string if not present

          if (message != null && orderID != null) {
            print('Message: $message');
            print('Order ID: $orderID');
            print('Payment URL: $paymentUrl');
            payUrl = paymentUrl;
            orderId = orderID;

            // Callback with extracted values
            callback(true, message, orderID, placeOrderBody.deliveryAddressId);
          } else {
            print('Error: Missing required fields in the response.');
          }
        } catch (jsonError) {
          print('Error parsing JSON: $jsonError');
        }
      } else {
        callback(false,
            ApiCheckerHelper.getError(apiResponse).errors![0].message, '-1');
      }
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      print("Exception occurred while processing the response.");
    }

    notifyListeners();
    // final OrderImageNoteProvider imageNoteProvider =
    //     Provider.of<OrderImageNoteProvider>(Get.context!, listen: false);

    // _isLoading = true;
    // notifyListeners();
    // ApiResponseModel apiResponse = await orderRepo!.placeOrder(placeOrderBody,
    //     imageNote: imageNoteProvider.imageFiles ?? []);
    // _isLoading = false;

    // if (apiResponse.response != null &&
    //     apiResponse.response!.statusCode == 200) {
    //   String? message = apiResponse.response!.data['message'];
    //   String orderID = apiResponse.response!.data['order_id'].toString();
    //   String url = apiResponse.response!.data['url'];

    //   callback(true, message, orderID);
    //   debugPrint('-------- Order placed successfully $orderID ----------');
    // } else {
    //   callback(false, ApiCheckerHelper.getError(apiResponse).errors![0].message,
    //       '-1');
    // }
    // notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  void setAddressIndex(int index, {bool notify = true}) {
    _addressIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> getCancelStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _returnStatus = await cancelStatusService();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error in provider: $e');
    }
  }

  void cancelOrder(
    String orderID,
    bool fromOrder,
    Function callback,
  ) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await orderRepo!.cancelOrder(orderID);
    _isLoading = false;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      trackOrder(orderID, null, Get.context!, false, isUpdate: true);
      getOrderDetails(orderID: orderID);

      if (fromOrder) {
        OrderModel? orderModel;
        for (var order in _runningOrderList!) {
          if (order.id.toString() == orderID) {
            orderModel = order;
          }
        }
        _runningOrderList!.remove(orderModel);
      }
      _showCancelled = true;
      callback(apiResponse.response?.data['message'], true, orderID);
    } else {
      callback(ApiCheckerHelper.getError(apiResponse).errors?.first.message,
          false, '-1');
    }
    notifyListeners();
  }

  void setBranchIndex(int index) {
    _branchIndex = index;
    _addressIndex = -1;
    _distance = -1;
    notifyListeners();
  }

  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if (notify) {
      notifyListeners();
    }
  }

  bool _isDistanceLoading = false;
  bool get isDistanceLoading => _isDistanceLoading;

  Future<bool> getDistanceInMeter(
      LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    _isDistanceLoading = true;
    notifyListeners();
    bool isSuccess = false;
    ApiResponseModel response =
        await orderRepo!.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.response!.statusCode == 200 &&
          response.response!.data['status'] == 'OK') {
        isSuccess = true;
        _distance = DistanceModel.fromJson(response.response!.data)
                .rows![0]
                .elements![0]
                .distance!
                .value! /
            1000;
      } else {
        _distance = Geolocator.distanceBetween(
              originLatLng.latitude,
              originLatLng.longitude,
              destinationLatLng.latitude,
              destinationLatLng.longitude,
            ) /
            1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
            originLatLng.latitude,
            originLatLng.longitude,
            destinationLatLng.latitude,
            destinationLatLng.longitude,
          ) /
          1000;
    }
    _isDistanceLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<void> setPlaceOrder(String placeOrder) async {
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeOrder);
  }

  String? getPlaceOrder() {
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }

  Future<void> clearPlaceOrder() async {
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }

  void clearPrevData({bool isUpdate = false}) {
    _paymentMethod = null;
    _addressIndex = -1;
    _branchIndex = 0;
    _paymentMethodIndex = 0;
    _selectedPaymentMethod = null;
    _selectedOfflineMethod = null;
    _distance = -1;
    _trackModel = null;
    _partialAmount = null;
    _isLoading = false;
    clearOfflinePayment();
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setPaymentIndex(int? index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    _paymentMethod = null;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void changePaymentMethod(
      {PaymentMethod? digitalMethod,
      bool isUpdate = true,
      OfflinePaymentModel? offlinePaymentModel,
      bool isClear = false}) {
    if (offlinePaymentModel != null) {
      _selectedOfflineMethod = offlinePaymentModel;
    } else if (digitalMethod != null) {
      _paymentMethod = digitalMethod;
      _paymentMethodIndex = null;
      _selectedOfflineMethod = null;
      _selectedOfflineValue = null;
    }
    if (isClear) {
      _paymentMethod = null;
      _selectedPaymentMethod = null;
      clearOfflinePayment();
    }
    if (isUpdate) {
      notifyListeners();
    }
  }

  void clearOfflinePayment() {
    _selectedOfflineMethod = null;
    _selectedOfflineValue = null;
    _isOfflineSelected = false;
  }

  void savePaymentMethod(
      {int? index, PaymentMethod? method, bool isUpdate = true}) {
    if (method != null) {
      _selectedPaymentMethod = method.copyWith('online');
    } else if (index != null && index == 0) {
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: getTranslated('cash_on_delivery', Get.context!),
        getWay: 'cash_on_delivery',
        type: 'cash_on_delivery',
      );
    } else if (index != null && index == 1) {
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: getTranslated('wallet_payment', Get.context!),
        getWay: 'wallet_payment',
        type: 'wallet_payment',
      );
    } else if (index != null && index == 2) {
      // New Skip Cash Option
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: 'Pay via Card using Skip Cash',
        getWay: 'skip_cash',
        type: 'skip_cash',
      );
    } else {
      _selectedPaymentMethod = null;
    }

    if (isUpdate) {
      notifyListeners();
    }
  }
  // void savePaymentMethod(
  //     {int? index, PaymentMethod? method, bool isUpdate = true}) {
  //   if (method != null) {
  //     _selectedPaymentMethod = method.copyWith('online');
  //   } else if (index != null && index == 0) {
  //     _selectedPaymentMethod = PaymentMethod(
  //       getWayTitle: getTranslated('cash_on_delivery', Get.context!),
  //       getWay: 'cash_on_delivery',
  //       type: 'cash_on_delivery',
  //     );
  //   } else if (index != null && index == 1) {
  //     _selectedPaymentMethod = PaymentMethod(
  //       getWayTitle: getTranslated('wallet_payment', Get.context!),
  //       getWay: 'wallet_payment',
  //       type: 'wallet_payment',
  //     );
  //   } else {
  //     _selectedPaymentMethod = null;
  //   }

  //   if (isUpdate) {
  //     notifyListeners();
  //   }
  // }

  void setOfflineSelectedValue(List<Map<String, String>>? data,
      {bool isUpdate = true}) {
    _selectedOfflineValue = data;

    if (isUpdate) {
      notifyListeners();
    }
  }

  void setOfflineSelect(bool value) {
    _isOfflineSelected = value;
    notifyListeners();
  }

  void changePartialPayment({double? amount, bool isUpdate = true}) {
    _partialAmount = amount;
    if (isUpdate) {
      notifyListeners();
    }
  }

  List<Map<String, String>> getOfflinePaymentData() {
    List<Map<String, String>>? data = [];

    if (formKey.currentState!.validate()) {
      setOfflineSelectedValue(null);

      field.forEach((key, value) {
        data.add({key: value.text});
      });
      setOfflineSelectedValue(data);
    }
    return data;
  }

  List<CartModel> reOrderCartList = [];
  Future<List<CartModel>?> reorderProduct(int? quantity, String orderId) async {
    _isLoading = true;
    notifyListeners();

    final ProductProvider productProvider =
        Provider.of<ProductProvider>(Get.context!, listen: false);

    List<OrderDetailsModel>? orderDetailsList =
        await getOrderDetails(orderID: orderId);
    reOrderCartList = [];

    for (OrderDetailsModel orderDetails in orderDetailsList ?? []) {
      Product? product;
      String? selectVariationType;

      if (orderDetails.formattedVariation != null) {
        selectVariationType =
            OrderHelper.getVariationValue(orderDetails.formattedVariation);
      }

      try {
        product = await productProvider
            .getProductDetails('${orderDetails.productId}');
      } catch (e) {
        _reOrderIndex = null;
        showCustomSnackBarHelper(getTranslated(
            'this_product_is_currently_unavailable', Get.context!));
      }

      CartModel? cartModel = OrderHelper.getReorderCartData(
        quantity: orderDetails
            .quantity, // Use original order quantity instead of passed quantity
        product: product,
        selectVariationType: selectVariationType,
      );

      if (cartModel != null) {
        reOrderCartList.add(cartModel);
      }
    }

    _isLoading = false;
    notifyListeners();
    return reOrderCartList;
  }
  // Future<List<CartModel>?> reorderProduct(int? quantity, String orderId) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   final ProductProvider productProvider =
  //       Provider.of<ProductProvider>(Get.context!, listen: false);
  //   print('re oreder');
  //   List<OrderDetailsModel>? orderDetailsList =
  //       await getOrderDetails(orderID: orderId);
  //   print("---------------------------${orderDetailsList!.length.toString()}");
  //   reOrderCartList = [];

  //   for (OrderDetailsModel orderDetails in orderDetailsList ?? []) {
  //     Product? product;
  //     String? selectVariationType;

  //     if (orderDetails.formattedVariation != null) {
  //       selectVariationType =
  //           OrderHelper.getVariationValue(orderDetails.formattedVariation);
  //     }
  //     print('------------------id---------${orderDetails.productId}');
  //     try {
  //       product = await productProvider
  //           .getProductDetails('${orderDetails.productId}');
  //       print('----------------product----$product');
  //     } catch (e) {
  //       _reOrderIndex = null;
  //       showCustomSnackBarHelper(getTranslated(
  //           'this_product_is_currently_unavailable', Get.context!));
  //     }

  //     CartModel? cartModel = OrderHelper.getReorderCartData(
  //         quantity: quantity,
  //         product: product,
  //         selectVariationType: selectVariationType);
  //     print("----------cartmodel-----------${cartModel}");
  //     if (cartModel != null) {
  //       reOrderCartList.add(cartModel);
  //     }
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  //   print('re order cart list------------------${reOrderCartList}');
  //   return reOrderCartList;
  // }
}
