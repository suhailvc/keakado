import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/product_widget.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  ProductProvider? productProvider;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          productProvider?.featuredProductModel?.totalSize != null &&
          !productProvider!.isLoading) {
        productProvider!.getItemList(
            productProvider?.featuredProductModel?.offset ?? 1,
            isUpdate: false,
            productType: ProductType.featuredItem);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider!
        .getItemList(1, isUpdate: false, productType: ProductType.featuredItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(
          getTranslated("Offers", context).toCapitalized(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, value, child) {
          if (productProvider == null || value.isLoading) {
            Center(
              child: CustomLoaderWidget(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          return Column(
            children: [
              searchBarWidget(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.62),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProductWidget(
                        isOfferScreen: true,
                        product:
                            (productProvider!.featuredProductModel?.products ??
                                [])[index],
                        isGrid: true,
                      ),
                    );
                  },
                  itemCount:
                      (productProvider?.featuredProductModel?.products ?? [])
                          .length,
                ),
              ),
            ],
          );
        },
      ),
    );
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
                  // suffixIcon: Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: SvgPicture.asset(
                  //     "assets/svg/scan_icon.svg",
                  //   ),
                  // ),
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
// import 'package:flutter/material.dart';
// import 'package:flutter_grocery/common/providers/product_provider.dart';
// import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
// import 'package:flutter_grocery/common/widgets/product_widget.dart';
// import 'package:flutter_grocery/features/offers/providers/offer_provider.dart';

// import 'package:flutter_grocery/helper/route_helper.dart';
// import 'package:flutter_grocery/localization/app_localization.dart';
// import 'package:flutter_grocery/localization/language_constraints.dart';

// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';

// class OfferScreen extends StatefulWidget {
//   const OfferScreen({Key? key}) : super(key: key);

//   @override
//   State<OfferScreen> createState() => _OfferScreenState();
// }

// class _OfferScreenState extends State<OfferScreen> {
//   ProductProvider? productProvider;

//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     Provider.of<OfferProvider>(context, listen: false).fetchOffers();
//     // scrollController.addListener(() {
//     //   if (scrollController.position.pixels ==
//     //           scrollController.position.maxScrollExtent &&
//     //       productProvider?.featuredProductModel?.totalSize != null &&
//     //       !productProvider!.isLoading) {
//     //     productProvider!.getItemList(
//     //         productProvider?.featuredProductModel?.offset ?? 1,
//     //         isUpdate: false,
//     //         productType: ProductType.featuredItem);
//     //   }
//     // });
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();

//   //   productProvider = Provider.of<ProductProvider>(context, listen: false);
//   //   productProvider!
//   //       .getItemList(1, isUpdate: false, productType: ProductType.featuredItem);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         backgroundColor: Theme.of(context).cardColor,
//         centerTitle: true,
//         title: Text(
//           getTranslated("Offers", context).toCapitalized(),
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Consumer<OfferProvider>(
//         builder: (context, value, child) {
//           if (value.offers == null || value.isLoading) {
//             Center(
//               child: CustomLoaderWidget(
//                 color: Theme.of(context).primaryColor,
//               ),
//             );
//           }
//           return Column(
//             children: [
//               //  searchBarWidget(),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.65,
//                   ),
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ProductWidget(
//                         isOfferScreen: true,
//                         product: (value.offers?.products ?? [])[index],
//                         // (productProvider!.featuredProductModel?.products ??
//                         //  [])[index],
//                         isGrid: true,
//                       ),
//                     );
//                   },
//                   itemCount: (value.offers?.products ?? []).length,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // Widget searchBarWidget() {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//   //     child: Row(
//   //       children: [
//   //         Expanded(
//   //           child: SizedBox(
//   //             height: 45,
//   //             child: TextField(
//   //               readOnly: true,
//   //               onTap: () {
//   //                 Navigator.pushNamed(context, RouteHelper.searchProduct);
//   //               },
//   //               decoration: InputDecoration(
//   //                 contentPadding: const EdgeInsets.symmetric(vertical: 8),
//   //                 border: OutlineInputBorder(
//   //                   borderSide: const BorderSide(
//   //                     color: Colors.green, // Green border
//   //                     width: 1.0, // Border width
//   //                   ),
//   //                   borderRadius:
//   //                       BorderRadius.circular(14.0), // Rounded corners
//   //                 ),
//   //                 enabledBorder: OutlineInputBorder(
//   //                   borderSide: const BorderSide(
//   //                     color: Colors.green, // Green border
//   //                     width: 1.0, // Border width
//   //                   ),
//   //                   borderRadius:
//   //                       BorderRadius.circular(14.0), // Rounded corners
//   //                 ),
//   //                 focusedBorder: OutlineInputBorder(
//   //                   borderSide: const BorderSide(
//   //                     color: Colors.green, // Green border
//   //                     width: 1.0, // Border width
//   //                   ),
//   //                   borderRadius:
//   //                       BorderRadius.circular(16.0), // Rounded corners
//   //                 ),
//   //                 prefixIcon: Padding(
//   //                   padding: const EdgeInsets.all(12.0),
//   //                   child: SvgPicture.asset(
//   //                     "assets/svg/search.svg",
//   //                   ),
//   //                 ),
//   //                 // suffixIcon: Padding(
//   //                 //   padding: const EdgeInsets.all(12.0),
//   //                 //   child: SvgPicture.asset(
//   //                 //     "assets/svg/scan_icon.svg",
//   //                 //   ),
//   //                 // ),
//   //                 hintText: getTranslated("search", context),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
