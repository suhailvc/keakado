import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/product_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/web_product_shimmer_widget.dart';
import 'package:flutter_grocery/features/cart/screens/cart_screen.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/default_bottom_bar.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryId;
  final String? subCategoryName;
  final bool isSingleLine;
  const CategoryProductScreen({
    Key? key,
    required this.categoryId,
    this.subCategoryName,
    this.isSingleLine = false,
  }) : super(key: key);

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  void _loadData(BuildContext context) async {
    final CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    if (categoryProvider.selectedCategoryIndex == -1) {
      // categoryProvider.getCategory(int.tryParse(widget.categoryId), context);

      // categoryProvider.getSubCategoryList(context, widget.categoryId);

      categoryProvider.initCategoryProductList(widget.categoryId);
    }
  }

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    String? appBarText = 'Sub Categories';
    if (widget.subCategoryName != null &&
        widget.subCategoryName != 'null' &&
        widget.subCategoryName!.isNotEmpty) {
      appBarText = widget.subCategoryName;
    } else {
      appBarText = categoryProvider.categoryModel?.name ?? 'name';
    }
    categoryProvider.initializeAllSortBy(context);

    return widget.isSingleLine
        ? bodyWidget()
        : Scaffold(
            appBar: (ResponsiveHelper.isDesktop(context)
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(120),
                    child: WebAppBarWidget())
                : AppBar(
                    backgroundColor: Theme.of(context).cardColor,
                    leading: GestureDetector(
                      onTap: () {
                        splashProvider.setPageIndex(0);
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        size: 30,
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      getTranslated(appBarText, context),
                      style: poppinsSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    actions: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CartScreen(),
                                  ));
                            },
                            icon: Image.asset(
                              'assets/image/cart_topbar.png',
                              width: MediaQuery.of(context).size.width * 0.05,
                              height: MediaQuery.of(context).size.width * 0.05,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                return cartProvider.cartList.isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          cartProvider.cartList.length
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        elevation: 20,
                        icon: Image.asset(
                          'assets/image/filter.png',
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.width * 0.05,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        onSelected: (String? value) {
                          int index = categoryProvider.allSortBy.indexOf(value);
                          categoryProvider.sortCategoryProduct(index);
                        },
                        itemBuilder: (context) {
                          return categoryProvider.allSortBy.map((choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(getTranslated(choice, context)),
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox(width: 10), // Add some padding at the end
                    ],
                    // actions: [
                    //   PopupMenuButton<String>(
                    //     elevation: 20,
                    //     icon: Image.asset(
                    //       'assets/image/filter.png',
                    //       width: MediaQuery.of(context).size.width *
                    //           0.06, // 6% of screen width
                    //       height: MediaQuery.of(context).size.width * 0.06,
                    //       color: Theme.of(context).textTheme.bodyLarge?.color,
                    //     ),
                    //     // Icon(
                    //     //   Icons.more_vert,
                    //     //   color: Theme.of(context).textTheme.bodyLarge!.color,
                    //     // ),
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
                  )) as PreferredSizeWidget?,
            body: bodyWidget(),
          );
  }

  Consumer<CategoryProvider> bodyWidget() {
    return Consumer<CategoryProvider>(
        builder: (context, productProvider, child) {
      return Column(
        crossAxisAlignment: ResponsiveHelper.isDesktop(context)
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Expanded(
              child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: productProvider.subCategoryProductList.isNotEmpty
                    ? Center(
                        child: SizedBox(
                          width: Dimensions.webScreenWidth,
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing:
                                  ResponsiveHelper.isDesktop(context) ? 13 : 10,
                              mainAxisSpacing:
                                  ResponsiveHelper.isDesktop(context) ? 13 : 10,
                              childAspectRatio:
                                  ResponsiveHelper.isDesktop(context)
                                      ? (1 / 1.4)
                                      : (1 / 1.8),
                              crossAxisCount:
                                  ResponsiveHelper.isDesktop(context) ? 5 : 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeSmall),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.isSingleLine
                                ? productProvider
                                            .subCategoryProductList.length >
                                        4
                                    ? 4
                                    : productProvider
                                        .subCategoryProductList.length
                                : productProvider.subCategoryProductList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ProductWidget(
                                  product: productProvider
                                      .subCategoryProductList[index],
                                  isCenter: false,
                                  isGrid: true);
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: (productProvider.hasData ?? false)
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall),
                                child: _ProductShimmer(isEnabled: true),
                              )
                            : NoDataWidget(
                                isFooter: false,
                                title: getTranslated(
                                    'not_product_found', context)),
                      ))),
            const FooterWebWidget(footerType: FooterType.sliver),
          ])),
          // const DefaultBottomBar(index: 0)
          // const CategoryCartTitleWidget(),
        ],
      );
    });
  }
}

// ignore: unused_element
class _SubcategoryTitleShimmer extends StatelessWidget {
  const _SubcategoryTitleShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        itemCount: 5,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeExtraSmall),
                alignment: Alignment.center,
                margin:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.titleLarge!.color,
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: 20,
                  width: 60,
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorResources.getGreyColor(context),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class _ProductShimmer extends StatelessWidget {
  final bool isEnabled;

  const _ProductShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
            childAspectRatio:
                ResponsiveHelper.isDesktop(context) ? (1 / 1.4) : (1 / 1.6),
            crossAxisCount: ResponsiveHelper.isDesktop(context)
                ? 5
                : ResponsiveHelper.isTab(context)
                    ? 2
                    : 2,
          ),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) =>
              const WebProductShimmerWidget(isEnabled: true),
          itemCount: 20,
        ),
      ],
    );
  }
}
