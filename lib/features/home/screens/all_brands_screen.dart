import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/home/screens/brand_products_screen.dart';
import 'package:flutter_grocery/helper/default_bottom_bar.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({Key? key}) : super(key: key);

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  late ProductProvider productProvider;

  @override
  void initState() {
    super.initState();
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.getAllBrands(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          getTranslated("Brands", context),
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
          if (provider.brandsModel == null ||
              provider.brandsModel!.data.isEmpty) {
            return Center(
              child: Text(
                getTranslated("No Brands Available", context),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BrandProductsScreen(
                        brandName: provider.brandsModel!.data[index].name,
                        brandId:
                            provider.brandsModel!.data[index].id.toString(),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    CustomImageWidget(
                      image: provider.brandsModel!.data[index].image,
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
              );
            },
            itemCount: provider.brandsModel!.data.length,
          );
        },
      ),
      bottomNavigationBar: const DefaultBottomBar(index: 0),
    );
  }
}
