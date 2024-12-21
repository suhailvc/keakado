import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    if (categoryProvider.categoryList != null &&
        categoryProvider.categoryList!.isNotEmpty) {
      _load(); // Using updated _load()
    } else {
      categoryProvider.getCategoryList(context, true).then((apiResponse) {
        if (apiResponse.response!.statusCode == 200 &&
            apiResponse.response!.data != null) {
          _load(); // Using updated _load()
        }
      });
    }
  } // @override
  // void initState() {
  //   super.initState();
  //   if (Provider.of<CategoryProvider>(context, listen: false).categoryList !=
  //           null &&
  //       Provider.of<CategoryProvider>(context, listen: false)
  //           .categoryList!
  //           .isNotEmpty) {
  //     _load();
  //   } else {
  //     Provider.of<CategoryProvider>(context, listen: false)
  //         .getCategoryList(context, true)
  //         .then((apiResponse) {
  //       if (apiResponse.response!.statusCode == 200 &&
  //           apiResponse.response!.data != null) {
  //         _load();
  //       }
  //     });
  //   }
  // }

  Future<void> _load() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.onChangeCategoryIndex(0, notify: false);

    if (categoryProvider.categoryList?.isNotEmpty ?? false) {
      for (var category in categoryProvider.categoryList!) {
        // Skip fetching if subcategories for this categoryID are already loaded
        if (categoryProvider
                .subCategoryMap[category.id.toString()]?.isNotEmpty ??
            false) {
          continue;
        }
        await categoryProvider.getSubCategoryList(
            context, category.id.toString());
      }
    }
  } // Future<void> _load() async {
  //   final categoryProvider =
  //       Provider.of<CategoryProvider>(context, listen: false);
  //   categoryProvider.onChangeCategoryIndex(0, notify: false);

  //   if (categoryProvider.categoryList?.isNotEmpty ?? false) {
  //     // Use Future.wait to ensure all calls complete
  //     await Future.wait(categoryProvider.categoryList!.map((category) async {
  //       await categoryProvider.getSubCategoryList(
  //           context, category.id.toString());
  //     }));
  //   }
  // }
  // _load() {
  //   final categoryProvider =
  //       Provider.of<CategoryProvider>(context, listen: false);
  //   categoryProvider.onChangeCategoryIndex(0, notify: false);

  //   // Ensure the category list is not empty before fetching subcategories
  //   if (categoryProvider.categoryList?.isNotEmpty ?? false) {
  //     for (var category in categoryProvider.categoryList!) {
  //       // Fetch subcategory list for each category
  //       categoryProvider.getSubCategoryList(context, category.id.toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated("category", context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
          child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return categoryProvider.categoryList == null
                ? Center(
                    child: CustomLoaderWidget(
                        color: Theme.of(context).primaryColor),
                  )
                : categoryProvider.categoryList?.isNotEmpty ?? false
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            searchBarWidget(),
                            const SizedBox(
                              height: 18,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    categoryProvider.categoryList?.length ??
                                        0, // Ensure safe access
                                itemBuilder: (context, index) {
                                  if (index >=
                                      categoryProvider.categoryList!.length) {
                                    return const SizedBox
                                        .shrink(); // Avoid out-of-range error
                                  }

                                  final category =
                                      categoryProvider.categoryList![index];
                                  final entry = categoryProvider
                                      .subCategoryMap.entries
                                      .elementAtOrNull(index);

                                  if (entry == null) {
                                    return const SizedBox
                                        .shrink(); // Handle cases where map entry is missing
                                  }

                                  final String categoryID = entry.key;
                                  return categoryWidget(
                                      category.name ?? "", categoryID);
                                },
                              ),
                            )

                            // Expanded(
                            //   child: ListView.builder(
                            //       itemBuilder: (context, index) {
                            //         final entry = categoryProvider
                            //             .subCategoryMap.entries
                            //             .elementAt(index);
                            //         final String categoryID =
                            //             entry.key; // Extract category ID
                            //         return categoryWidget(
                            //             categoryProvider
                            //                     .categoryList![index].name ??
                            //                 "",
                            //             categoryID);
                            //       },
                            //       itemCount:
                            //           categoryProvider.categoryList!.length,
                            //       shrinkWrap: true,
                            //       padding: const EdgeInsets.only(left: 0)),
                            // )
                          ],
                        ),
                      )
                    // ? Row(children: [
                    //     Container(
                    //       width: 120,
                    //       margin: const EdgeInsets.symmetric(
                    //           vertical: Dimensions.paddingSizeSmall),
                    //       height: double.maxFinite,
                    //       decoration: BoxDecoration(
                    //         boxShadow: [
                    //           BoxShadow(
                    //               color: Theme.of(context).shadowColor,
                    //               spreadRadius: 3,
                    //               blurRadius: 10)
                    //         ],
                    //       ),
                    //       child: ListView.builder(
                    //         physics: const BouncingScrollPhysics(),
                    //         itemCount: categoryProvider.categoryList!.length,
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: Dimensions.paddingSizeSmall),
                    //         itemBuilder: (context, index) {
                    //           CategoryModel category =
                    //               categoryProvider.categoryList![index];
                    //           return InkWell(
                    //             onTap: () {
                    //               categoryProvider.onChangeCategoryIndex(index);
                    //               categoryProvider.getSubCategoryList(
                    //                   context, category.id.toString());
                    //             },
                    //             child: CategoryItemWidget(
                    //               title: category.name,
                    //               icon: category.image,
                    //               isSelected:
                    //                   categoryProvider.categoryIndex == index,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //     categoryProvider.subCategoryList != null
                    //         ? Expanded(
                    //             child: ListView.builder(
                    //               padding: const EdgeInsets.all(
                    //                   Dimensions.paddingSizeSmall),
                    //               itemCount:
                    //                   categoryProvider.subCategoryList!.length +
                    //                       1,
                    //               itemBuilder: (context, index) {
                    //                 if (index == 0) {
                    //                   return ListTile(
                    //                     onTap: () {
                    //                       categoryProvider
                    //                           .onChangeSelectIndex(-1);
                    //                       categoryProvider
                    //                           .initCategoryProductList(
                    //                         categoryProvider
                    //                             .categoryList![categoryProvider
                    //                                 .categoryIndex]
                    //                             .id
                    //                             .toString(),
                    //                       );
                    //                       Navigator.of(context).pushNamed(
                    //                         RouteHelper
                    //                             .getCategoryProductsRoute(
                    //                           categoryId:
                    //                               '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                    //                         ),
                    //                       );
                    //                     },
                    //                     title:
                    //                         Text(getTranslated('all', context)),
                    //                     trailing: const Icon(
                    //                         Icons.keyboard_arrow_right),
                    //                   );
                    //                 }
                    //                 return ListTile(
                    //                   onTap: () {
                    //                     categoryProvider
                    //                         .onChangeSelectIndex(index - 1);
                    //                     if (ResponsiveHelper.isMobilePhone()) {}
                    //                     categoryProvider
                    //                         .initCategoryProductList(
                    //                       categoryProvider
                    //                           .subCategoryList![index - 1].id
                    //                           .toString(),
                    //                     );

                    //                     Navigator.of(context).pushNamed(
                    //                       RouteHelper.getCategoryProductsRoute(
                    //                         categoryId:
                    //                             '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                    //                         subCategory: categoryProvider
                    //                             .subCategoryList![index - 1]
                    //                             .name,
                    //                       ),
                    //                     );
                    //                   },
                    //                   title: Text(
                    //                     categoryProvider
                    //                         .subCategoryList![index - 1].name!,
                    //                     style: poppinsMedium.copyWith(
                    //                         fontSize: 13,
                    //                         color: Theme.of(context)
                    //                             .textTheme
                    //                             .bodyLarge
                    //                             ?.color
                    //                             ?.withOpacity(0.6)),
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                   trailing: const Icon(
                    //                       Icons.keyboard_arrow_right),
                    //                 );
                    //               },
                    //             ),
                    //           )
                    //         : const Expanded(
                    //             child: SubCategoriesShimmerWidget()),
                    //   ])
                    : NoDataWidget(
                        title: getTranslated('category_not_found', context),
                      );
          },
        ),
      )),
    );
  }

  Widget searchBarWidget() {
    return Row(
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
                  borderRadius: BorderRadius.circular(14.0), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.green, // Green border
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(14.0), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.green, // Green border
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
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
    );
  }

  Widget categoryWidget(String categoryName, String categoryID) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style: poppinsSemiBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteHelper.getSubCategoriesRoute(
                        categoryId: categoryID, categoryName: categoryName),
                  );
                },
                child: const Text("View all"))
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        // Display category name and other UI elements
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                categoryProvider.getSubCategories(categoryID)?.length ?? 0,
            itemBuilder: (context, index) {
              final subCategory =
                  categoryProvider.getSubCategories(categoryID)?[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: categoryTile(
                  (subCategory?.id ?? "").toString(),
                  subCategory?.image ?? "",
                  subCategory?.name ?? "",
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget categoryTile(String id, String imgUrl, String categoryName) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    log('------------------------------${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl');
    print(
        'dfdgfdg${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}');
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteHelper.getCategoryProductsRoute(
            categoryId: id.toString(),
            subCategory: categoryName,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 100,
              width: 100,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  image:
                      //  '${splashProvider.baseUrls?.categoryImageUrl?.contains("subcategory") == true ? splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category") : splashProvider.baseUrls?.categoryImageUrl}/$imgUrl',
                      '${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl',
                  fit: BoxFit.cover,
                  height: 100, // Increased height
                  width: 100, // Increased width
                ),
              )),
          const SizedBox(
            height: 12,
          ),
          Text(
            categoryName,
            style: poppinsMedium,
          )
        ],
      ),
    );
  }
}
