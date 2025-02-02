// class CheckoutScreen extends StatefulWidget {
//   final double amount;
//   final double itemDiscount;
//   final String? orderType;
//   final double? discount;
//   final String? couponCode;
//   final String freeDeliveryType;
//   final double deliveryCharge;
//   const CheckoutScreen(
//       {Key? key,
//       required this.itemDiscount,
//       required this.amount,
//       required this.orderType,
//       required this.discount,
//       required this.couponCode,
//       required this.freeDeliveryType,
//       required this.deliveryCharge})
//       : super(key: key);

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
//   final TextEditingController _noteController = TextEditingController();
//   late GoogleMapController _mapController;
//   List<Branches>? _branches = [];
//   bool _loading = true;
//   Set<Marker> _markers = HashSet<Marker>();
//   late bool _isLoggedIn;
//   List<PaymentMethod> _activePaymentList = [];
//   late bool selfPickup;

//   @override
//   void initState() {
//     initLoading();

//     final walletProvide =
//         Provider.of<WalletAndLoyaltyProvider>(context, listen: false);
//     Provider.of<ExpressDeliveryProvider>(context, listen: false)
//         .expressDeliveryStatus();
//     Provider.of<OrderProvider>(context, listen: false)
//         .fetchExpressDeliverySlots();
//     walletProvide.setCurrentTabButton(0, isUpdate: false);
//     walletProvide.insertFilterList();
//     walletProvide.setWalletFilerType('all', isUpdate: false);

 

//     if (_isLoggedIn) {
//       walletProvide.getWalletBonusList(false);
//       Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo();
//       walletProvide.getLoyaltyTransactionList('1', false, true,
//           isEarning: walletProvide.selectedTabButtonIndex == 1);

    
//     }
//     super.initState();

//     // initLoading();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AuthProvider authProvider =
//         Provider.of<AuthProvider>(context, listen: false);
//     final ConfigModel configModel =
//         Provider.of<SplashProvider>(context, listen: false).configModel!;

//     final bool isRoute = (_isLoggedIn ||
//         (configModel.isGuestCheckout! && authProvider.getGuestId() != null));

//     return Scaffold(
//       backgroundColor: ColorResources.scaffoldGrey,
//       key: _scaffoldKey,
//       resizeToAvoidBottomInset: true,
//       appBar: (ResponsiveHelper.isDesktop(context)
//           ? const PreferredSize(
//               preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
//           : AppBar(
//               scrolledUnderElevation: 0,
//               backgroundColor: Theme.of(context).cardColor,
//               centerTitle: true,
//               leading: GestureDetector(
//                 onTap: () {
                
//                   Navigator.popUntil(context, (route) => route.isFirst);
//                 },
//                 child: const Icon(
//                   Icons.chevron_left,
//                   size: 30,
//                 ),
//               ),
//               title: Text(
//                 getTranslated("checkout", context),
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//             )) as PreferredSizeWidget?,
//       body: isRoute
//           ? Column(
//               children: [
//                 Expanded(
//                   child: CustomScrollView(
//                     slivers: [
//                       SliverToBoxAdapter(
//                         child: Consumer<OrderProvider>(
//                           builder: (context, orderProvider, child) {
//                             double deliveryCharge =
//                                 CheckOutHelper.getDeliveryCharge(
//                               freeDeliveryType: widget.freeDeliveryType,
//                               orderAmount: widget.amount,
//                               distance: orderProvider.distance,
//                               discount: widget.discount ?? 0,
//                               configModel: configModel,
//                             );

//                             orderProvider.getCheckOutData?.copyWith(
//                                 deliveryCharge: deliveryCharge,
//                                 orderNote: _noteController.text);

//                             return Consumer<LocationProvider>(
//                               builder: (context, address, child) => Column(
//                                 children: [
//                                   Center(
//                                     child: SizedBox(
//                                       width: Dimensions.webScreenWidth,
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Expanded(
//                                             flex: 6,
//                                             child: Column(
//                                               children: [
//                                                 // if (_branches!.isNotEmpty)
//                                                 // selectBranchWidget(context, orderProvider),

//                                                 // Address
//                                                 DeliveryAddressWidget(
//                                                   selfPickup: selfPickup,
//                                                 ),

//                                                 // // Time Slot
//                                                 preferenceTimeWidget(
//                                                     context, orderProvider),

//                                                 if (!ResponsiveHelper.isDesktop(
//                                                     context))
//                                                   DetailsWidget(
//                                                     paymentList:
//                                                         _activePaymentList,
//                                                     noteController:
//                                                         _noteController,
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                           if (ResponsiveHelper.isDesktop(
//                                               context))
//                                             Expanded(
//                                               flex: 4,
//                                               child: Column(children: [
//                                                 DetailsWidget(
//                                                     paymentList:
//                                                         _activePaymentList,
//                                                     noteController:
//                                                         _noteController),
//                                                 const PlaceOrderButtonWidget(),
//                                               ]),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const FooterWebWidget(footerType: FooterType.sliver),
//                     ],
//                   ),
//                 ),
//                 if (!ResponsiveHelper.isDesktop(context))
//                   const Center(
//                     child: PlaceOrderButtonWidget(),
//                   ),
//               ],
//             )
//           : const NotLoggedInWidget(),
//     );
//   }