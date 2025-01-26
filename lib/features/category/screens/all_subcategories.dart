import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AllSubCategories extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const AllSubCategories({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<AllSubCategories> createState() => _AllSubCategoriesState();
}

class _AllSubCategoriesState extends State<AllSubCategories> {
  List<CategoryModel> categories = [];
  List<CategoryModel> allCategories = [];
  // @override
  // void initState() {
  //   final categoryProvider =
  //       Provider.of<CategoryProvider>(context, listen: false);
  //   // categoryProvider.initializeAllSortBy(context);

  //   categories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
  //   allCategories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false)
          .getSubCategoryList(context, widget.categoryId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<CategoryProvider>(context);
    setState(() {
      categories = provider.getSubCategories(widget.categoryId) ?? [];
      allCategories = categories;
    });
  }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   final categoryProvider = Provider.of<CategoryProvider>(context);
  //   // categoryProvider.initializeAllSortBy(context);

  //   categories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
  //   allCategories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    print('---------length${widget.categoryId}');
    print('---------length${categories.length}');
    // final categoryProvider =
    //     Provider.of<CategoryProvider>(context); // Removed listen: false
    var querySize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated(widget.categoryName, context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // actions: [
        //   PopupMenuButton<String>(
        //     elevation: 20,
        //     icon: Icon(
        //       Icons.more_vert,
        //       color: Theme.of(context).textTheme.bodyLarge!.color,
        //     ),
        //     onSelected: (String? value) {
        //       int index = categoryProvider.allSortBy.indexOf(value);
        //       categoryProvider.sortCategoryProduct(index);
        //     },
        //     itemBuilder: (context) {
        //       return categoryProvider.allSortBy.map((choice) {
        //         return PopupMenuItem<String>(
        //           value: choice,
        //           child: Text(getTranslated(choice, context)),
        //         );
        //       }).toList();
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          searchBarWidget(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                maxCrossAxisExtent: querySize.width / 3,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return categoryTile(
                  categories[index].id,
                  categories[index].image ?? "",
                  categories[index].name ?? "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBarWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    categories = allCategories;
                  } else {
                    categories = allCategories
                        .where(
                          (element) => (element.name ?? "_")
                              .toLowerCase()
                              .contains(value.toLowerCase()),
                        )
                        .toList();
                  }
                  setState(() {});
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
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

  Widget categoryTile(int? id, String imgUrl, String categoryName) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    var querySize = MediaQuery.of(context).size;
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
                      '${splashProvider.baseUrls?.categoryImageUrl?.contains("subcategory") == true ? splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category") : splashProvider.baseUrls?.categoryImageUrl}/$imgUrl',
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                ),
              )),
          SizedBox(
            height: querySize.width * 0.005,
          ),
          Text(
            categoryName,
            style: poppinsMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}



// class AllSubCategories extends StatefulWidget {
//   final String categoryId;
//   final String categoryName;
//   const AllSubCategories(
//       {Key? key, required this.categoryId, required this.categoryName})
//       : super(key: key);

//   @override
//   State<AllSubCategories> createState() => _AllSubCategoriesState();
// }

// class _AllSubCategoriesState extends State<AllSubCategories> {
//   List<CategoryModel> categories = [];
//   List<CategoryModel> allCategories = [];

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final categoryProvider = Provider.of<CategoryProvider>(context);
//     categoryProvider.initializeAllSortBy(context);
//     categories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
//     allCategories = categoryProvider.getSubCategories(widget.categoryId) ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final CategoryProvider categoryProvider =
//         Provider.of<CategoryProvider>(context);
//     var querySize = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           getTranslated(widget.categoryName, context),
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           PopupMenuButton(
//               elevation: 20,
//               // enabled: true,
//               icon: Icon(Icons.more_vert,
//                   color: Theme.of(context).textTheme.bodyLarge!.color),
//               onSelected: (String? value) {
//                 int index = categoryProvider.allSortBy.indexOf(value);
//                 categoryProvider.sortCategoryProduct(index);
//               },
//               itemBuilder: (context) {
//                 return categoryProvider.allSortBy.map((choice) {
//                   return PopupMenuItem(
//                     value: choice,
//                     child: Text(getTranslated(choice, context)),
//                   );
//                 }).toList();
//               })
//           // PopupMenuButton(
//           //     elevation: 20,
//           //     enabled: true,
//           //     icon: Icon(Icons.more_vert,
//           //         color: Theme.of(context).textTheme.bodyLarge!.color),
//           //     onSelected: (String? value) {
//           //       int index = categoryProvider.allSortBy.indexOf(value);
//           //       categoryProvider.sortCategoryProduct(index);
//           //     },
//           //     itemBuilder: (context) {
//           //       return categoryProvider.allSortBy.map((choice) {
//           //         return PopupMenuItem(
//           //           value: choice,
//           //           child: Text(getTranslated(choice, context)),
//           //         );
//           //       }).toList();
//           //     })
//         ],
//       ),
//       body: Column(
//         children: [
//           searchBarWidget(),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 16), // Adjust padding here
//               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                 crossAxisSpacing: 16, // Adjust the spacing here
//                 mainAxisSpacing: 16, // Adjust the spacing here
//                 maxCrossAxisExtent: querySize.width /
//                     3, // Dividing the width by 3 to fit three items per row
//                 childAspectRatio:
//                     0.8, // Adjust this ratio based on item dimensions
//               ),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 return categoryTile(
//                   categories[index].id,
//                   categories[index].image ?? "",
//                   categories[index].name ?? "",
//                 );
//               },
//             ),
//             // child: GridView.builder(
//             //   padding: const EdgeInsets.symmetric(horizontal: 24),
//             //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//             //     crossAxisSpacing: 1,
//             //     childAspectRatio: 0.91,
//             //     mainAxisSpacing: querySize.width * 0.05,
//             //     maxCrossAxisExtent: querySize.width * 0.299,
//             //   ),
//             //   itemBuilder: (context, index) {
//             //     print(
//             //         "----------------------------------------------------------------------------------------------------${categories[index].image}");
//             //     return categoryTile(
//             //         categories[index].id,
//             //         categories[index].image ?? "",
//             //         categories[index].name ?? "");
//             //   },
//             //   itemCount: categories.length,
//             // ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget searchBarWidget() {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 onChanged: (value) {
//                   if (value.isEmpty) {
//                     categories = allCategories;
//                   } else {
//                     categories = allCategories
//                         .where(
//                           (element) => (element.name ?? "_")
//                               .toLowerCase()
//                               .contains(value.toLowerCase()),
//                         )
//                         .toList();
//                   }
//                   setState(() {});
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

//   Widget categoryTile(int? id, String imgUrl, String categoryName) {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     print(
//         'dfdgfdg${splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category")}/$imgUrl');
//     var querySize = MediaQuery.of(context).size;
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
//                       '${splashProvider.baseUrls?.categoryImageUrl?.contains("subcategory") == true ? splashProvider.baseUrls?.categoryImageUrl?.replaceFirst("subcategory", "category") : splashProvider.baseUrls?.categoryImageUrl}/$imgUrl',
//                   fit: BoxFit.cover,
//                   height: 100, // Increased height
//                   width: 100, // Increased width
//                 ),
//               )),
//           SizedBox(
//             height: querySize.width * 0.005,
//           ),
//           // Row(
//           //   children: [
//           //     Flexible(
//           //child:
//           Text(
//             categoryName,
//             style: poppinsMedium,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           //     ),
//           //   ],
//           // )
//         ],
//       ),
//     );
//   }
// }
