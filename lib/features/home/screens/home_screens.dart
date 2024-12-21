import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/providers/localization_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/title_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/checkout/provider/exprees_deliver_provider.dart';
import 'package:flutter_grocery/features/home/providers/banner_provider.dart';
import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
import 'package:flutter_grocery/features/home/screens/all_brands_screen.dart';
import 'package:flutter_grocery/features/home/screens/brand_products_screen.dart';
import 'package:flutter_grocery/features/home/widgets/banners_widget.dart';
import 'package:flutter_grocery/features/home/widgets/category_web_widget.dart';
import 'package:flutter_grocery/features/home/widgets/flash_deal_home_card_widget.dart';
import 'package:flutter_grocery/features/home/widgets/home_item_widget.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(bool reload, BuildContext context,
      {bool fromRefresh = false, bool fromLanguage = false}) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final flashDealProvider =
        Provider.of<FlashDealProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withListProvider =
        Provider.of<WishListProvider>(context, listen: false);
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false);
    // Provider.of<ExpressDeliveryProvider>(context, listen: false)
    //     .expressDeliveryStatus();
    ConfigModel config =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    // Only reload on explicit requests
    if (!fromRefresh) return;

    if (reload) {
      Provider.of<SplashProvider>(context, listen: false).initConfig();
    }

    if (reload || !(categoryProvider.categoryList?.isNotEmpty ?? false)) {
      await categoryProvider.getCategoryList(context, reload);
    }

    if (reload || (bannerProvider.bannerList?.isEmpty ?? true)) {
      await bannerProvider.getBannerList(context, reload);
    }

    if (productProvider.dailyProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.dailyItem);
    }

    if (productProvider.featuredProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.featuredItem);
    }

    if (productProvider.mostViewedProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.mostReviewed);
    }

    productProvider.getAllProductList(1, reload, isUpdate: false);

    productProvider.getAllBrands();

    if (authProvider.isLoggedIn()) {
      withListProvider.getWishListProduct();
    }

    if ((config.flashDealProductStatus ?? false) &&
        flashDealProvider.flashDealModel == null) {
      flashDealProvider.getFlashDealProducts(1, isUpdate: false);
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  bool _dataLoaded = false; // Flag to prevent duplicate API calls

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
  }

  Future<void> _loadInitialData() async {
    if (!_dataLoaded) {
      await HomeScreen.loadData(false, context, fromRefresh: true);
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final CategoryProvider categoryProvider =
    //     Provider.of<CategoryProvider>(context, listen: false);
    return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
      AppConstants.mimimumOrderValue =
          splashProvider.configModel!.freeDeliveryOverAmount!;
      AppConstants.deliveryCagrge = splashProvider.configModel!.deliveryCharge!;
      print(
          '----------------------------------minimumorder${AppConstants.mimimumOrderValue}');
      print(
          '----------------------------------deliverchatge${AppConstants.deliveryCagrge}');
      return RefreshIndicator(
        onRefresh: () async {
          // Explicit refresh via RefreshIndicator
          await HomeScreen.loadData(true, context, fromRefresh: true);
          setState(() {
            _dataLoaded = true; // Reset the flag after refresh
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Scaffold(
          appBar: ResponsiveHelper.isDesktop(context)
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
              : null,
          body: CustomScrollView(controller: scrollController, slivers: [
            SliverToBoxAdapter(
                child: Center(
                    child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Column(children: [
                searchBarWidget(),
                Consumer<BannerProvider>(builder: (context, banner, child) {
                  return (banner.bannerList?.isEmpty ?? false)
                      ? const SizedBox()
                      : const BannersWidget();
                }),

                /// Category

                Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeLarge
                        : Dimensions.paddingSizeSmall,
                  ),
                  child: const CategoryWidget(),
                ),

                /// Flash Deal
                if (splashProvider.configModel?.flashDealProductStatus ?? false)
                  const FlashDealHomeCardWidget(),

                Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                  bool isDailyProduct =
                      (productProvider.dailyProductModel == null ||
                          (productProvider
                                  .dailyProductModel?.products?.isNotEmpty ??
                              false));
                  bool isFeaturedProduct =
                      (productProvider.featuredProductModel == null ||
                          (productProvider
                                  .featuredProductModel?.products?.isNotEmpty ??
                              false));
                  bool isMostViewedProduct =
                      (productProvider.mostViewedProductModel == null ||
                          (productProvider.mostViewedProductModel?.products
                                  ?.isNotEmpty ??
                              false));

                  return Column(children: [
                    if ((splashProvider
                                .configModel?.mostReviewedProductStatus ??
                            false) &&
                        isMostViewedProduct)
                      Column(children: [
                        TitleWidget(
                            title: getTranslated("Top Seller", context),
                            onTap: () {
                              Navigator.pushNamed(
                                  context,
                                  RouteHelper.getHomeItemRoute(
                                      ProductType.mostReviewed));
                            }),
                        HomeItemWidget(
                            productList: productProvider
                                .mostViewedProductModel?.products),
                      ]),
                    isDailyProduct
                        ? Column(children: [
                            TitleWidget(
                                title: getTranslated('Best deals', context),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context,
                                      RouteHelper.getHomeItemRoute(
                                          ProductType.dailyItem));
                                }),
                            HomeItemWidget(
                                productList: productProvider
                                    .dailyProductModel?.products),
                          ])
                        : const SizedBox(),
                    if ((splashProvider.configModel?.featuredProductStatus ??
                            false) &&
                        isFeaturedProduct)
                      Column(children: [
                        TitleWidget(
                            title: getTranslated("Promotions", context),
                            onTap: () {
                              Navigator.pushNamed(
                                  context,
                                  RouteHelper.getHomeItemRoute(
                                      ProductType.featuredItem));
                            }),
                        LimitedBox(
                          maxHeight: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Container(
                                height: 250,
                                width: 165,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/promotion_${(index % 2) + 1}.png'),
                                  ),
                                ),
                              ),
                            ),
                            itemCount: 4,
                          ),
                        )
                      ]),
                  ]);
                }),
                // if (categoryProvider.categoryList!
                //         .firstWhere(
                //           (element) =>
                //               element.name!.toLowerCase().contains("fruit"),
                //           orElse: () => CategoryModel(),
                //         )
                //         .id !=
                //     null)
                //   TitleWidget(
                //     title: getTranslated('Organic Products', context),
                //   ),
                // if (categoryProvider.categoryList!
                //         .firstWhere(
                //           (element) =>
                //               element.name!.toLowerCase().contains("fruit"),
                //           orElse: () => CategoryModel(),
                //         )
                //         .id !=
                //     null)
                // Consumer<CategoryProvider>(
                //   builder: (context, value, child) {
                //     // Get the first 10 items if the list has more than 10, otherwise use the whole list
                //     final categoryProducts =
                //         value.categoryProductList.length > 10
                //             ? value.categoryProductList.sublist(0, 10)
                //             : value.categoryProductList;

                //     return HomeItemWidget(productList: categoryProducts);
                //   },
                // ),
                // Consumer<CategoryProvider>(
                //   builder: (context, value, child) =>
                //       HomeItemWidget(productList: value.categoryProductList),
                // ),

                Consumer<ProductProvider>(builder: (context, provider, child) {
                  return Column(
                    children: [
                      if (provider.brandsModel != null &&
                          provider.brandsModel!.data.isNotEmpty)
                        TitleWidget(
                          title: getTranslated('Shop By Brand', context),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AllBrandsScreen(),
                              ),
                            );
                          },
                        ),
                      if (provider.brandsModel != null &&
                          provider.brandsModel!.data.isNotEmpty)
                        LimitedBox(
                          maxHeight: 125,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BrandProductsScreen(
                                        brandName: provider
                                            .brandsModel!.data[index].name,
                                        brandId: provider
                                            .brandsModel!.data[index].id
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    CustomImageWidget(
                                      image: provider
                                          .brandsModel!.data[index].image,
                                      height: 85,
                                      width: 85,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      provider.brandsModel!.data[index].name,
                                      style: poppinsSemiBold.copyWith(
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            itemCount: provider.brandsModel!.data.length,
                          ),
                        ),
                      if (provider.brandsModel != null &&
                          provider.brandsModel!.data.isNotEmpty)
                        const SizedBox(height: 24),
                    ],
                  );
                }),
              ]),
            ))),
            const FooterWebWidget(footerType: FooterType.sliver),
          ]),
        ),
      );
    });
  }

  Widget searchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.pushNamed(context, RouteHelper.searchProduct);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green, // Green border
                      width: 1.0, // Border width
                    ),
                    borderRadius:
                        BorderRadius.circular(14.0), // Rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green, // Green border
                      width: 1.0, // Border width
                    ),
                    borderRadius:
                        BorderRadius.circular(14.0), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green, // Green border
                      width: 1.0, // Border width
                    ),
                    borderRadius:
                        BorderRadius.circular(16.0), // Rounded corners
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      "assets/svg/search.svg",
                    ),
                  ),
                  hintText: getTranslated("search", context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();

//   static Future<void> loadData(bool reload, BuildContext context,
//       {bool fromLanguage = false}) async {
//     final productProvider =
//         Provider.of<ProductProvider>(context, listen: false);

//     final flashDealProvider =
//         Provider.of<FlashDealProvider>(context, listen: false);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     final withListProvider =
//         Provider.of<WishListProvider>(context, listen: false);

//     final localizationProvider =
//         Provider.of<LocalizationProvider>(context, listen: false);

//     ConfigModel config =
//         Provider.of<SplashProvider>(context, listen: false).configModel!;
//     if (reload) {
//       Provider.of<SplashProvider>(context, listen: false).initConfig();
//     }
//     if (fromLanguage &&
//         (authProvider.isLoggedIn() || config.isGuestCheckout!)) {
//       localizationProvider.changeLanguage();
//     }

//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);

//     // Load category list only if not already loaded or explicitly reloaded
//     if (reload || !(categoryProvider.categoryList?.isNotEmpty ?? false)) {
//       await categoryProvider.getCategoryList(context, reload);
//     }

//     final bannerProvider = Provider.of<BannerProvider>(context, listen: false);

//     // Load banner list only if not already loaded or explicitly reloaded
//     if (reload || (bannerProvider.bannerList?.isEmpty ?? true)) {
//       await bannerProvider.getBannerList(context, reload);
//     }

//     if (productProvider.dailyProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.dailyItem);
//     }

//     if (productProvider.featuredProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.featuredItem);
//     }

//     if (productProvider.mostViewedProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.mostReviewed);
//     }

//     productProvider.getAllProductList(1, reload, isUpdate: false);

//     productProvider.getAllBrands();

//     if (authProvider.isLoggedIn()) {
//       withListProvider.getWishListProduct();
//     }

//     if ((config.flashDealProductStatus ?? false) &&
//         flashDealProvider.flashDealModel == null) {
//       flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//     }
//   }
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // Load data without forcing a refresh on first launch
//     HomeScreen.loadData(false, context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);

//     return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
//       return RefreshIndicator(
//         onRefresh: () async {
//           // Force reload when the RefreshIndicator is triggered
//           await HomeScreen.loadData(true, context);
//         },
//         backgroundColor: Theme.of(context).primaryColor,
//         child: Scaffold(
//           appBar: ResponsiveHelper.isDesktop(context)
//               ? const PreferredSize(
//                   preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
//               : null,
//           body: CustomScrollView(controller: scrollController, slivers: [
//             SliverToBoxAdapter(
//                 child: Center(
//                     child: SizedBox(
//               width: Dimensions.webScreenWidth,
//               child: Column(children: [
//                 searchBarWidget(),

//                 /// Category
//                 Padding(
//                   padding: EdgeInsets.only(
//                     bottom: ResponsiveHelper.isDesktop(context)
//                         ? Dimensions.paddingSizeLarge
//                         : Dimensions.paddingSizeSmall,
//                   ),
//                   child: const CategoryWidget(),
//                 ),

//                 Consumer<BannerProvider>(builder: (context, banner, child) {
//                   return (banner.bannerList?.isEmpty ?? false)
//                       ? const SizedBox()
//                       : const BannersWidget();
//                 }),

//                 /// Flash Deal
//                 if (splashProvider.configModel?.flashDealProductStatus ?? false)
//                   const FlashDealHomeCardWidget(),

//                 Consumer<ProductProvider>(
//                     builder: (context, productProvider, child) {
//                   bool isDailyProduct =
//                       (productProvider.dailyProductModel == null ||
//                           (productProvider
//                                   .dailyProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isFeaturedProduct =
//                       (productProvider.featuredProductModel == null ||
//                           (productProvider
//                                   .featuredProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isMostViewedProduct =
//                       (productProvider.mostViewedProductModel == null ||
//                           (productProvider.mostViewedProductModel?.products
//                                   ?.isNotEmpty ??
//                               false));

//                   return Column(children: [
//                     if ((splashProvider
//                                 .configModel?.mostReviewedProductStatus ??
//                             false) &&
//                         isMostViewedProduct)
//                       Column(children: [
//                         TitleWidget(
//                             title: getTranslated("Top Seller", context),
//                             onTap: () {
//                               Navigator.pushNamed(
//                                   context,
//                                   RouteHelper.getHomeItemRoute(
//                                       ProductType.mostReviewed));
//                             }),
//                         HomeItemWidget(
//                             productList: productProvider
//                                 .mostViewedProductModel?.products),
//                       ]),
//                     isDailyProduct
//                         ? Column(children: [
//                             TitleWidget(
//                                 title: getTranslated('Best deals', context),
//                                 onTap: () {
//                                   Navigator.pushNamed(
//                                       context,
//                                       RouteHelper.getHomeItemRoute(
//                                           ProductType.dailyItem));
//                                 }),
//                             HomeItemWidget(
//                                 productList: productProvider
//                                     .dailyProductModel?.products),
//                           ])
//                         : const SizedBox(),
//                     if ((splashProvider.configModel?.featuredProductStatus ??
//                             false) &&
//                         isFeaturedProduct)
//                       Column(children: [
//                         TitleWidget(
//                             title: getTranslated("Promotions", context),
//                             onTap: () {
//                               Navigator.pushNamed(
//                                   context,
//                                   RouteHelper.getHomeItemRoute(
//                                       ProductType.featuredItem));
//                             }),
//                         LimitedBox(
//                           maxHeight: 250,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (context, index) => Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Container(
//                                 height: 250,
//                                 width: 165,
//                                 decoration: BoxDecoration(
//                                   image: DecorationImage(
//                                     image: AssetImage(
//                                         'assets/image/promotion_${(index % 2) + 1}.png'),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             itemCount: 4,
//                           ),
//                         )
//                       ]),
//                   ]);
//                 }),

//                 Consumer<CategoryProvider>(
//                   builder: (context, value, child) =>
//                       HomeItemWidget(productList: value.categoryProductList),
//                 ),

//                 Consumer<ProductProvider>(builder: (context, provider, child) {
//                   return Column(
//                     children: [
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         TitleWidget(
//                           title: getTranslated('Shop By Brand', context),
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => const AllBrandsScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         LimitedBox(
//                           maxHeight: 125,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (context, index) => Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => BrandProductsScreen(
//                                         brandName: provider
//                                             .brandsModel!.data[index].name,
//                                         brandId: provider
//                                             .brandsModel!.data[index].id
//                                             .toString(),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Column(
//                                   children: [
//                                     CustomImageWidget(
//                                       image: provider
//                                           .brandsModel!.data[index].image,
//                                       height: 85,
//                                       width: 85,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       provider.brandsModel!.data[index].name,
//                                       style: poppinsSemiBold.copyWith(
//                                         fontSize: 16,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             itemCount: provider.brandsModel!.data.length,
//                           ),
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         const SizedBox(height: 24),
//                     ],
//                   );
//                 }),
//               ]),
//             ))),
//             const FooterWebWidget(footerType: FooterType.sliver),
//           ]),
//         ),
//       );
//     });
//   }

//   Widget searchBarWidget() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 readOnly: true,
//                 onTap: () {
//                   Navigator.pushNamed(context, RouteHelper.searchProduct);
//                 },
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(16.0), // Rounded corners
//                   ),
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: SvgPicture.asset(
//                       "assets/svg/search.svg",
//                     ),
//                   ),
//                   hintText: getTranslated("search", context),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();

//   static Future<void> loadData(bool reload, BuildContext context,
//       {bool fromLanguage = false}) async {
//     final productProvider =
//         Provider.of<ProductProvider>(context, listen: false);

//     final flashDealProvider =
//         Provider.of<FlashDealProvider>(context, listen: false);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     final withLListProvider =
//         Provider.of<WishListProvider>(context, listen: false);

//     final localizationProvider =
//         Provider.of<LocalizationProvider>(context, listen: false);

//     ConfigModel config =
//         Provider.of<SplashProvider>(context, listen: false).configModel!;
//     if (reload) {
//       Provider.of<SplashProvider>(context, listen: false).initConfig();
//     }
//     if (fromLanguage &&
//         (authProvider.isLoggedIn() || config.isGuestCheckout!)) {
//       localizationProvider.changeLanguage();
//     }
//     Provider.of<CategoryProvider>(context, listen: false)
//         .getCategoryList(context, reload);

//     Provider.of<BannerProvider>(context, listen: false)
//         .getBannerList(context, reload);

//     if (productProvider.dailyProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.dailyItem);
//     }

//     if (productProvider.featuredProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.featuredItem);
//     }

//     if (productProvider.mostViewedProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.mostReviewed);
//     }

//     productProvider.getAllProductList(1, reload, isUpdate: false);

//     productProvider.getAllBrands();

//     if (authProvider.isLoggedIn()) {
//       withLListProvider.getWishListProduct();
//     }

//     if ((config.flashDealProductStatus ?? false) &&
//         flashDealProvider.flashDealModel == null) {
//       flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//     }
//   }
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     HomeScreen.loadData(true, context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final CategoryProvider categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);
//     return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
//       return RefreshIndicator(
//         onRefresh: () async {
//           await HomeScreen.loadData(true, context);
//         },
//         backgroundColor: Theme.of(context).primaryColor,
//         child: Scaffold(
//           appBar: ResponsiveHelper.isDesktop(context)
//               ? const PreferredSize(
//                   preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
//               : null,
//           body: CustomScrollView(controller: scrollController, slivers: [
//             SliverToBoxAdapter(
//                 child: Center(
//                     child: SizedBox(
//               width: Dimensions.webScreenWidth,
//               child: Column(children: [
//                 searchBarWidget(),

//                 /// Category
//                 Padding(
//                   padding: EdgeInsets.only(
//                     bottom: ResponsiveHelper.isDesktop(context)
//                         ? Dimensions.paddingSizeLarge
//                         : Dimensions.paddingSizeSmall,
//                   ),
//                   child: const CategoryWidget(),
//                 ),

//                 Consumer<BannerProvider>(builder: (context, banner, child) {
//                   return (banner.bannerList?.isEmpty ?? false)
//                       ? const SizedBox()
//                       : const BannersWidget();
//                 }),

//                 /// Flash Deal
//                 if (splashProvider.configModel?.flashDealProductStatus ?? false)
//                   const FlashDealHomeCardWidget(),

//                 Consumer<ProductProvider>(
//                     builder: (context, productProvider, child) {
//                   bool isDalyProduct =
//                       (productProvider.dailyProductModel == null ||
//                           (productProvider
//                                   .dailyProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isFeaturedProduct =
//                       (productProvider.featuredProductModel == null ||
//                           (productProvider
//                                   .featuredProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isMostViewedProduct =
//                       (productProvider.mostViewedProductModel == null ||
//                           (productProvider.mostViewedProductModel?.products
//                                   ?.isNotEmpty ??
//                               false));

//                   return Column(children: [
//                     if ((splashProvider
//                                 .configModel?.mostReviewedProductStatus ??
//                             false) &&
//                         isMostViewedProduct)
//                       Column(children: [
//                         TitleWidget(
//                             title: getTranslated("Top Seller", context),
//                             onTap: () {
//                               Navigator.pushNamed(
//                                   context,
//                                   RouteHelper.getHomeItemRoute(
//                                       ProductType.mostReviewed));
//                             }),
//                         HomeItemWidget(
//                             productList: productProvider
//                                 .mostViewedProductModel?.products),
//                       ]),
//                     isDalyProduct
//                         ? Column(children: [
//                             TitleWidget(
//                                 title: getTranslated('Best deals', context),
//                                 onTap: () {
//                                   Navigator.pushNamed(
//                                       context,
//                                       RouteHelper.getHomeItemRoute(
//                                           ProductType.dailyItem));
//                                 }),
//                             HomeItemWidget(
//                                 productList: productProvider
//                                     .dailyProductModel?.products),
//                           ])
//                         : const SizedBox(),
//                     if ((splashProvider.configModel?.featuredProductStatus ??
//                             false) &&
//                         isFeaturedProduct)
//                       Column(children: [
//                         TitleWidget(
//                             title: getTranslated("Promotions", context),
//                             onTap: () {
//                               Navigator.pushNamed(
//                                   context,
//                                   RouteHelper.getHomeItemRoute(
//                                       ProductType.featuredItem));
//                             }),
//                         // HomeItemWidget(
//                         //   productList:
//                         //       productProvider.featuredProductModel?.products,
//                         //   isFeaturedItem: true,
//                         // ),
//                         LimitedBox(
//                           maxHeight: 250,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (context, index) => Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Container(
//                                 height: 250,
//                                 width: 165,
//                                 decoration: BoxDecoration(
//                                   image: DecorationImage(
//                                     image: AssetImage(
//                                         'assets/image/promotion_${(index % 2) + 1}.png'),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             itemCount: 4,
//                           ),
//                         )
//                       ]),
//                   ]);
//                 }),
//                 if (categoryProvider.categoryList!
//                         .firstWhere(
//                           (element) =>
//                               element.name!.toLowerCase().contains("fruit"),
//                           orElse: () => CategoryModel(),
//                         )
//                         .id !=
//                     null)
//                   TitleWidget(
//                     title: getTranslated('Organic Products', context),
//                   ),
//                 if (categoryProvider.categoryList!
//                         .firstWhere(
//                           (element) =>
//                               element.name!.toLowerCase().contains("fruit"),
//                           orElse: () => CategoryModel(),
//                         )
//                         .id !=
//                     null)
//                   Consumer<CategoryProvider>(
//                     builder: (context, value, child) =>
//                         HomeItemWidget(productList: value.categoryProductList),
//                   ),

//                 Consumer<ProductProvider>(builder: (context, provider, child) {
//                   return Column(
//                     children: [
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         TitleWidget(
//                           title: getTranslated('Shop By Brand', context),
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => const AllBrandsScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         LimitedBox(
//                           maxHeight: 125,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (context, index) => Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => BrandProductsScreen(
//                                         brandName: provider
//                                             .brandsModel!.data[index].name,
//                                         brandId: provider
//                                             .brandsModel!.data[index].id
//                                             .toString(),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Column(
//                                   children: [
//                                     CustomImageWidget(
//                                       image: provider
//                                           .brandsModel!.data[index].image,
//                                       height: 85,
//                                       width: 85,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       provider.brandsModel!.data[index].name,
//                                       style: poppinsSemiBold.copyWith(
//                                         fontSize: 16,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             itemCount: provider.brandsModel!.data.length,
//                           ),
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         const SizedBox(height: 24),
//                     ],
//                   );
//                 })

//                 // ResponsiveHelper.isMobilePhone()
//                 //     ? const SizedBox(height: 10)
//                 //     : const SizedBox.shrink(),

//                 // AllProductListWidget(scrollController: scrollController),
//               ]),
//             ))),
//             const FooterWebWidget(footerType: FooterType.sliver),
//           ]),
//         ),
//       );
//     });
//   }

//   Widget searchBarWidget() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 readOnly: true,
//                 onTap: () {
//                   Navigator.pushNamed(context, RouteHelper.searchProduct);
//                 },
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(16.0), // Rounded corners
//                   ),
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: SvgPicture.asset(
//                       "assets/svg/search.svg",
//                     ),
//                   ),
//                   hintText: getTranslated("search", context),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
// import 'package:flutter_grocery/common/models/config_model.dart';
// import 'package:flutter_grocery/common/providers/localization_provider.dart';
// import 'package:flutter_grocery/common/providers/product_provider.dart';
// import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
// import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
// import 'package:flutter_grocery/common/widgets/title_widget.dart';
// import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
// import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
// import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
// import 'package:flutter_grocery/features/category/providers/category_provider.dart';
// import 'package:flutter_grocery/features/home/providers/banner_provider.dart';
// import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
// import 'package:flutter_grocery/features/home/screens/all_brands_screen.dart';
// import 'package:flutter_grocery/features/home/screens/brand_products_screen.dart';
// import 'package:flutter_grocery/features/home/widgets/banners_widget.dart';
// import 'package:flutter_grocery/features/home/widgets/category_web_widget.dart';
// import 'package:flutter_grocery/features/home/widgets/flash_deal_home_card_widget.dart';
// import 'package:flutter_grocery/features/home/widgets/home_item_widget.dart';
// import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
// import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
// import 'package:flutter_grocery/helper/responsive_helper.dart';
// import 'package:flutter_grocery/helper/route_helper.dart';
// import 'package:flutter_grocery/localization/language_constraints.dart';
// import 'package:flutter_grocery/utill/dimensions.dart';
// import 'package:flutter_grocery/utill/product_type.dart';
// import 'package:flutter_grocery/utill/styles.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();

//   // static Future<void> loadData(bool reload, BuildContext context,
//   //     {bool fromLanguage = false, bool forceReload = false}) async {
//   //   final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//   //   await splashProvider.initConfig();

//   //   if (splashProvider.configModel == null) {
//   //     return; // Prevent further loading if configModel is null
//   //   }

//   //   final productProvider =
//   //       Provider.of<ProductProvider>(context, listen: false);
//   //   final flashDealProvider =
//   //       Provider.of<FlashDealProvider>(context, listen: false);
//   //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   //   final wishListProvider =
//   //       Provider.of<WishListProvider>(context, listen: false);
//   //   final localizationProvider =
//   //       Provider.of<LocalizationProvider>(context, listen: false);
//   //   final config = splashProvider.configModel;

//   //   if (reload) {
//   //     await splashProvider.initConfig();
//   //   }

//   //   if (fromLanguage &&
//   //       (authProvider.isLoggedIn() || (config?.isGuestCheckout ?? false))) {
//   //     localizationProvider.changeLanguage();
//   //   }

//   //   // Fetch categories only if not already loaded or if forceReload is true
//   //   if (forceReload ||
//   //       Provider.of<CategoryProvider>(context, listen: false).categoryList ==
//   //           null) {
//   //     Provider.of<CategoryProvider>(context, listen: false)
//   //         .getCategoryList(context, reload);
//   //   }

//   //   // Fetch banners only if not already loaded or if forceReload is true
//   //   if (forceReload ||
//   //       Provider.of<BannerProvider>(context, listen: false).bannerList ==
//   //           null) {
//   //     Provider.of<BannerProvider>(context, listen: false)
//   //         .getBannerList(context, reload);
//   //   }

//   //   if (forceReload || productProvider.dailyProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.dailyItem);
//   //   }

//   //   if (forceReload || productProvider.featuredProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.featuredItem);
//   //   }

//   //   if (forceReload || productProvider.mostViewedProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.mostReviewed);
//   //   }

//   //   if (forceReload || productProvider.allProductModel == null) {
//   //     productProvider.getAllProductList(1, reload, isUpdate: false);
//   //   }

//   //   if (forceReload || productProvider.brandsModel == null) {
//   //     productProvider.getAllBrands();
//   //   }

//   //   // if (authProvider.isLoggedIn() && (forceReload)) {
//   //   //   wishListProvider.getWishListProduct();
//   //   // }

//   //   if ((config?.flashDealProductStatus ?? false) &&
//   //       (forceReload || flashDealProvider.flashDealModel == null)) {
//   //     flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//   //   }
//   // }
//   // static Future<void> loadData(bool reload, BuildContext context,
//   //     {bool fromLanguage = false, bool forceReload = false}) async {
//   //   final splashProvider = Provider.of<SplashProvider>(context, listen: false);

//   //   // Skip loading if data is already loaded and not forced
//   //   if (!forceReload && splashProvider.hasDataLoaded) {
//   //     return;
//   //   }

//   //   await splashProvider.initConfig();

//   //   if (splashProvider.configModel == null) {
//   //     return;
//   //   }

//   //   final productProvider =
//   //       Provider.of<ProductProvider>(context, listen: false);
//   //   final flashDealProvider =
//   //       Provider.of<FlashDealProvider>(context, listen: false);
//   //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   //   final wishListProvider =
//   //       Provider.of<WishListProvider>(context, listen: false);
//   //   final localizationProvider =
//   //       Provider.of<LocalizationProvider>(context, listen: false);
//   //   final config = splashProvider.configModel;

//   //   if (reload) {
//   //     await splashProvider.initConfig();
//   //   }

//   //   if (fromLanguage &&
//   //       (authProvider.isLoggedIn() || (config?.isGuestCheckout ?? false))) {
//   //     localizationProvider.changeLanguage();
//   //   }

//   //   if (forceReload ||
//   //       Provider.of<CategoryProvider>(context, listen: false).categoryList ==
//   //           null) {
//   //     Provider.of<CategoryProvider>(context, listen: false)
//   //         .getCategoryList(context, reload);
//   //   }

//   //   if (forceReload ||
//   //       Provider.of<BannerProvider>(context, listen: false).bannerList ==
//   //           null) {
//   //     Provider.of<BannerProvider>(context, listen: false)
//   //         .getBannerList(context, reload);
//   //   }

//   //   if (forceReload || productProvider.dailyProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.dailyItem);
//   //   }

//   //   if (forceReload || productProvider.featuredProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.featuredItem);
//   //   }

//   //   if (forceReload || productProvider.mostViewedProductModel == null) {
//   //     productProvider.getItemList(1,
//   //         isUpdate: false, productType: ProductType.mostReviewed);
//   //   }

//   //   if (forceReload || productProvider.allProductModel == null) {
//   //     productProvider.getAllProductList(1, reload, isUpdate: false);
//   //   }

//   //   if (forceReload || productProvider.brandsModel == null) {
//   //     productProvider.getAllBrands();
//   //   }

//   //   if (authProvider.isLoggedIn() && (forceReload)) {
//   //     wishListProvider.getWishListProduct();
//   //   }

//   //   if ((config?.flashDealProductStatus ?? false) &&
//   //       (forceReload || flashDealProvider.flashDealModel == null)) {
//   //     flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//   //   }
//   // }

//   static Future<void> loadData(bool reload, BuildContext context,
//       {bool fromLanguage = false}) async {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     await splashProvider.initConfig(); // Ensures configModel is fully loaded
//     if (splashProvider.configModel == null) {
//       return; // Prevent further loading if configModel is null
//     }
//     final productProvider =
//         Provider.of<ProductProvider>(context, listen: false);

//     final flashDealProvider =
//         Provider.of<FlashDealProvider>(context, listen: false);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     final withLListProvider =
//         Provider.of<WishListProvider>(context, listen: false);

//     final localizationProvider =
//         Provider.of<LocalizationProvider>(context, listen: false);

//     ConfigModel? config =
//         Provider.of<SplashProvider>(context, listen: false).configModel;
//     if (reload) {
//       Provider.of<SplashProvider>(context, listen: false).initConfig();
//     }
//     if (fromLanguage &&
//         (authProvider.isLoggedIn() || (config?.isGuestCheckout ?? false))) {
//       localizationProvider.changeLanguage();
//     }
//     Provider.of<CategoryProvider>(context, listen: false)
//         .getCategoryList(context, reload);

//     Provider.of<BannerProvider>(context, listen: false)
//         .getBannerList(context, reload);

//     if (productProvider.dailyProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.dailyItem);
//     }

//     if (productProvider.featuredProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.featuredItem);
//     }

//     if (productProvider.mostViewedProductModel == null) {
//       productProvider.getItemList(1,
//           isUpdate: false, productType: ProductType.mostReviewed);
//     }

//     productProvider.getAllProductList(1, reload, isUpdate: false);

//     productProvider.getAllBrands();

//     if (authProvider.isLoggedIn()) {
//       withLListProvider.getWishListProduct();
//     }

//     // if ((config.flashDealProductStatus ?? false) &&
//     //     flashDealProvider.flashDealModel == null) {
//     //   flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//     // }
//     // Null-safe check for flashDealProductStatus
//     if ((config?.flashDealProductStatus ?? false) &&
//         flashDealProvider.flashDealModel == null) {
//       flashDealProvider.getFlashDealProducts(1, isUpdate: false);
//     }
//   }
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     HomeScreen.loadData(false, context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final CategoryProvider categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);
//     return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
//       if (splashProvider.isLoading ||
//               splashProvider.configModel ==
//                   null /*||
//           !splashProvider.hasDataLoaded*/
//           ) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (!splashProvider.isConfigLoaded) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       return RefreshIndicator(
//         onRefresh: () async {
//           await HomeScreen.loadData(true, context);
//         },
//         backgroundColor: Theme.of(context).primaryColor,
//         child: Scaffold(
//           appBar: ResponsiveHelper.isDesktop(context)
//               ? const PreferredSize(
//                   preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
//               : null,
//           body: CustomScrollView(controller: scrollController, slivers: [
//             SliverToBoxAdapter(
//                 child: Center(
//                     child: SizedBox(
//               width: Dimensions.webScreenWidth,
//               child: Column(children: [
//                 searchBarWidget(),

//                 /// Category
//                 Padding(
//                   padding: EdgeInsets.only(
//                     bottom: ResponsiveHelper.isDesktop(context)
//                         ? Dimensions.paddingSizeLarge
//                         : Dimensions.paddingSizeSmall,
//                   ),
//                   child: const CategoryWidget(),
//                 ),

//                 Consumer<BannerProvider>(builder: (context, banner, child) {
//                   return (banner.bannerList?.isEmpty ?? false)
//                       ? const SizedBox()
//                       : const BannersWidget();
//                 }),

//                 /// Flash Deal
//                 if (splashProvider.configModel?.flashDealProductStatus ?? false)
//                   const FlashDealHomeCardWidget(),

//                 Consumer<ProductProvider>(
//                     builder: (context, productProvider, child) {
//                   bool isDalyProduct =
//                       (productProvider.dailyProductModel == null ||
//                           (productProvider
//                                   .dailyProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isFeaturedProduct =
//                       (productProvider.featuredProductModel == null ||
//                           (productProvider
//                                   .featuredProductModel?.products?.isNotEmpty ??
//                               false));
//                   bool isMostViewedProduct =
//                       (productProvider.mostViewedProductModel == null ||
//                           (productProvider.mostViewedProductModel?.products
//                                   ?.isNotEmpty ??
//                               false));

//                   return Column(children: [
//                     // if ((splashProvider.configModel?.mostReviewedProductStatus ??
//                     //         false) &&
//                     //     isMostViewedProduct)
//                     Column(children: [
//                       TitleWidget(
//                           title: getTranslated("Top Seller", context),
//                           onTap: () {
//                             Navigator.pushNamed(
//                                 context,
//                                 RouteHelper.getHomeItemRoute(
//                                     ProductType.mostReviewed));
//                           }),
//                       HomeItemWidget(
//                           productList:
//                               productProvider.mostViewedProductModel?.products),
//                     ]),
//                     isDalyProduct
//                         ? Column(children: [
//                             TitleWidget(
//                                 title: getTranslated('Best deals', context),
//                                 onTap: () {
//                                   Navigator.pushNamed(
//                                       context,
//                                       RouteHelper.getHomeItemRoute(
//                                           ProductType.dailyItem));
//                                 }),
//                             HomeItemWidget(
//                                 productList: productProvider
//                                     .dailyProductModel?.products),
//                           ])
//                         : const SizedBox(),
//                     // if ((splashProvider.configModel?.featuredProductStatus ??
//                     //         false) &&
//                     //     isFeaturedProduct)
//                     Column(children: [
//                       TitleWidget(
//                           title: getTranslated("Promotions", context),
//                           onTap: () {
//                             Navigator.pushNamed(
//                                 context,
//                                 RouteHelper.getHomeItemRoute(
//                                     ProductType.featuredItem));
//                           }),
//                       // HomeItemWidget(
//                       //   productList:
//                       //       productProvider.featuredProductModel?.products,
//                       //   isFeaturedItem: true,
//                       // ),
//                       LimitedBox(
//                         maxHeight: 250,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemBuilder: (context, index) => Padding(
//                             padding: const EdgeInsets.only(left: 16.0),
//                             child: Container(
//                               height: 250,
//                               width: 165,
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   image: AssetImage(
//                                       'assets/image/promotion_${(index % 2) + 1}.png'),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           itemCount: 4,
//                         ),
//                       )
//                     ]),
//                   ]);
//                 }),
//                 if (categoryProvider.categoryList!
//                         .firstWhere(
//                           (element) =>
//                               element.name?.toLowerCase().contains("fruit") ??
//                               false,
//                           // element.name!.toLowerCase().contains("fruit"),
//                           orElse: () => CategoryModel(),
//                         )
//                         .id !=
//                     null)
//                   TitleWidget(
//                     title: getTranslated('Organic Products', context),
//                   ),
//                 if (categoryProvider.categoryList!
//                         .firstWhere(
//                           (element) =>
//                               element.name!.toLowerCase().contains("fruit"),
//                           orElse: () => CategoryModel(),
//                         )
//                         .id !=
//                     null)
//                   Consumer<CategoryProvider>(
//                     builder: (context, value, child) =>
//                         HomeItemWidget(productList: value.categoryProductList),
//                   ),
//                 Consumer<BannerProvider>(builder: (context, banner, child) {
//                   return (banner.bannerList?.isEmpty ?? false)
//                       ? const SizedBox()
//                       : const BannersWidget();
//                 }),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Consumer<ProductProvider>(builder: (context, provider, child) {
//                   return Column(
//                     children: [
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         TitleWidget(
//                           title: getTranslated('Shop By Brand', context),
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => const AllBrandsScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         LimitedBox(
//                           maxHeight: 125,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (context, index) => Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => BrandProductsScreen(
//                                         brandName: provider
//                                             .brandsModel!.data[index].name,
//                                         brandId: provider
//                                             .brandsModel!.data[index].id
//                                             .toString(),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Column(
//                                   children: [
//                                     CustomImageWidget(
//                                       image: provider
//                                           .brandsModel!.data[index].image,
//                                       height: 85,
//                                       width: 85,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       provider.brandsModel!.data[index].name,
//                                       style: poppinsSemiBold.copyWith(
//                                         fontSize: 16,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             itemCount: provider.brandsModel!.data.length,
//                           ),
//                         ),
//                       if (provider.brandsModel != null &&
//                           provider.brandsModel!.data.isNotEmpty)
//                         const SizedBox(height: 24),
//                     ],
//                   );
//                 })

//                 // ResponsiveHelper.isMobilePhone()
//                 //     ? const SizedBox(height: 10)
//                 //     : const SizedBox.shrink(),

//                 // AllProductListWidget(scrollController: scrollController),
//               ]),
//             ))),
//             const FooterWebWidget(footerType: FooterType.sliver),
//           ]),
//         ),
//       );
//     });
//   }

//   Widget searchBarWidget() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 readOnly: true,
//                 onTap: () {
//                   Navigator.pushNamed(context, RouteHelper.searchProduct);
//                 },
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(14.0), // Rounded corners
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                       color: Colors.green, // Green border
//                       width: 1.0, // Border width
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(16.0), // Rounded corners
//                   ),
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: SvgPicture.asset(
//                       "assets/svg/search.svg",
//                     ),
//                   ),
//                   // suffixIcon: Padding(
//                   //   padding: const EdgeInsets.all(12.0),
//                   //   child: SvgPicture.asset(
//                   //     "assets/svg/scan_icon.svg",
//                   //   ),
//                   // ),
//                   hintText: getTranslated("search", context),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
