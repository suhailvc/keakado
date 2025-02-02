// ignore_for_file: deprecated_member_use

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/providers/localization_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/features/checkout/provider/exprees_deliver_provider.dart';
import 'package:flutter_grocery/features/checkout/widgets/constants.dart';
import 'package:flutter_grocery/features/checkout/widgets/delivery_address_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/details_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/place_order_button_widget.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/home/screens/bottom_nav.dart';
import 'package:flutter_grocery/features/order/providers/image_note_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';

import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/providers/wallet_provider.dart';

import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double amount;
  final double itemDiscount;
  final String? orderType;
  final double? discount;
  final String? couponCode;
  final String freeDeliveryType;
  final double deliveryCharge;
  const CheckoutScreen(
      {Key? key,
      required this.itemDiscount,
      required this.amount,
      required this.orderType,
      required this.discount,
      required this.couponCode,
      required this.freeDeliveryType,
      required this.deliveryCharge})
      : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final TextEditingController _noteController = TextEditingController();
  late GoogleMapController _mapController;
  List<Branches>? _branches = [];
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  late bool _isLoggedIn;
  List<PaymentMethod> _activePaymentList = [];
  late bool selfPickup;

  @override
  void initState() {
    initLoading();
    // double? walletBalance = Provider.of<ProfileProvider>(context, listen: false)
    //     .userInfoModel
    //     ?.walletBalance;
    // print("---------------------$walletBalance");
    Provider.of<OrderProvider>(context, listen: false).resetTimeSelections();
    Provider.of<LocationProvider>(context, listen: false)
        .resetAddressSelection();
    final walletProvide =
        Provider.of<WalletAndLoyaltyProvider>(context, listen: false);
    Provider.of<ExpressDeliveryProvider>(context, listen: false)
        .expressDeliveryStatus();
    Provider.of<OrderProvider>(context, listen: false)
        .fetchExpressDeliverySlots();
    walletProvide.setCurrentTabButton(0, isUpdate: false);
    walletProvide.insertFilterList();
    walletProvide.setWalletFilerType('all', isUpdate: false);

    // Future.delayed(const Duration(milliseconds: 500)).then((value) {
    //   if (widget.status != null && widget.status!.contains('success')) {
    //     if (!kIsWeb ||
    //         (kIsWeb &&
    //             widget.token != null &&
    //             walletProvide.checkToken(widget.token!))) {
    //       showCustomSnackBarHelper(
    //           getTranslated('add_fund_successful', context),
    //           isError: false);
    //     }
    //   } else if (widget.status != null && widget.status!.contains('fail')) {
    //     showCustomSnackBarHelper(getTranslated('add_fund_failed', context));
    //   }
    // });

    if (_isLoggedIn) {
      walletProvide.getWalletBonusList(false);
      Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo();
      walletProvide.getLoyaltyTransactionList('1', false, true,
          isEarning: walletProvide.selectedTabButtonIndex == 1);

      // scrollController.addListener(() {
      //   if (scrollController.position.pixels ==
      //           scrollController.position.maxScrollExtent &&
      //       walletProvide.transactionList != null &&
      //       !walletProvide.isLoading) {
      //     int pageSize = (walletProvide.popularPageSize! / 10).ceil();
      //     if (walletProvide.offset < pageSize) {
      //       walletProvide.setOffset = walletProvide.offset + 1;
      //       walletProvide.updatePagination(true);

      //       walletProvide.getLoyaltyTransactionList(
      //         walletProvide.offset.toString(),
      //         false,
      //         true,
      //         isEarning: walletProvide.selectedTabButtonIndex == 1,
      //       );
      //     }
      //   }
      // });
    }
    super.initState();

    // initLoading();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    final bool isRoute = (_isLoggedIn ||
        (configModel.isGuestCheckout! && authProvider.getGuestId() != null));

    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).cardColor,
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => BottomBarView(
                  //       navigation: '3',
                  //     ),
                  //   ),
                  //   (route) => false,
                  // );
                  // Navigator.pushNamedAndRemoveUntil(
                  //   context,
                  //  ,
                  //   (route) => false,
                  // );
                  // Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Icon(
                  Icons.chevron_left,
                  size: 30,
                ),
              ),
              title: Text(
                getTranslated("checkout", context),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )) as PreferredSizeWidget?,
      body: isRoute
          ? Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Consumer<OrderProvider>(
                          builder: (context, orderProvider, child) {
                            double deliveryCharge =
                                CheckOutHelper.getDeliveryCharge(
                              freeDeliveryType: widget.freeDeliveryType,
                              orderAmount: widget.amount,
                              distance: orderProvider.distance,
                              discount: widget.discount ?? 0,
                              configModel: configModel,
                            );

                            orderProvider.getCheckOutData?.copyWith(
                                deliveryCharge: deliveryCharge,
                                orderNote: _noteController.text);

                            return Consumer<LocationProvider>(
                              builder: (context, address, child) => Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: Dimensions.webScreenWidth,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Column(
                                              children: [
                                                // if (_branches!.isNotEmpty)
                                                // selectBranchWidget(context, orderProvider),

                                                // Address
                                                DeliveryAddressWidget(
                                                  selfPickup: selfPickup,
                                                ),

                                                // // Time Slot
                                                if (address
                                                        .selectAddressIndex !=
                                                    -1)
                                                  Column(
                                                    children: [
                                                      preferenceTimeWidget(
                                                          context,
                                                          orderProvider),
                                                      if (!ResponsiveHelper
                                                          .isDesktop(context))
                                                        DetailsWidget(
                                                          paymentList:
                                                              _activePaymentList,
                                                          noteController:
                                                              _noteController,
                                                        ),
                                                    ],
                                                  )
                                              ],
                                            ),
                                          ),
                                          if (ResponsiveHelper.isDesktop(
                                              context))
                                            Expanded(
                                              flex: 4,
                                              child: Column(children: [
                                                DetailsWidget(
                                                    paymentList:
                                                        _activePaymentList,
                                                    noteController:
                                                        _noteController),
                                                const PlaceOrderButtonWidget(),
                                              ]),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const FooterWebWidget(footerType: FooterType.sliver),
                    ],
                  ),
                ),
                if (!ResponsiveHelper.isDesktop(context))
                  const Center(
                    child: PlaceOrderButtonWidget(),
                  ),
              ],
            )
          : const NotLoggedInWidget(),
    );
  }

  CustomShadowWidget selectBranchWidget(
      BuildContext context, OrderProvider orderProvider) {
    return CustomShadowWidget(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Text(getTranslated('select_branch', context),
              style:
                  poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),
        SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
              itemCount: _branches!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () {
                      try {
                        orderProvider.setBranchIndex(index);
                        double.parse(_branches![index].latitude!);
                        _setMarkers(index);
                        // ignore: empty_catches
                      } catch (e) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                          horizontal: Dimensions.paddingSizeSmall),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == orderProvider.branchIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(_branches![index].name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsMedium.copyWith(
                            color: index == orderProvider.branchIndex
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                    ),
                  ),
                );
              },
            )),
        Container(
          height: 200,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              child: GoogleMap(
                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.parse(_branches![0].latitude!),
                      double.parse(_branches![0].longitude!),
                    ),
                    zoom: 8),
                zoomControlsEnabled: true,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) async {
                  await Geolocator.requestPermission();
                  _mapController = controller;
                  _loading = false;
                  _setMarkers(0);
                },
              ),
            ),
            _loading
                ? Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ))
                : const SizedBox(),
          ]),
        ),
      ]),
    );
  }

  preferenceTimeWidget(BuildContext context, OrderProvider orderProvider) {
    return Consumer<ExpressDeliveryProvider>(
      builder: (context, expressProvider, child) {
        bool isExpressAvailable = expressProvider.status == '1' &&
            expressProvider.deliveryCharge?.status == 'success';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Text(
                    getTranslated('preference_time', context),
                    style: poppinsBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Tooltip(
                    triggerMode: ResponsiveHelper.isDesktop(context)
                        ? null
                        : TooltipTriggerMode.tap,
                    message:
                        getTranslated('select_your_preference_time', context),
                    child: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).disabledColor,
                      size: Dimensions.paddingSizeLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection
                    CustomSingleChildListWidget(
                      scrollDirection: Axis.horizontal,
                      itemCount: isExpressAvailable ? 3 : 2,
                      itemBuilder: (index) {
                        if (!isExpressAvailable) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: index + 1,
                                  groupValue: orderProvider.selectDateSlot,
                                  onChanged: (value) => orderProvider
                                      .updateDateSlot(value as int),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  DateConverterHelper.estimatedDate(
                                      DateTime.now()
                                          .add(Duration(days: index + 1))),
                                  style: poppinsRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: index,
                                  groupValue: orderProvider.selectDateSlot,
                                  onChanged: (value) => orderProvider
                                      .updateDateSlot(value as int),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  index == 0
                                      ? getTranslated(
                                          'Express Delivery', context)
                                      : DateConverterHelper.estimatedDate(
                                          DateTime.now()
                                              .add(Duration(days: index))),
                                  style: poppinsRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),

                    // Show time slots only if a date is selected
                    if (orderProvider.selectDateSlot != -1) ...[
                      const SizedBox(height: 10),

                      // Express Time Slots
                      if (isExpressAvailable &&
                          orderProvider.selectDateSlot == 0)
                        CustomSingleChildListWidget(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderProvider.expressDeliverySlots.length,
                          itemBuilder: (index) {
                            var slot =
                                orderProvider.expressDeliverySlots[index];
                            return _buildTimeSlot(
                              context: context,
                              orderProvider: orderProvider,
                              index: index,
                              startTime: slot.startTime!,
                              endTime: slot.endTime!,
                            );
                          },
                        ),

                      // Normal Time Slots
                      if (orderProvider.selectDateSlot > 0)
                        CustomSingleChildListWidget(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderProvider.timeSlots?.length ?? 0,
                          itemBuilder: (index) => _buildTimeSlot(
                            context: context,
                            orderProvider: orderProvider,
                            index: index,
                            startTime:
                                orderProvider.timeSlots![index].startTime!,
                            endTime: orderProvider.timeSlots![index].endTime!,
                          ),
                        ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // preferenceTimeWidget(BuildContext context, OrderProvider orderProvider) {
  //   return Consumer<ExpressDeliveryProvider>(
  //     builder: (context, expressProvider, child) {
  //       bool isExpressAvailable = expressProvider.status == '1' &&
  //           expressProvider.deliveryCharge?.status == 'success';

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 8),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 16.0),
  //             child: Row(
  //               children: [
  //                 Text(
  //                   getTranslated('preference_time', context),
  //                   style: poppinsBold.copyWith(
  //                       fontSize: Dimensions.fontSizeLarge),
  //                 ),
  //                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //                 Tooltip(
  //                   triggerMode: ResponsiveHelper.isDesktop(context)
  //                       ? null
  //                       : TooltipTriggerMode.tap,
  //                   message:
  //                       getTranslated('select_your_preference_time', context),
  //                   child: Icon(
  //                     Icons.info_outline,
  //                     color: Theme.of(context).disabledColor,
  //                     size: Dimensions.paddingSizeLarge,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(16),
  //                 color: Colors.white,
  //               ),
  //               padding: const EdgeInsets.all(8.0),
  //               child: Align(
  //                 alignment:
  //                     Provider.of<LocalizationProvider>(context, listen: false)
  //                             .isLtr
  //                         ? Alignment.topLeft
  //                         : Alignment.topRight,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     CustomSingleChildListWidget(
  //                       scrollDirection: Axis.horizontal,
  //                       // Show only 2 options if express not available
  //                       itemCount: isExpressAvailable ? 3 : 2,
  //                       itemBuilder: (index) {
  //                         if (!isExpressAvailable) {
  //                           // If express not available, show only tomorrow and day after
  //                           return Padding(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 2),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Radio(
  //                                   activeColor: Theme.of(context).primaryColor,
  //                                   value: index +
  //                                       1, // Adjust index to skip express option
  //                                   groupValue: orderProvider.selectDateSlot,
  //                                   onChanged: (value) {
  //                                     walletPaid = 0;
  //                                     orderProvider.changePartialPayment();
  //                                     orderProvider.savePaymentMethod(
  //                                         index: null, method: null);
  //                                     AppConstants.deliveryCagrge =
  //                                         Provider.of<SplashProvider>(context,
  //                                                 listen: false)
  //                                             .configModel!
  //                                             .deliveryCharge!;
  //                                     print('--touched');
  //                                     orderProvider.updateDateSlot(index + 1);
  //                                   },
  //                                 ),
  //                                 const SizedBox(
  //                                     width: Dimensions.paddingSizeExtraSmall),
  //                                 Text(
  //                                   DateConverterHelper.estimatedDate(
  //                                       DateTime.now()
  //                                           .add(Duration(days: index + 1))),
  //                                   style: poppinsRegular.copyWith(
  //                                     color: Theme.of(context)
  //                                         .textTheme
  //                                         .bodyLarge
  //                                         ?.color,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         } else {
  //                           // If express available, show all options
  //                           return Padding(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 2),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Radio(
  //                                     activeColor:
  //                                         Theme.of(context).primaryColor,
  //                                     value: index,
  //                                     groupValue: orderProvider.selectDateSlot,
  //                                     onChanged: (value) {
  //                                       print('---touched');
  //                                       walletPaid = 0;
  //                                       orderProvider.changePartialPayment();
  //                                       orderProvider.savePaymentMethod(
  //                                           index: null, method: null);
  //                                       if (index == 0) {
  //                                         AppConstants.deliveryCagrge =
  //                                             expressProvider.deliveryCharge!
  //                                                 .deliveryCharge!;
  //                                       } else {
  //                                         AppConstants.deliveryCagrge =
  //                                             Provider.of<SplashProvider>(
  //                                                     context,
  //                                                     listen: false)
  //                                                 .configModel!
  //                                                 .deliveryCharge!;
  //                                       }
  //                                       orderProvider.updateDateSlot(index);
  //                                     }),
  //                                 const SizedBox(
  //                                     width: Dimensions.paddingSizeExtraSmall),
  //                                 Text(
  //                                   index == 0
  //                                       ? getTranslated(
  //                                           'Express Delivery', context)
  //                                       : DateConverterHelper.estimatedDate(
  //                                           DateTime.now()
  //                                               .add(Duration(days: index))),
  //                                   style: poppinsRegular.copyWith(
  //                                     color: Theme.of(context)
  //                                         .textTheme
  //                                         .bodyLarge
  //                                         ?.color,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         }
  //                       },
  //                     ),

  //                     // Show Express Time Slots if applicable
  //                     if (isExpressAvailable &&
  //                         orderProvider.selectDateSlot == 0)
  //                       CustomSingleChildListWidget(
  //                         scrollDirection: Axis.horizontal,
  //                         itemCount: orderProvider.expressDeliverySlots.length,
  //                         itemBuilder: (index) {
  //                           var slot =
  //                               orderProvider.expressDeliverySlots[index];
  //                           return _buildTimeSlot(
  //                             context: context,
  //                             orderProvider: orderProvider,
  //                             index: index,
  //                             startTime: slot.startTime!,
  //                             endTime: slot.endTime!,
  //                           );
  //                         },
  //                       ),

  //                     // Show Normal Time Slots
  //                     if (orderProvider.selectDateSlot != 0)
  //                       CustomSingleChildListWidget(
  //                         scrollDirection: Axis.horizontal,
  //                         itemCount: orderProvider.timeSlots?.length ?? 0,
  //                         itemBuilder: (index) => _buildTimeSlot(
  //                           context: context,
  //                           orderProvider: orderProvider,
  //                           index: index,
  //                           startTime:
  //                               orderProvider.timeSlots![index].startTime!,
  //                           endTime: orderProvider.timeSlots![index].endTime!,
  //                         ),
  //                       ),

  //                     const SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildTimeSlot({
    required BuildContext context,
    required OrderProvider orderProvider,
    required int index,
    required String startTime,
    required String endTime,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: () => orderProvider.updateTimeSlot(index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeSmall,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: orderProvider.selectTimeSlot == index
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                spreadRadius: .5,
                blurRadius: .5,
              )
            ],
            border: Border.all(
              color: orderProvider.selectTimeSlot == index
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: orderProvider.selectTimeSlot == index
                    ? Theme.of(context).cardColor
                    : Theme.of(context).textTheme.bodyLarge!.color!,
                size: 20,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '${DateConverterHelper.stringToStringTime(startTime, context)} - ${DateConverterHelper.stringToStringTime(endTime, context)}',
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: orderProvider.selectTimeSlot == index
                      ? Theme.of(context).cardColor
                      : Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // preferenceTimeWidget(BuildContext context, OrderProvider orderProvider) {
  //   return Consumer<ExpressDeliveryProvider>(
  //       builder: (context, expressProvider, child) {
  //     int? num = 0;

  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 16.0),
  //           child: Row(
  //             children: [
  //               Text(
  //                 getTranslated('preference_time', context),
  //                 style: poppinsBold.copyWith(
  //                   fontSize: Dimensions.fontSizeLarge,
  //                 ),
  //               ),
  //               const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //               Tooltip(
  //                 triggerMode: ResponsiveHelper.isDesktop(context)
  //                     ? null
  //                     : TooltipTriggerMode.tap,
  //                 message:
  //                     getTranslated('select_your_preference_time', context),
  //                 child: Icon(
  //                   Icons.info_outline,
  //                   color: Theme.of(context).disabledColor,
  //                   size: Dimensions.paddingSizeLarge,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               color: Colors.white,
  //             ),
  //             padding: const EdgeInsets.all(8.0),
  //             child: Align(
  //               alignment:
  //                   Provider.of<LocalizationProvider>(context, listen: false)
  //                           .isLtr
  //                       ? Alignment.topLeft
  //                       : Alignment.topRight,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomSingleChildListWidget(
  //                     scrollDirection: Axis.horizontal,
  //                     itemCount: 3, // Max options (Express, Normal, Estimated)
  //                     itemBuilder: (index) {
  //                       // Express Delivery Slot Handling
  //                       if (expressProvider.status != '1' && index == 0) {
  //                         // If express delivery is not available, skip
  //                         return const SizedBox.shrink();
  //                       }

  //                       // Show Express Delivery Slot
  //                       if (expressProvider.status == '1' &&
  //                           index == 0 &&
  //                           expressProvider.deliveryCharge!.status ==
  //                               'success') {
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(horizontal: 2),
  //                           child: Row(
  //                             children: [
  //                               Radio(
  //                                 activeColor: Theme.of(context).primaryColor,
  //                                 value: index,
  //                                 groupValue: orderProvider.selectDateSlot,
  //                                 onChanged: (value) async {
  //                                   orderProvider.updateDateSlot(index);
  //                                 },
  //                               ),
  //                               const SizedBox(
  //                                   width: Dimensions.paddingSizeExtraSmall),
  //                               Text(
  //                                 getTranslated('Express Delivery', context),
  //                                 style: poppinsRegular.copyWith(
  //                                   color: Theme.of(context)
  //                                       .textTheme
  //                                       .bodyLarge
  //                                       ?.color,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       }

  //                       // Handle Normal and Estimated Delivery
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 2),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             Radio(
  //                               activeColor: Theme.of(context).primaryColor,
  //                               value: index,
  //                               groupValue: orderProvider.selectDateSlot,
  //                               onChanged: (value) =>
  //                                   orderProvider.updateDateSlot(index),
  //                             ),
  //                             const SizedBox(
  //                                 width: Dimensions.paddingSizeExtraSmall),
  //                             Text(
  //                               index == 0 &&
  //                                       expressProvider
  //                                               .deliveryCharge!.status ==
  //                                           'success'
  //                                   ? getTranslated('Express Delivery', context)
  //                                   : index == 1
  //                                       ? DateConverterHelper.estimatedDate(
  //                                           DateTime.now()
  //                                               .add(const Duration(days: 1)))
  //                                       : DateConverterHelper.estimatedDate(
  //                                           DateTime.now()
  //                                               .add(const Duration(days: 2))),
  //                               style: poppinsRegular.copyWith(
  //                                 color: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge
  //                                     ?.color,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                   // Display Express Delivery Time Slots if available
  //                   if (expressProvider.status == '1' &&
  //                       orderProvider.selectDateSlot == 0 &&
  //                       orderProvider.expressDeliverySlots.isNotEmpty)
  //                     CustomSingleChildListWidget(
  //                       scrollDirection: Axis.horizontal,
  //                       itemCount: orderProvider.expressDeliverySlots.length,
  //                       itemBuilder: (index) {
  //                         print('new num---------$num');
  //                         var slot = orderProvider.expressDeliverySlots[index];
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: Dimensions.paddingSizeSmall),
  //                           child: InkWell(
  //                             onTap: () => orderProvider.updateTimeSlot(index),
  //                             child: Container(
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: Dimensions.paddingSizeSmall,
  //                                 horizontal: Dimensions.paddingSizeSmall,
  //                               ),
  //                               alignment: Alignment.center,
  //                               decoration: BoxDecoration(
  //                                 color: orderProvider.selectTimeSlot == index
  //                                     ? Theme.of(context).primaryColor
  //                                     : Theme.of(context).cardColor,
  //                                 borderRadius: BorderRadius.circular(
  //                                     Dimensions.radiusSizeDefault),
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Theme.of(context).shadowColor,
  //                                     spreadRadius: .5,
  //                                     blurRadius: .5,
  //                                   )
  //                                 ],
  //                                 border: Border.all(
  //                                   color: orderProvider.selectTimeSlot == index
  //                                       ? Theme.of(context).primaryColor
  //                                       : Theme.of(context)
  //                                           .textTheme
  //                                           .bodyLarge!
  //                                           .color!,
  //                                 ),
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Icon(Icons.history,
  //                                       color: orderProvider.selectTimeSlot ==
  //                                               index
  //                                           ? Theme.of(context).cardColor
  //                                           : Theme.of(context)
  //                                               .textTheme
  //                                               .bodyLarge!
  //                                               .color!,
  //                                       size: 20),
  //                                   const SizedBox(
  //                                       width:
  //                                           Dimensions.paddingSizeExtraSmall),
  //                                   Text(
  //                                     '${DateConverterHelper.stringToStringTime(slot.startTime!, context)} - ${DateConverterHelper.stringToStringTime(slot.endTime!, context)}',
  //                                     style: poppinsRegular.copyWith(
  //                                       fontSize: Dimensions.fontSizeLarge,
  //                                       color: orderProvider.selectTimeSlot ==
  //                                               index
  //                                           ? Theme.of(context).cardColor
  //                                           : Theme.of(context)
  //                                               .textTheme
  //                                               .bodyLarge!
  //                                               .color!,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   // Handle Other Time Slots for Normal and Estimated Delivery
  //                   CustomSingleChildListWidget(
  //                     scrollDirection: Axis.horizontal,
  //                     itemCount: orderProvider.timeSlots?.length ?? 0,
  //                     itemBuilder: (index) {
  //                       if (orderProvider.selectDateSlot == 0) {
  //                         // Skip rendering for Express Delivery
  //                         return const SizedBox.shrink();
  //                       }
  //                       num = num! + 1;
  //                       print('new num1----------$num');
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: Dimensions.paddingSizeSmall),
  //                         child: InkWell(
  //                           onTap: () => orderProvider.updateTimeSlot(index),
  //                           child: Container(
  //                             padding: const EdgeInsets.symmetric(
  //                                 vertical: Dimensions.paddingSizeSmall,
  //                                 horizontal: Dimensions.paddingSizeSmall),
  //                             alignment: Alignment.center,
  //                             decoration: BoxDecoration(
  //                               color: orderProvider.selectTimeSlot == index
  //                                   ? Theme.of(context).primaryColor
  //                                   : Theme.of(context).cardColor,
  //                               borderRadius: BorderRadius.circular(
  //                                   Dimensions.radiusSizeDefault),
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Theme.of(context).shadowColor,
  //                                   spreadRadius: .5,
  //                                   blurRadius: .5,
  //                                 )
  //                               ],
  //                               border: Border.all(
  //                                 color: orderProvider.selectTimeSlot == index
  //                                     ? Theme.of(context).primaryColor
  //                                     : Theme.of(context)
  //                                         .textTheme
  //                                         .bodyLarge!
  //                                         .color!,
  //                               ),
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Icon(Icons.history,
  //                                     color:
  //                                         orderProvider.selectTimeSlot == index
  //                                             ? Theme.of(context).cardColor
  //                                             : Theme.of(context)
  //                                                 .textTheme
  //                                                 .bodyLarge!
  //                                                 .color!,
  //                                     size: 20),
  //                                 const SizedBox(
  //                                     width: Dimensions.paddingSizeExtraSmall),
  //                                 Text(
  //                                   '${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].startTime!, context)} - ${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].endTime!, context)}',
  //                                   style: poppinsRegular.copyWith(
  //                                     fontSize: Dimensions.fontSizeLarge,
  //                                     color:
  //                                         orderProvider.selectTimeSlot == index
  //                                             ? Theme.of(context).cardColor
  //                                             : Theme.of(context)
  //                                                 .textTheme
  //                                                 .bodyLarge!
  //                                                 .color!,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                   const SizedBox(height: 20),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  // preferenceTimeWidget(BuildContext context, OrderProvider orderProvider) {
  //   return Consumer<ExpressDeliveryProvider>(
  //       builder: (context, expressProvider, child) {
  //     int num = 0;
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 16.0),
  //           child: Row(
  //             children: [
  //               Text(
  //                 getTranslated('preference_time', context),
  //                 style: poppinsBold.copyWith(
  //                   fontSize: Dimensions.fontSizeLarge,
  //                 ),
  //               ),
  //               const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //               Tooltip(
  //                 triggerMode: ResponsiveHelper.isDesktop(context)
  //                     ? null
  //                     : TooltipTriggerMode.tap,
  //                 message:
  //                     getTranslated('select_your_preference_time', context),
  //                 child: Icon(Icons.info_outline,
  //                     color: Theme.of(context).disabledColor,
  //                     size: Dimensions.paddingSizeLarge),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               color: Colors.white,
  //             ),
  //             padding: const EdgeInsets.all(8.0),
  //             child: Align(
  //               alignment:
  //                   Provider.of<LocalizationProvider>(context, listen: false)
  //                           .isLtr
  //                       ? Alignment.topLeft
  //                       : Alignment.topRight,
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     CustomSingleChildListWidget(
  //                       scrollDirection: Axis.horizontal,
  //                       itemCount:
  //                           3, // Max options (Express, Normal, Estimated)
  //                       itemBuilder: (index) {
  //                         num = index;
  //                         if (expressProvider.status != '1' && index == 1) {
  //                           // If status is not '1', skip Normal Delivery option
  //                           return const SizedBox.shrink();
  //                         }
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(horizontal: 2),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               Radio(
  //                                 activeColor: Theme.of(context).primaryColor,
  //                                 value: index,
  //                                 groupValue: orderProvider.selectDateSlot,
  //                                 onChanged: (value) =>
  //                                     orderProvider.updateDateSlot(index),
  //                               ),
  //                               const SizedBox(
  //                                   width: Dimensions.paddingSizeExtraSmall),
  //                               Text(
  //                                 index == 0
  //                                     ? (expressProvider.status == '1'
  //                                         ? getTranslated(
  //                                             'Express Delivery', context)
  //                                         : DateConverterHelper.estimatedDate(
  //                                             DateTime.now().add(
  //                                                 const Duration(days: 1))))
  //                                     : index == 1
  //                                         ? DateConverterHelper.estimatedDate(
  //                                             DateTime.now()
  //                                                 .add(const Duration(days: 1)))
  //                                         : DateConverterHelper.estimatedDate(
  //                                             DateTime.now().add(
  //                                                 const Duration(days: 2))),
  //                                 style: poppinsRegular.copyWith(
  //                                   color: Theme.of(context)
  //                                       .textTheme
  //                                       .bodyLarge
  //                                       ?.color,
  //                                 ),
  //                               ),
  //                               const SizedBox(
  //                                   width: Dimensions.paddingSizeExtraSmall),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),

  //                     // CustomSingleChildListWidget(
  //                     //   scrollDirection: Axis.horizontal,
  //                     //   itemCount: 3,
  //                     //   itemBuilder: (index) {
  //                     //     return Padding(
  //                     //       padding: const EdgeInsets.symmetric(horizontal: 2),
  //                     //       child: Row(
  //                     //         mainAxisAlignment: MainAxisAlignment.start,
  //                     //         children: [
  //                     //           Radio(
  //                     //             activeColor: Theme.of(context).primaryColor,
  //                     //             value: index,
  //                     //             groupValue: orderProvider.selectDateSlot,
  //                     //             onChanged: (value) =>
  //                     //                 orderProvider.updateDateSlot(index),
  //                     //           ),
  //                     //           const SizedBox(
  //                     //               width: Dimensions.paddingSizeExtraSmall),
  //                     //           Text(
  //                     //             index == 0
  //                     //                 ? (expressProvider.status == '1'
  //                     //                     ? getTranslated(
  //                     //                         'Express Delivery', context)
  //                     //                     : getTranslated(
  //                     //                         'Normal Delivery', context))
  //                     //                 : index == 1
  //                     //                     ? DateConverterHelper.estimatedDate(
  //                     //                         DateTime.now()
  //                     //                             .add(const Duration(days: 1)))
  //                     //                     : DateConverterHelper.estimatedDate(
  //                     //                         DateTime.now().add(
  //                     //                             const Duration(days: 2))),
  //                     //             style: poppinsRegular.copyWith(
  //                     //               color: Theme.of(context)
  //                     //                   .textTheme
  //                     //                   .bodyLarge
  //                     //                   ?.color,
  //                     //             ),
  //                     //           ),
  //                     //           const SizedBox(
  //                     //               width: Dimensions.paddingSizeExtraSmall),
  //                     //         ],
  //                     //       ),
  //                     //     );
  //                     //   },
  //                     // ),
  //                     // const SizedBox(height: Dimensions.paddingSizeDefault),
  //                     orderProvider.timeSlots == null
  //                         ? CustomLoaderWidget(
  //                             color: Theme.of(context).primaryColor)
  //                         : CustomSingleChildListWidget(
  //                             scrollDirection: Axis.horizontal,
  //                             itemCount: orderProvider.timeSlots?.length ?? 0,
  //                             itemBuilder: (index) {
  //                               return Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: Dimensions.paddingSizeSmall),
  //                                 child: InkWell(
  //                                   hoverColor: Colors.transparent,
  //                                   onTap: () =>
  //                                       orderProvider.updateTimeSlot(index),
  //                                   child: (num == 0 &&
  //                                           expressProvider.status == '1')
  //                                       ? SizedBox()
  //                                       : Container(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               vertical:
  //                                                   Dimensions.paddingSizeSmall,
  //                                               horizontal: Dimensions
  //                                                   .paddingSizeSmall),
  //                                           alignment: Alignment.center,
  //                                           decoration: BoxDecoration(
  //                                             color: orderProvider
  //                                                         .selectTimeSlot ==
  //                                                     index
  //                                                 ? Theme.of(context)
  //                                                     .primaryColor
  //                                                 : Theme.of(context).cardColor,
  //                                             borderRadius:
  //                                                 BorderRadius.circular(
  //                                                     Dimensions
  //                                                         .radiusSizeDefault),
  //                                             boxShadow: [
  //                                               BoxShadow(
  //                                                 color: Theme.of(context)
  //                                                     .shadowColor,
  //                                                 spreadRadius: .5,
  //                                                 blurRadius: .5,
  //                                               )
  //                                             ],
  //                                             border: Border.all(
  //                                               color: orderProvider
  //                                                           .selectTimeSlot ==
  //                                                       index
  //                                                   ? Theme.of(context)
  //                                                       .primaryColor
  //                                                   : Theme.of(context)
  //                                                       .textTheme
  //                                                       .bodyLarge!
  //                                                       .color!,
  //                                             ),
  //                                           ),
  //                                           child: Row(
  //                                             children: [
  //                                               Icon(Icons.history,
  //                                                   color: orderProvider
  //                                                               .selectTimeSlot ==
  //                                                           index
  //                                                       ? Theme.of(context)
  //                                                           .cardColor
  //                                                       : Theme.of(context)
  //                                                           .textTheme
  //                                                           .bodyLarge!
  //                                                           .color!,
  //                                                   size: 20),
  //                                               const SizedBox(
  //                                                   width: Dimensions
  //                                                       .paddingSizeExtraSmall),
  //                                               Text(
  //                                                 '${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].startTime!, context)} '
  //                                                 '- ${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].endTime!, context)}',
  //                                                 style:
  //                                                     poppinsRegular.copyWith(
  //                                                   fontSize: Dimensions
  //                                                       .fontSizeLarge,
  //                                                   color: orderProvider
  //                                                               .selectTimeSlot ==
  //                                                           index
  //                                                       ? Theme.of(context)
  //                                                           .cardColor
  //                                                       : Theme.of(context)
  //                                                           .textTheme
  //                                                           .bodyLarge!
  //                                                           .color!,
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                     const SizedBox(height: 20),
  //                   ]),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }
  // preferenceTimeWidget(BuildContext context, OrderProvider orderProvider) {
  //   DateTime now = DateTime.now();
  //   DateTime today5PM = DateTime(now.year, now.month, now.day, 22);
  //   DateTime tomorrow = now.add(Duration(days: 1));
  //   DateTime dayAfterTomorrow = now.add(Duration(days: 2));
  //   DateTime twoDaysAfterTomorrow = now.add(Duration(days: 3));

  //   return Consumer<ExpressDeliveryProvider>(
  //       builder: (context, expressProvider, child) {
  //     print('delivery status-----------${expressProvider.status}');
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 16.0),
  //           child: Row(
  //             children: [
  //               Text(
  //                 getTranslated('preference_time', context),
  //                 style: poppinsBold.copyWith(
  //                   fontSize: Dimensions.fontSizeLarge,
  //                 ),
  //               ),
  //               const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //               Tooltip(
  //                 triggerMode: ResponsiveHelper.isDesktop(context)
  //                     ? null
  //                     : TooltipTriggerMode.tap,
  //                 message:
  //                     getTranslated('select_your_preference_time', context),
  //                 child: Icon(Icons.info_outline,
  //                     color: Theme.of(context).disabledColor,
  //                     size: Dimensions.paddingSizeLarge),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               color: Colors.white,
  //             ),
  //             padding: const EdgeInsets.all(8.0),
  //             child: Align(
  //               alignment:
  //                   Provider.of<LocalizationProvider>(context, listen: false)
  //                           .isLtr
  //                       ? Alignment.topLeft
  //                       : Alignment.topRight,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomSingleChildListWidget(
  //                     scrollDirection: Axis.horizontal,
  //                     itemCount: now.isBefore(today5PM)
  //                         ? 3
  //                         : 2, // Show 3 options before 5 PM, otherwise 2
  //                     itemBuilder: (index) {
  //                       String displayText;

  //                       // Determine the text based on the index and time of day
  //                       if (now.isBefore(today5PM)) {
  //                         // Ordering before 5 PM
  //                         if (index == 0 && expressProvider.status == '1') {
  //                           displayText =
  //                               getTranslated('Express Delivery', context);
  //                           // displayText = getTranslated(
  //                           //     'Delivery will be tomorrow ${DateFormat('dd MMM yyyy').format(tomorrow)}',
  //                           //     context);
  //                         } else if (index == 1) {
  //                           displayText = DateConverterHelper.estimatedDate(
  //                               tomorrow); // "Day After Tomorrow"
  //                         } else {
  //                           displayText = DateConverterHelper.estimatedDate(
  //                               dayAfterTomorrow); // "Two Days After Tomorrow"
  //                         }
  //                       } else {
  //                         // Ordering after 5 PM
  //                         if (index == 5) {
  //                           displayText = DateConverterHelper.estimatedDate(
  //                               dayAfterTomorrow); // "Day After Tomorrow"
  //                         } else {
  //                           displayText = DateConverterHelper.estimatedDate(
  //                               twoDaysAfterTomorrow); // "Two Days After Tomorrow"
  //                         }
  //                       }

  //                       return displayText.isNotEmpty
  //                           ? Padding(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 2),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.start,
  //                                 children: [
  //                                   Radio(
  //                                     activeColor:
  //                                         Theme.of(context).primaryColor,
  //                                     value: index,
  //                                     groupValue: orderProvider.selectDateSlot,
  //                                     onChanged: (value) =>
  //                                         orderProvider.updateDateSlot(index),
  //                                   ),
  //                                   const SizedBox(
  //                                       width:
  //                                           Dimensions.paddingSizeExtraSmall),
  //                                   Text(
  //                                     displayText,
  //                                     style: poppinsRegular.copyWith(
  //                                       color: Theme.of(context)
  //                                           .textTheme
  //                                           .bodyLarge
  //                                           ?.color,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(
  //                                       width:
  //                                           Dimensions.paddingSizeExtraSmall),
  //                                 ],
  //                               ),
  //                             )
  //                           : const SizedBox();
  //                     },
  //                   ),
  //                   orderProvider.timeSlots == null
  //                       ? CustomLoaderWidget(
  //                           color: Theme.of(context).primaryColor)
  //                       : CustomSingleChildListWidget(
  //                           scrollDirection: Axis.horizontal,
  //                           itemCount: orderProvider.timeSlots?.length ?? 0,
  //                           itemBuilder: (index) {
  //                             return Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                   horizontal: Dimensions.paddingSizeSmall),
  //                               child: InkWell(
  //                                 hoverColor: Colors.transparent,
  //                                 onTap: () =>
  //                                     orderProvider.updateTimeSlot(index),
  //                                 child: Container(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       vertical: Dimensions.paddingSizeSmall,
  //                                       horizontal:
  //                                           Dimensions.paddingSizeSmall),
  //                                   alignment: Alignment.center,
  //                                   decoration: BoxDecoration(
  //                                     color:
  //                                         orderProvider.selectTimeSlot == index
  //                                             ? Theme.of(context).primaryColor
  //                                             : Theme.of(context).cardColor,
  //                                     borderRadius: BorderRadius.circular(
  //                                         Dimensions.radiusSizeDefault),
  //                                     boxShadow: [
  //                                       BoxShadow(
  //                                         color: Theme.of(context).shadowColor,
  //                                         spreadRadius: .5,
  //                                         blurRadius: .5,
  //                                       )
  //                                     ],
  //                                     border: Border.all(
  //                                       color: orderProvider.selectTimeSlot ==
  //                                               index
  //                                           ? Theme.of(context).primaryColor
  //                                           : Theme.of(context)
  //                                               .textTheme
  //                                               .bodyLarge!
  //                                               .color!,
  //                                     ),
  //                                   ),
  //                                   child: Row(
  //                                     children: [
  //                                       Icon(Icons.history,
  //                                           color: orderProvider
  //                                                       .selectTimeSlot ==
  //                                                   index
  //                                               ? Theme.of(context).cardColor
  //                                               : Theme.of(context)
  //                                                   .textTheme
  //                                                   .bodyLarge!
  //                                                   .color!,
  //                                           size: 20),
  //                                       const SizedBox(
  //                                           width: Dimensions
  //                                               .paddingSizeExtraSmall),
  //                                       Text(
  //                                         '${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].startTime!, context)} '
  //                                         '- ${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].endTime!, context)}',
  //                                         style: poppinsRegular.copyWith(
  //                                           fontSize: Dimensions.fontSizeLarge,
  //                                           color: orderProvider
  //                                                       .selectTimeSlot ==
  //                                                   index
  //                                               ? Theme.of(context).cardColor
  //                                               : Theme.of(context)
  //                                                   .textTheme
  //                                                   .bodyLarge!
  //                                                   .color!,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                   const SizedBox(height: 20),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  Future<void> initLoading() async {
    final OrderProvider orderProvider =
        Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final OrderImageNoteProvider orderImageNoteProvider =
        Provider.of<OrderImageNoteProvider>(context, listen: false);

    orderProvider.clearPrevData();
    orderImageNoteProvider.onPickImage(true, isUpdate: false);
    splashProvider.getOfflinePaymentMethod(true);

    _isLoggedIn = authProvider.isLoggedIn();
    final bool isGuestCheckout =
        (splashProvider.configModel!.isGuestCheckout!) &&
            authProvider.getGuestId() != null;
    selfPickup = CheckOutHelper.isSelfPickup(orderType: widget.orderType ?? '');
    orderProvider.setOrderType(widget.orderType, notify: false);

    orderProvider.setCheckOutData = CheckOutModel(
      itemDiscount: widget.itemDiscount ?? 0.0,
      orderType: widget.orderType,
      deliveryCharge: widget.amount < AppConstants.mimimumOrderValue &&
              Provider.of<CouponProvider>(context, listen: false)
                      .freeDeliveryCoupon ==
                  false
          ? AppConstants.deliveryCagrge
          : 0,
      // deliveryCharge: widget.amount < AppConstants.mimimumOrderValue
      //     ? AppConstants.deliveryCagrge
      //     : 0,
      freeDeliveryType: widget.freeDeliveryType,
      amount: widget.amount,
      placeOrderDiscount: widget.discount,
      couponCode: widget.couponCode,
      orderNote: null,
    );

    if (_isLoggedIn || isGuestCheckout) {
      orderProvider.setAddressIndex(-1, notify: false);
      orderProvider.initializeTimeSlot();
      _branches = splashProvider.configModel!.branches;

      await locationProvider.initAddressList();
      AddressModel? lastOrderedAddress;

      if (_isLoggedIn && widget.orderType == 'delivery') {
        lastOrderedAddress = await locationProvider.getLastOrderedAddress();
      }

      CheckOutHelper.selectDeliveryAddressAuto(
          orderType: widget.orderType,
          isLoggedIn: (_isLoggedIn || isGuestCheckout),
          lastAddress: lastOrderedAddress);
    }
    _activePaymentList = CheckOutHelper.getActivePaymentList(
        configModel: splashProvider.configModel!);
  }

  void _setMarkers(int selectedIndex) async {
    late BitmapDescriptor bitmapDescriptor;
    late BitmapDescriptor bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(25, 30)),
            Images.restaurantMarker)
        .then((marker) {
      bitmapDescriptor = marker;
    });
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(20, 20)),
            Images.unselectedRestaurantMarker)
        .then((marker) {
      bitmapDescriptorUnSelect = marker;
    });
    // Marker
    _markers = HashSet<Marker>();
    for (int index = 0; index < _branches!.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.tryParse(_branches![index].latitude!)!,
            double.tryParse(_branches![index].longitude!)!),
        infoWindow: InfoWindow(
            title: _branches![index].name, snippet: _branches![index].address),
        icon: selectedIndex == index
            ? bitmapDescriptor
            : bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          double.tryParse(_branches![selectedIndex].latitude!)!,
          double.tryParse(_branches![selectedIndex].longitude!)!,
        ),
        zoom: ResponsiveHelper.isMobile() ? 12 : 16)));

    setState(() {});
  }
}
