import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_slider_list_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/common/widgets/product_widget.dart';
import 'package:flutter_grocery/common/widgets/web_product_shimmer_widget.dart';
import 'package:provider/provider.dart';

class RelatedProductWidget extends StatefulWidget {
  final List<Product>? productList;
  final bool isFlashDeal;
  final bool isFeaturedItem;
  const RelatedProductWidget(
      {this.productList,
      this.isFlashDeal = false,
      this.isFeaturedItem = false,
      super.key});

  @override
  State<RelatedProductWidget> createState() => _RelatedProductWidgetState();
}

class _RelatedProductWidgetState extends State<RelatedProductWidget> {
  @override
  void initState() {
    // TODO: implement initState
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ProductProvider>(context, listen: false)
        .getRelatedProduct(authProvider.getUserToken());
    super.initState();
  }

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    print("------------------home--------------");

    return Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
      return productProvider.reltedProductModel != null
          ? Column(children: [
              widget.isFlashDeal
                  ? SizedBox(
                      height: 340,
                      child: CarouselSlider.builder(
                        itemCount: widget.productList!.length > 5
                            ? 5
                            : widget.productList!.length,
                        options: CarouselOptions(
                          height: 340,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 1000),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          viewportFraction: 0.7,
                          enlargeFactor: 0.2,
                          // onPageChanged: (index, reason) {
                          //   flashDealProvider.setCurrentIndex(index);
                          // },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          return ProductWidget(
                            isGrid: true,
                            product: productProvider
                                .reltedProductModel!.products![index],
                            productType: ProductType.flashSale,
                            isCenter: false,
                          );
                        },
                      ))
                  : SizedBox(
                      height: 280,
                      child: CustomSliderListWidget(
                        controller: scrollController,
                        verticalPosition: widget.isFeaturedItem ? 50 : 120,
                        isShowForwardButton:
                            (widget.productList?.length ?? 0) > 3,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? 0
                                  : Dimensions.paddingSizeSmall),
                          itemCount: widget.productList?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            print(
                                "----------------home------------------------------------${widget.productList![index].image![0]}");
                            if (!widget.isFeaturedItem) {
                              return Container(
                                width: MediaQuery.of(context).size.width / 2.75,
                                height: MediaQuery.of(context).size.width / 3,
                                // width: ResponsiveHelper.isDesktop(context) ? widget.isFeaturedItem ? 370 : 260 : widget.isFeaturedItem ? MediaQuery.of(context).size.width * 0.90 : MediaQuery.of(context).size.width * 0.65,
                                padding: const EdgeInsets.all(5),
                                child: ProductWidget(
                                  isGrid: widget.isFeaturedItem ? false : true,
                                  product: widget.productList![index],
                                  productType: ProductType.dailyItem,
                                  isCenter: false,
                                ),
                              );
                            }
                            //  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product.image!.isNotEmpty ? product.image![0] : ''}'
                            return Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: SizedBox(
                                width: 165,
                                height: 225,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImageWidget(
                                    fit: BoxFit.cover,
                                    image:
                                        '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${widget.productList![index].image!.isNotEmpty ? widget.productList![index].image![0] : ''}',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ])
          : SizedBox(
              height: 250,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: 195,
                    padding: const EdgeInsets.all(5),
                    child: const WebProductShimmerWidget(isEnabled: true),
                  );
                },
              ),
            );
    });
  }
}
