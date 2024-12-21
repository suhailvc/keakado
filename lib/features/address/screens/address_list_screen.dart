import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/app_bar_base_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/features/address/widgets/adress_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'add_new_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  final AddressModel? addressModel;
  const AddressListScreen({Key? key, this.addressModel}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (_isLoggedIn) {
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: ResponsiveHelper.isMobilePhone()
          ? AppBar(
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
                getTranslated('address', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            )
          : (ResponsiveHelper.isDesktop(context)
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
              : const AppBarBaseWidget()) as PreferredSizeWidget?,
      body: _isLoggedIn
          ? Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await locationProvider.initAddressList();
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CustomScrollView(slivers: [
                    SliverToBoxAdapter(
                        child: Center(
                            child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              locationProvider.addressList == null
                                  ? CustomLoaderWidget(
                                      color: Theme.of(context).primaryColor)
                                  : (locationProvider.addressList?.isNotEmpty ??
                                          false)
                                      ? Column(
                                          children: [
                                            ResponsiveHelper.isDesktop(context)
                                                ? GridView.builder(
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisSpacing: 13,
                                                      mainAxisSpacing: 13,
                                                      childAspectRatio: 4.5,
                                                      crossAxisCount: 2,
                                                    ),
                                                    itemCount: locationProvider
                                                        .addressList?.length,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeDefault,
                                                      vertical: Dimensions
                                                          .paddingSizeDefault,
                                                    ),
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return AddressWidget(
                                                        addressModel:
                                                            locationProvider
                                                                    .addressList![
                                                                index],
                                                        index: index,
                                                      );
                                                    },
                                                  )
                                                : ListView.separated(
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeSmall),
                                                    itemCount: locationProvider
                                                            .addressList
                                                            ?.length ??
                                                        0,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) =>
                                                            AddressWidget(
                                                      addressModel:
                                                          locationProvider
                                                                  .addressList![
                                                              index],
                                                      index: index,
                                                    ),
                                                  ),
                                            // (locationProvider.addressList
                                            //                 ?.length ??
                                            //             0) <=
                                            //         4
                                            //     ? const SizedBox(height: 300)
                                            //     : const SizedBox(),
                                          ],
                                        )
                                      : NoDataWidget(
                                          title: getTranslated(
                                              'no_address_found', context)),
                              GestureDetector(
                                onTap: () {
                                  locationProvider.updateAddressStatusMessage(
                                      message: '');
                                  Navigator.of(context).pushNamed(
                                      RouteHelper.getAddAddressRoute(
                                          'address', 'add', AddressModel()),
                                      arguments: const AddNewAddressScreen());
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Text(
                                        " Add Address",
                                        style: poppinsMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
                    const FooterWebWidget(footerType: FooterType.sliver),
                  ]),
                );
              },
            )
          : const NotLoggedInWidget(),
    );
  }
}
