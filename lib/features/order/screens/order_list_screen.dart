import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_widget.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    Provider.of<OrderProvider>(context, listen: false)
        .changeActiveOrderStatus(true, isUpdate: false);

    if (isLoggedIn) {
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
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
              scrolledUnderElevation: 0,
              title: Text(
                getTranslated('my_orders', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
      body: isLoggedIn
          ? Consumer<OrderProvider>(builder: (context, orderProvider, child) {
              return Column(
                children: [
                  ResponsiveHelper.isDesktop(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraLarge),
                          child: Text("my_orders".tr,
                              style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E7E7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            splashFactory: NoSplash.splashFactory,
                            splashColor: Colors.transparent,
                          ),
                          child: TabBar(
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            onTap: (int? index) => orderProvider
                                .changeActiveOrderStatus(index == 0),
                            tabAlignment: TabAlignment.center,
                            controller: _tabController,
                            dividerColor: ColorResources.scaffoldGrey,
                            labelColor:
                                Theme.of(context).textTheme.bodyLarge!.color,
                            indicatorColor: ColorResources.scaffoldGrey,
                            indicator: const BoxDecoration(
                              color: ColorResources.scaffoldGrey,
                            ),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 0.1,
                            unselectedLabelStyle: poppinsRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                            labelStyle: poppinsMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                            tabs: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabController?.index == 0
                                      ? Colors.white
                                      : const Color(0xFFE7E7E7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  getTranslated('ongoing', context),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabController?.index == 1
                                      ? Colors.white
                                      : const Color(0xFFE7E7E7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  getTranslated('history', context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OrderWidget(isRunning: true),
                      OrderWidget(isRunning: false),
                    ],
                  )),
                ],
              );
            })
          : const NotLoggedInWidget(),
    );
  }
}
