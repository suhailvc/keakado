import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_item_widget.dart';
import 'package:provider/provider.dart';

class OrderWidget extends StatefulWidget {
  final bool isRunning;
  const OrderWidget({Key? key, required this.isRunning}) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  Timer? _debounceTimer;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<OrderProvider>(context, listen: false)
          .getOrderList(context);
      _retryCount = 0;
    } catch (e) {
      if (_retryCount < maxRetries) {
        _retryCount++;
        await Future.delayed(retryDelay * _retryCount);
        if (mounted) {
          _fetchOrders();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getTranslated('failed_to_load_orders', context)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      await _fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      body: Consumer<OrderProvider>(
        builder: (context, order, index) {
          List<OrderModel>? orderList;
          if (order.runningOrderList != null) {
            orderList = widget.isRunning
                ? order.runningOrderList!.reversed.toList()
                : order.historyOrderList!.reversed.toList();
          }

          if (_isLoading && orderList == null) {
            return Center(
                child:
                    CustomLoaderWidget(color: Theme.of(context).primaryColor));
          }

          return orderList != null
              ? orderList.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: _handleRefresh,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                            child: Center(
                                child: SizedBox(
                          width: Dimensions.webScreenWidth,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault),
                            itemCount: orderList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeSmall),
                                child: OrderItemWidget(
                                    orderList: orderList, index: index),
                              );
                            },
                          ),
                        ))),
                        const FooterWebWidget(footerType: FooterType.sliver),
                      ]),
                    )
                  : NoDataWidget(
                      image: Images.emptyOrderImage,
                      title: getTranslated('no_order_history', context),
                      subTitle: getTranslated('buy_something_to_see', context),
                      isShowButton: true,
                    )
              : Center(
                  child: CustomLoaderWidget(
                      color: Theme.of(context).primaryColor));
        },
      ),
    );
  }
}
// class OrderWidget extends StatefulWidget {
//   final bool isRunning;
//   const OrderWidget({Key? key, required this.isRunning}) : super(key: key);

//   @override
//   State<OrderWidget> createState() => _OrderWidgetState();
// }

// class _OrderWidgetState extends State<OrderWidget> {
// //  bool _isFirstLoad = true;
//   // @override
//   // void didChangeDependencies() {
//   //   if (_isFirstLoad) {
//   //     Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
//   //     _isFirstLoad = false;
//   //   }
//   //   super.didChangeDependencies();
//   // }

//   @override
//   Widget build(BuildContext context) {
//   print('order_widget');
//     return Scaffold(
//       backgroundColor: ColorResources.scaffoldGrey,
//       body: Consumer<OrderProvider>(
//         builder: (context, order, index) {
//           List<OrderModel>? orderList;
//           if (order.runningOrderList != null) {
//             orderList = widget.isRunning
//                 ? order.runningOrderList!.reversed.toList()
//                 : order.historyOrderList!.reversed.toList();
//           }

//           return orderList != null
//               ? orderList.isNotEmpty
//                   ? RefreshIndicator(
//                       onRefresh: () async {
//                         await Provider.of<OrderProvider>(context, listen: false)
//                             .getOrderList(context);
//                       },
//                       backgroundColor: Theme.of(context).primaryColor,
//                       child: CustomScrollView(slivers: [
//                         SliverToBoxAdapter(
//                             child: Center(
//                                 child: SizedBox(
//                           width: Dimensions.webScreenWidth,
//                           child: ListView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeDefault),
//                             itemCount: orderList.length,
//                             shrinkWrap: true,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(
//                                     bottom: Dimensions.paddingSizeSmall),
//                                 child: OrderItemWidget(
//                                     orderList: orderList, index: index),
//                               );
//                             },
//                           ),
//                         ))),
//                         const FooterWebWidget(footerType: FooterType.sliver),
//                       ]),
//                     )
//                   : NoDataWidget(
//                       image: Images.emptyOrderImage,
//                       title: getTranslated('no_order_history', context),
//                       subTitle: getTranslated('buy_something_to_see', context),
//                       isShowButton: true,
//                     )
//               : Center(
//                   child: CustomLoaderWidget(
//                       color: Theme.of(context).primaryColor));
//         },
//       ),
//     );
//   }
// }
