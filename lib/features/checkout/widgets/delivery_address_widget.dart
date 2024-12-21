import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/address/widgets/adress_widget.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final bool selfPickup;

  const DeliveryAddressWidget({
    Key? key,
    required this.selfPickup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    return !selfPickup
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 24),
                child: Text(
                  getTranslated('delivery_to', context),
                  style:
                      poppinsBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Consumer<LocationProvider>(
                    builder: (context, locationProvider, _) =>
                        Consumer<OrderProvider>(
                      builder: (context, orderProvider, _) {
                        bool isAvailable = false;

                        AddressModel? deliveryAddress =
                            CheckOutHelper.getDeliveryAddress(
                          addressList: locationProvider.addressList,
                          selectedAddress: orderProvider.addressIndex == -1
                              ? null
                              : locationProvider
                                  .addressList?[orderProvider.addressIndex],
                          lastOrderAddress: null,
                        );

                        if (deliveryAddress != null) {
                          isAvailable = CheckOutHelper.isBranchAvailable(
                            branches: configModel.branches ?? [],
                            selectedBranch: configModel
                                .branches![orderProvider.branchIndex],
                            selectedAddress: deliveryAddress,
                          );

                          if (!isAvailable) {
                            deliveryAddress = null;
                          }
                        }

                        return locationProvider.addressList == null
                            ? const _DeliverySectionShimmer()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                        height: Dimensions.paddingSizeDefault),
                                    deliveryAddress == null ||
                                            orderProvider.addressIndex == -1
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeDefault),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.info_outline_rounded,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                Text(
                                                  getTranslated(
                                                      'no_address_found',
                                                      context),
                                                  style:
                                                      poppinsRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        :
                                        // Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [
                                        //         Row(children: [
                                        //           Icon(Icons.person,
                                        //               color: Theme.of(context)
                                        //                   .primaryColor
                                        //                   .withOpacity(0.5)),
                                        //           const SizedBox(
                                        //               width: Dimensions
                                        //                   .paddingSizeSmall),
                                        //           Flexible(
                                        //               child: Text(deliveryAddress
                                        //                       .contactPersonName ??
                                        //                   '')),
                                        //         ]),
                                        //         const SizedBox(
                                        //             height: Dimensions
                                        //                 .paddingSizeSmall),
                                        //         Row(children: [
                                        //           Icon(Icons.call,
                                        //               color: Theme.of(context)
                                        //                   .primaryColor
                                        //                   .withOpacity(0.5)),
                                        //           const SizedBox(
                                        //               width: Dimensions
                                        //                   .paddingSizeSmall),
                                        //           Text(deliveryAddress
                                        //                   .contactPersonNumber ??
                                        //               ''),
                                        //         ]),
                                        //         const Divider(
                                        //             height: Dimensions
                                        //                 .paddingSizeDefault),
                                        //         Text(
                                        //             deliveryAddress.address ?? '',
                                        //             maxLines: 1,
                                        //             overflow:
                                        //                 TextOverflow.ellipsis),
                                        //         const SizedBox(
                                        //             height: Dimensions
                                        //                 .paddingSizeSmall),
                                        //         Row(
                                        //             mainAxisAlignment:
                                        //                 MainAxisAlignment.start,
                                        //             children: [
                                        //               if (deliveryAddress
                                        //                       .houseNumber !=
                                        //                   null)
                                        //                 Text(
                                        //                   '${getTranslated('house', context)} - ${deliveryAddress.houseNumber}',
                                        //                   maxLines: 1,
                                        //                   overflow: TextOverflow
                                        //                       .ellipsis,
                                        //                 ),
                                        //               const SizedBox(
                                        //                   width: Dimensions
                                        //                       .paddingSizeSmall),
                                        //               if (deliveryAddress
                                        //                       .floorNumber !=
                                        //                   null)
                                        //                 Text(
                                        //                   '${getTranslated('floor', context)} - ${deliveryAddress.floorNumber}',
                                        //                   maxLines: 1,
                                        //                   overflow: TextOverflow
                                        //                       .ellipsis,
                                        //                 ),
                                        //             ]),
                                        //         const SizedBox(
                                        //           height: Dimensions
                                        //               .paddingSizeDefault,
                                        //         ),
                                        //       ]),
                                        locationProvider.addressList != null
                                            ? locationProvider
                                                    .addressList!.isNotEmpty
                                                ? ListView.separated(
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const Divider(),
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeSmall),
                                                    itemCount: locationProvider
                                                            .addressList
                                                            ?.length ??
                                                        0,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Center(
                                                          child: SizedBox(
                                                              width: 700,
                                                              child:
                                                                  AddressWidget(
                                                                fromSelectAddress:
                                                                    true,
                                                                addressModel:
                                                                    locationProvider
                                                                            .addressList![
                                                                        index],
                                                                index: index,
                                                              )));
                                                    },
                                                  )
                                                : const SizedBox()
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                    GestureDetector(
                                      onTap: () async {
                                        // showDialog(
                                        //   context: context,
                                        //   builder: (_) =>
                                        //       const AddAddressDialogWidget(),
                                        // );
                                        await Navigator.pushNamed(
                                            context,
                                            RouteHelper.getAddAddressRoute(
                                                'checkout',
                                                'add',
                                                AddressModel()));
                                        await locationProvider
                                            .initAddressList();

                                        CheckOutHelper
                                            .selectDeliveryAddressAuto(
                                          isLoggedIn: true,
                                          orderType: orderProvider
                                              .getCheckOutData?.orderType,
                                          lastAddress: null,
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            Text(
                                              " Add Address",
                                              style: poppinsMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}

class _DeliverySectionShimmer extends StatelessWidget {
  const _DeliverySectionShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
        child: Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(2))),
            Container(
                height: 14,
                width: 50,
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(2))),
          ]),
          const Divider(height: Dimensions.paddingSizeDefault),
          Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    height: Dimensions.paddingSizeLarge,
                    width: Dimensions.paddingSizeLarge,
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(2),
                    )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    height: Dimensions.paddingSizeLarge,
                    width: Dimensions.paddingSizeLarge,
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                Container(
                    height: 14,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(2),
                    )),
              ]),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ),
    ]));
  }
}
