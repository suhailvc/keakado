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

// class _AllCategoriesScreenState extends State<AllCategoriesScreen>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);

//     if (categoryProvider.categoryList?.isNotEmpty ?? false) {
//       _load();
//     } else {
//       final apiResponse = await categoryProvider.getCategoryList(context, true);
//       if (apiResponse.response?.statusCode == 200) {
//         _load();
//       }
//     }
//   }

//   Future<void> _load() async {
//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);
//     categoryProvider.onChangeCategoryIndex(0, notify: false);

//     if (categoryProvider.categoryList?.isNotEmpty ?? false) {
//       for (var category in categoryProvider.categoryList!) {
//         if (categoryProvider
//                 .subCategoryMap[category.id.toString()]?.isNotEmpty ??
//             false) {
//           continue;
//         }
//         await categoryProvider.getSubCategoryList(
//             context, category.id.toString());
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           getTranslated("category", context),
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Center(
//         child: SizedBox(
//           width: Dimensions.webScreenWidth,
//           child: Consumer<CategoryProvider>(
//             builder: (context, categoryProvider, child) {
//               if (categoryProvider.categoryList == null) {
//                 return Center(
//                   child:
//                       CustomLoaderWidget(color: Theme.of(context).primaryColor),
//                 );
//               }

//               if (categoryProvider.categoryList?.isEmpty ?? true) {
//                 return NoDataWidget(
//                   title: getTranslated('category_not_found', context),
//                 );
//               }

//               return Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     searchBarWidget(),
//                     const SizedBox(height: 18),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         itemCount: categoryProvider.categoryList?.length ?? 0,
//                         cacheExtent: 400,
//                         itemBuilder: (context, index) {
//                           if (index >= categoryProvider.categoryList!.length) {
//                             return const SizedBox.shrink();
//                           }

//                           final category =
//                               categoryProvider.categoryList![index];
//                           final subCategories = categoryProvider
//                                   .getSubCategories(category.id.toString()) ??
//                               [];

//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 24),
//                             child: _CategorySection(
//                               categoryName: category.name ?? "",
//                               categoryID: category.id.toString(),
//                               subCategories: subCategories,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
class _AllCategoriesScreenState extends State<AllCategoriesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      false; // Changed to false since we don't need caching

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.categoryList != null &&
        categoryProvider.categoryList!.isNotEmpty) {
      _load();
    } else {
      categoryProvider.getCategoryList(context, true).then((apiResponse) {
        if (apiResponse.response!.statusCode == 200) {
          _load();
        }
      });
    }
  }

  Future<void> _load() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.onChangeCategoryIndex(0, notify: false);

    if (categoryProvider.categoryList?.isNotEmpty ?? false) {
      for (var category in categoryProvider.categoryList!) {
        if (categoryProvider
                .subCategoryMap[category.id.toString()]?.isNotEmpty ??
            false) {
          continue;
        }
        await categoryProvider.getSubCategoryList(
            context, category.id.toString());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated("category", context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categoryList == null) {
            return Center(
              child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
            );
          }

          if (categoryProvider.categoryList!.isEmpty) {
            return NoDataWidget(
              title: getTranslated('category_not_found', context),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                searchBarWidget(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: categoryProvider.categoryList!.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categoryList![index];
                      final subCategories = categoryProvider
                              .getSubCategories(category.id.toString()) ??
                          [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name ?? "",
                                style: poppinsSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteHelper.getSubCategoriesRoute(
                                      categoryId: category.id.toString(),
                                      categoryName: category.name ?? "",
                                    ),
                                  );
                                },
                                child: Text(getTranslated('view_all', context)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: subCategories.length,
                              itemBuilder: (context, subIndex) {
                                final subCategory = subCategories[subIndex];
                                final String imageUrl =
                                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/${subCategory.image}';

                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        RouteHelper.getCategoryProductsRoute(
                                          categoryId: subCategory.id.toString(),
                                          subCategory: subCategory.name,
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 100,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          subCategory.name ?? "",
                                          style: poppinsMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
}

class _CategorySection extends StatelessWidget {
  final String categoryName;
  final String categoryID;
  final List<CategoryModel> subCategories;

  const _CategorySection({
    required this.categoryName,
    required this.categoryID,
    required this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style:
                  poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                RouteHelper.getSubCategoriesRoute(
                  categoryId: categoryID,
                  categoryName: categoryName,
                ),
              ),
              child: Text(getTranslated('view_all', context)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _CategoryTile(
                  id: (subCategory.id ?? "").toString(),
                  imgUrl: subCategory.image ?? "",
                  categoryName: subCategory.name ?? "",
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String id;
  final String imgUrl;
  final String categoryName;

  const _CategoryTile({
    required this.id,
    required this.imgUrl,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final imageUrl =
        '${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteHelper.getCategoryProductsRoute(
            categoryId: id,
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageWidget(
                image: imageUrl,
                fit: BoxFit.cover,
                height: 100,
                width: 100,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            categoryName,
            style: poppinsMedium,
          ),
        ],
      ),
    );
  }
}
// class AllCategoriesScreen extends StatefulWidget {
//   const AllCategoriesScreen({Key? key}) : super(key: key);

//   @override
//   State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
// }

// class _AllCategoriesScreenState extends State<AllCategoriesScreen>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;
//   @override
//   void initState() {
//     super.initState();
//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);

//     if (categoryProvider.categoryList != null &&
//         categoryProvider.categoryList!.isNotEmpty) {
//       _load(); // Using updated _load()
//     } else {
//       categoryProvider.getCategoryList(context, true).then((apiResponse) {
//         if (apiResponse.response!.statusCode == 200 &&
//             apiResponse.response!.data != null) {
//           _load(); // Using updated _load()
//         }
//       });
//     }
//   } // @override
//   // void initState() {
//   //   super.initState();
//   //   if (Provider.of<CategoryProvider>(context, listen: false).categoryList !=
//   //           null &&
//   //       Provider.of<CategoryProvider>(context, listen: false)
//   //           .categoryList!
//   //           .isNotEmpty) {
//   //     _load();
//   //   } else {
//   //     Provider.of<CategoryProvider>(context, listen: false)
//   //         .getCategoryList(context, true)
//   //         .then((apiResponse) {
//   //       if (apiResponse.response!.statusCode == 200 &&
//   //           apiResponse.response!.data != null) {
//   //         _load();
//   //       }
//   //     });
//   //   }
//   // }

//   Future<void> _load() async {
//     final categoryProvider =
//         Provider.of<CategoryProvider>(context, listen: false);
//     categoryProvider.onChangeCategoryIndex(0, notify: false);

//     if (categoryProvider.categoryList?.isNotEmpty ?? false) {
//       for (var category in categoryProvider.categoryList!) {
//         // Skip fetching if subcategories for this categoryID are already loaded
//         if (categoryProvider
//                 .subCategoryMap[category.id.toString()]?.isNotEmpty ??
//             false) {
//           continue;
//         }
//         await categoryProvider.getSubCategoryList(
//             context, category.id.toString());
//       }
//     }
//   } // Future<void> _load() async {
//   //   final categoryProvider =
//   //       Provider.of<CategoryProvider>(context, listen: false);
//   //   categoryProvider.onChangeCategoryIndex(0, notify: false);

//   //   if (categoryProvider.categoryList?.isNotEmpty ?? false) {
//   //     // Use Future.wait to ensure all calls complete
//   //     await Future.wait(categoryProvider.categoryList!.map((category) async {
//   //       await categoryProvider.getSubCategoryList(
//   //           context, category.id.toString());
//   //     }));
//   //   }
//   // }
//   // _load() {
//   //   final categoryProvider =
//   //       Provider.of<CategoryProvider>(context, listen: false);
//   //   categoryProvider.onChangeCategoryIndex(0, notify: false);

//   //   // Ensure the category list is not empty before fetching subcategories
//   //   if (categoryProvider.categoryList?.isNotEmpty ?? false) {
//   //     for (var category in categoryProvider.categoryList!) {
//   //       // Fetch subcategory list for each category
//   //       categoryProvider.getSubCategoryList(context, category.id.toString());
//   //     }
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           getTranslated("category", context),
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Center(
//           child: SizedBox(
//         width: Dimensions.webScreenWidth,
//         child: Consumer<CategoryProvider>(
//           builder: (context, categoryProvider, child) {
//             return categoryProvider.categoryList == null
//                 ? Center(
//                     child: CustomLoaderWidget(
//                         color: Theme.of(context).primaryColor),
//                   )
//                 : categoryProvider.categoryList?.isNotEmpty ?? false
//                     ? Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             searchBarWidget(),
//                             const SizedBox(
//                               height: 18,
//                             ),
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount:
//                                     categoryProvider.categoryList?.length ??
//                                         0, // Ensure safe access
//                                 // cacheExtent: 400,
//                                 itemBuilder: (context, index) {
//                                   if (index >=
//                                       categoryProvider.categoryList!.length) {
//                                     return const SizedBox
//                                         .shrink(); // Avoid out-of-range error
//                                   }

//                                   final category =
//                                       categoryProvider.categoryList![index];
//                                   final entry = categoryProvider
//                                       .subCategoryMap.entries
//                                       .elementAtOrNull(index);

//                                   if (entry == null) {
//                                     return const SizedBox
//                                         .shrink(); // Handle cases where map entry is missing
//                                   }
//                                   final subCategories =
//                                       categoryProvider.getSubCategories(
//                                               category.id.toString()) ??
//                                           [];
//                                   final String categoryID = entry.key;
//                                   return categoryWidget(category.name ?? "",
//                                       categoryID, subCategories);
//                                 },
//                               ),
//                             )

//                             // Expanded(
//                             //   child: ListView.builder(
//                             //       itemBuilder: (context, index) {
//                             //         final entry = categoryProvider
//                             //             .subCategoryMap.entries
//                             //             .elementAt(index);
//                             //         final String categoryID =
//                             //             entry.key; // Extract category ID
//                             //         return categoryWidget(
//                             //             categoryProvider
//                             //                     .categoryList![index].name ??
//                             //                 "",
//                             //             categoryID);
//                             //       },
//                             //       itemCount:
//                             //           categoryProvider.categoryList!.length,
//                             //       shrinkWrap: true,
//                             //       padding: const EdgeInsets.only(left: 0)),
//                             // )
//                           ],
//                         ),
//                       )
//                     // ? Row(children: [
//                     //     Container(
//                     //       width: 120,
//                     //       margin: const EdgeInsets.symmetric(
//                     //           vertical: Dimensions.paddingSizeSmall),
//                     //       height: double.maxFinite,
//                     //       decoration: BoxDecoration(
//                     //         boxShadow: [
//                     //           BoxShadow(
//                     //               color: Theme.of(context).shadowColor,
//                     //               spreadRadius: 3,
//                     //               blurRadius: 10)
//                     //         ],
//                     //       ),
//                     //       child: ListView.builder(
//                     //         physics: const BouncingScrollPhysics(),
//                     //         itemCount: categoryProvider.categoryList!.length,
//                     //         padding: const EdgeInsets.symmetric(
//                     //             horizontal: Dimensions.paddingSizeSmall),
//                     //         itemBuilder: (context, index) {
//                     //           CategoryModel category =
//                     //               categoryProvider.categoryList![index];
//                     //           return InkWell(
//                     //             onTap: () {
//                     //               categoryProvider.onChangeCategoryIndex(index);
//                     //               categoryProvider.getSubCategoryList(
//                     //                   context, category.id.toString());
//                     //             },
//                     //             child: CategoryItemWidget(
//                     //               title: category.name,
//                     //               icon: category.image,
//                     //               isSelected:
//                     //                   categoryProvider.categoryIndex == index,
//                     //             ),
//                     //           );
//                     //         },
//                     //       ),
//                     //     ),
//                     //     categoryProvider.subCategoryList != null
//                     //         ? Expanded(
//                     //             child: ListView.builder(
//                     //               padding: const EdgeInsets.all(
//                     //                   Dimensions.paddingSizeSmall),
//                     //               itemCount:
//                     //                   categoryProvider.subCategoryList!.length +
//                     //                       1,
//                     //               itemBuilder: (context, index) {
//                     //                 if (index == 0) {
//                     //                   return ListTile(
//                     //                     onTap: () {
//                     //                       categoryProvider
//                     //                           .onChangeSelectIndex(-1);
//                     //                       categoryProvider
//                     //                           .initCategoryProductList(
//                     //                         categoryProvider
//                     //                             .categoryList![categoryProvider
//                     //                                 .categoryIndex]
//                     //                             .id
//                     //                             .toString(),
//                     //                       );
//                     //                       Navigator.of(context).pushNamed(
//                     //                         RouteHelper
//                     //                             .getCategoryProductsRoute(
//                     //                           categoryId:
//                     //                               '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
//                     //                         ),
//                     //                       );
//                     //                     },
//                     //                     title:
//                     //                         Text(getTranslated('all', context)),
//                     //                     trailing: const Icon(
//                     //                         Icons.keyboard_arrow_right),
//                     //                   );
//                     //                 }
//                     //                 return ListTile(
//                     //                   onTap: () {
//                     //                     categoryProvider
//                     //                         .onChangeSelectIndex(index - 1);
//                     //                     if (ResponsiveHelper.isMobilePhone()) {}
//                     //                     categoryProvider
//                     //                         .initCategoryProductList(
//                     //                       categoryProvider
//                     //                           .subCategoryList![index - 1].id
//                     //                           .toString(),
//                     //                     );

//                     //                     Navigator.of(context).pushNamed(
//                     //                       RouteHelper.getCategoryProductsRoute(
//                     //                         categoryId:
//                     //                             '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
//                     //                         subCategory: categoryProvider
//                     //                             .subCategoryList![index - 1]
//                     //                             .name,
//                     //                       ),
//                     //                     );
//                     //                   },
//                     //                   title: Text(
//                     //                     categoryProvider
//                     //                         .subCategoryList![index - 1].name!,
//                     //                     style: poppinsMedium.copyWith(
//                     //                         fontSize: 13,
//                     //                         color: Theme.of(context)
//                     //                             .textTheme
//                     //                             .bodyLarge
//                     //                             ?.color
//                     //                             ?.withOpacity(0.6)),
//                     //                     overflow: TextOverflow.ellipsis,
//                     //                   ),
//                     //                   trailing: const Icon(
//                     //                       Icons.keyboard_arrow_right),
//                     //                 );
//                     //               },
//                     //             ),
//                     //           )
//                     //         : const Expanded(
//                     //             child: SubCategoriesShimmerWidget()),
//                     //   ])
//                     : NoDataWidget(
//                         title: getTranslated('category_not_found', context),
//                       );
//           },
//         ),
//       )),
//     );
//   }

//   Widget searchBarWidget() {
//     return Row(
//       children: [
//         Expanded(
//           child: SizedBox(
//             height: 45,
//             child: TextField(
//               readOnly: true,
//               onTap: () {
//                 Navigator.pushNamed(context, RouteHelper.searchProduct);
//               },
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                 border: OutlineInputBorder(
//                   borderSide: const BorderSide(
//                     color: Colors.green, // Green border
//                     width: 1.0, // Border width
//                   ),
//                   borderRadius: BorderRadius.circular(14.0), // Rounded corners
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(
//                     color: Colors.green, // Green border
//                     width: 1.0, // Border width
//                   ),
//                   borderRadius: BorderRadius.circular(14.0), // Rounded corners
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(
//                     color: Colors.green, // Green border
//                     width: 1.0, // Border width
//                   ),
//                   borderRadius: BorderRadius.circular(16.0), // Rounded corners
//                 ),
//                 prefixIcon: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: SvgPicture.asset(
//                     "assets/svg/search.svg",
//                   ),
//                 ),
//                 // suffixIcon: Padding(
//                 //   padding: const EdgeInsets.all(12.0),
//                 //   child: SvgPicture.asset(
//                 //     "assets/svg/scan_icon.svg",
//                 //   ),
//                 // ),
//                 hintText: getTranslated("search", context),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget categoryWidget(String categoryName, String categoryID,
//       List<CategoryModel> subCategories) {
//     // final categoryProvider =
//     //     Provider.of<CategoryProvider>(context, listen: false);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               categoryName,
//               style: poppinsSemiBold.copyWith(
//                 fontSize: Dimensions.fontSizeLarge,
//               ),
//             ),
//             GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     RouteHelper.getSubCategoriesRoute(
//                         categoryId: categoryID, categoryName: categoryName),
//                   );
//                 },
//                 child: Text(getTranslated('view_all', context)))
//           ],
//         ),
//         const SizedBox(
//           height: 12,
//         ),
//         // Display category name and other UI elements
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             //  cacheExtent: 400,
//             scrollDirection: Axis.horizontal,
//             itemCount: subCategories.length,
//             // categoryProvider.getSubCategories(categoryID)?.length ?? 0,
//             itemBuilder: (context, index) {
//               final subCategory = subCategories[index];
//               // final subCategory =
//               //     categoryProvider.getSubCategories(categoryID)?[index];
//               return Padding(
//                 padding: const EdgeInsets.only(right: 12.0),
//                 child: categoryTile(
//                   (subCategory?.id ?? "").toString(),
//                   subCategory?.image ?? "",
//                   subCategory?.name ?? "",
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget categoryTile(String id, String imgUrl, String categoryName) {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     log('------------------------------${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl');
//     log('dfdgfdg${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}');
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).pushNamed(
//           RouteHelper.getCategoryProductsRoute(
//             categoryId: id.toString(),
//             subCategory: categoryName,
//           ),
//         );
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//               height: 100,
//               width: 100,
//               decoration:
//                   BoxDecoration(borderRadius: BorderRadius.circular(12)),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: CustomImageWidget(
//                   image:
//                       //  '${splashProvider.baseUrls?.categoryImageUrl?.contains("subcategory") == true ? splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category") : splashProvider.baseUrls?.categoryImageUrl}/$imgUrl',
//                       '${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl',
//                   fit: BoxFit.cover,
//                   height: 100, // Increased height
//                   width: 100, // Increased width
//                 ),
//               )),
//           const SizedBox(
//             height: 12,
//           ),
//           Text(
//             categoryName,
//             style: poppinsMedium,
//           )
//         ],
//       ),
//     );
//   }
// }
