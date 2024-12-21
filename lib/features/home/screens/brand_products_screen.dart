import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/product_widget.dart';
import 'package:flutter_grocery/helper/default_bottom_bar.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:provider/provider.dart';

class BrandProductsScreen extends StatefulWidget {
  final String brandName;
  final String brandId;
  const BrandProductsScreen(
      {Key? key, required this.brandName, required this.brandId})
      : super(key: key);

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  late ProductProvider productProvider;

  @override
  void initState() {
    super.initState();
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.getAllBrandProducts(widget.brandId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          getTranslated(widget.brandName, context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CustomLoaderWidget(
                color: ColorResources.colorGreen,
              ),
            );
          }
          if (provider.brandProductModel == null ||
              provider.brandProductModel!.products == null ||
              provider.brandProductModel!.products!.isEmpty) {
            return Center(
              child: Text(
                getTranslated("No Proudcts Available Available", context),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
              childAspectRatio:
                  ResponsiveHelper.isDesktop(context) ? (1 / 1.4) : (1 / 1.8),
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            itemCount: productProvider.brandProductModel!.products!.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ProductWidget(
                product: productProvider.brandProductModel!.products![index],
                isCenter: false,
                isGrid: true,
              );
            },
          );
        },
      ),
      bottomNavigationBar: const DefaultBottomBar(index: 0),
    );
  }
}
