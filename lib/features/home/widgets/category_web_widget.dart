import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/home/widgets/category_page_widget.dart';
import 'package:flutter_grocery/features/home/widgets/category_shimmer_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  final bool isListView;
  const CategoryWidget({Key? key, this.isListView = false}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  ScrollController scrollController = ScrollController();
  bool _isInitialCallMade = false; // Flag to track the initial API call

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);

    return Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
      // Perform the API call only once
      if (!_isInitialCallMade &&
          categoryProvider.categoryList != null &&
          categoryProvider.categoryList!.isNotEmpty) {
        // categoryProvider.getCategoryProductList(categoryProvider.categoryList!
        //     .firstWhere(
        //       (element) => element.name!.toLowerCase().contains("fruit"),
        //     )
        //     .id
        //     .toString());
        _isInitialCallMade = true; // Mark the flag as true after the call
      }

      print('---------category');
      return categoryProvider.categoryList == null
          ? const CategoriesShimmerWidget()
          : (categoryProvider.categoryList?.isNotEmpty ?? false)
              ? Column(children: [
                  TitleWidget(
                    title: getTranslated('category', context),
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteHelper.categories);
                    },
                  ),
                  ResponsiveHelper.isDesktop(context)
                      ? CategoryWebWidget(scrollController: scrollController)
                      : LimitedBox(
                          maxHeight: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryProvider.categoryList?.length,
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteHelper.getSubCategoriesRoute(
                                        categoryId:
                                            '${categoryProvider.categoryList![index].id}',
                                        categoryName:
                                            '${categoryProvider.categoryList![index].name}'),
                                  );
                                  // categoryProvider.onChangeSelectIndex(-1,
                                  //     notify: false);
                                  // Navigator.of(context).pushNamed(
                                  //   RouteHelper.getCategoryProductsRoute(
                                  //       subCategory:
                                  //           '${categoryProvider.categoryList![index].name}',
                                  //       categoryId:
                                  //           '${categoryProvider.categoryList![index].id}'),
                                  // );
                                },
                                child: Column(children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    margin: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          '${splashProvider.baseUrls?.categoryImageUrl}/${categoryProvider.categoryList?[index].image}',
                                        ),
                                      ),
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  Expanded(
                                    flex: ResponsiveHelper.isDesktop(context)
                                        ? 3
                                        : 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall),
                                      child: Text(
                                        // index != 7
                                        //     ?
                                        categoryProvider
                                            .categoryList![index].name!,
                                        // : getTranslated(
                                        //     'view_all', context),
                                        style: poppinsBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ]),
                              );
                            },
                          ),
                        )
                ])
              : const SizedBox();
    });
  }
}

// class _CategoryWidgetState extends State<CategoryWidget> {
//   ScrollController scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final SplashProvider splashProvider =
//         Provider.of<SplashProvider>(context, listen: false);

//     return Consumer<CategoryProvider>(
//         builder: (context, categoryProvider, child) {
//       if (categoryProvider.categoryList != null &&
//           categoryProvider.categoryList!.isNotEmpty) {
//         categoryProvider.getCategoryProductList(categoryProvider.categoryList!
//             .firstWhere(
//               (element) => element.name!.toLowerCase().contains("fruit"),
//             )
//             .id
//             .toString());
//       }
//       print('---------category');
//       return categoryProvider.categoryList == null
//           ? const CategoriesShimmerWidget()
//           : (categoryProvider.categoryList?.isNotEmpty ?? false)
//               ? Column(children: [
//                   TitleWidget(
//                     title: getTranslated('Category', context),
//                     onTap: () {
//                       Navigator.of(context).pushNamed(RouteHelper.categories);
//                     },
//                   ),
//                   ResponsiveHelper.isDesktop(context)
//                       ? CategoryWebWidget(scrollController: scrollController)
//                       : LimitedBox(
//                           maxHeight: 150,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: categoryProvider.categoryList?.length,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeSmall),
//                             // physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             // gridDelegate:
//                             //     SliverGridDelegateWithFixedCrossAxisCount(
//                             //   crossAxisCount: ResponsiveHelper.isMobilePhone()
//                             //       ? 4
//                             //       : ResponsiveHelper.isTab(context)
//                             //           ? 4
//                             //           : 3,
//                             //   mainAxisSpacing: 10,
//                             //   crossAxisSpacing: 10,
//                             //   childAspectRatio:
//                             //       0.6, // Adjusted to increase height
//                             // ),
//                             itemBuilder: (context, index) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   // if (index == 7) {
//                                   //   ResponsiveHelper.isMobilePhone()
//                                   //       ? splashProvider.setPageIndex(1)
//                                   //       : const SizedBox();
//                                   //   ResponsiveHelper.isWeb()
//                                   //       ? Navigator.pushNamed(
//                                   //           context, RouteHelper.categories)
//                                   //       : const SizedBox();
//                                   // } else {
//                                   categoryProvider.onChangeSelectIndex(-1,
//                                       notify: false);
//                                   Navigator.of(context).pushNamed(
//                                     RouteHelper.getCategoryProductsRoute(
//                                         categoryId:
//                                             '${categoryProvider.categoryList![index].id}'),
//                                   );
//                                   // }
//                                 },
//                                 child: Column(children: [
//                                   Container(
//                                     height: 100,
//                                     width: 100,
//                                     margin: const EdgeInsets.all(
//                                         Dimensions.paddingSizeExtraSmall),
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.rectangle,
//                                       borderRadius: BorderRadius.circular(12),
//                                       image: DecorationImage(
//                                         fit: BoxFit.cover,
//                                         image: CachedNetworkImageProvider(
//                                           '${splashProvider.baseUrls?.categoryImageUrl}/${categoryProvider.categoryList?[index].image}',
//                                         ),
//                                       ),
//                                       color: Theme.of(context).cardColor,
//                                     ),

//                                     // : Container(
//                                     //     height: 100, // Increased height
//                                     //     width: 100, // Increased width
//                                     //     decoration: BoxDecoration(
//                                     //       shape: BoxShape.rectangle,
//                                     //       color: Theme.of(context)
//                                     //           .primaryColor,
//                                     //     ),
//                                     //     alignment: Alignment.center,
//                                     //     child: Text(
//                                     //       '${(categoryProvider.categoryList?.length ?? 0) - 7}+',
//                                     //       style: poppinsRegular.copyWith(
//                                     //           color: Theme.of(context)
//                                     //               .cardColor),
//                                     //     ),
//                                     //   ),
//                                   ),
//                                   Expanded(
//                                     flex: ResponsiveHelper.isDesktop(context)
//                                         ? 3
//                                         : 2,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(
//                                           Dimensions.paddingSizeExtraSmall),
//                                       child: Text(
//                                         index != 7
//                                             ? categoryProvider
//                                                 .categoryList![index].name!
//                                             : getTranslated(
//                                                 'view_all', context),
//                                         style: poppinsBold.copyWith(
//                                           fontSize: Dimensions.fontSizeSmall,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ),
//                                 ]),
//                               );
//                             },
//                           ),
//                         )
//                 ])
//               : const SizedBox();
//     });
//   }
// }
