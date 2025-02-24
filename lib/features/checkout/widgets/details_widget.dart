import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/checkout/widgets/amount_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/image_note_upload_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_section_widget.dart';
import 'package:provider/provider.dart';

import 'partial_pay_widget.dart';

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({
    Key? key,
    required this.paymentList,
    required this.noteController,
  }) : super(key: key);

  final List<PaymentMethod> paymentList;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    CheckOutModel? checkOutData =
        Provider.of<OrderProvider>(context, listen: false).getCheckOutData;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (Provider.of<OrderProvider>(context, listen: false).selectTimeSlot !=
          -1) ...[
        const PaymentSectionWidget(),
        PartialPayWidget(
            totalPrice:
                checkOutData!.amount! + (checkOutData.deliveryCharge ?? 0)),
      ],
      // const PaymentSectionWidget(),
      // PartialPayWidget(
      //     totalPrice:
      //         checkOutData!.amount! + (checkOutData.deliveryCharge ?? 0)),

      const ImageNoteUploadWidget(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            getTranslated('add_delivery_note', context),
            style: poppinsBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            fillColor: Colors.white,
            isShowBorder: true,
            controller: noteController,
            hintText: getTranslated('type', context),
            maxLines: 5,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ]),
      ),
      // Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       const SizedBox(height: 8),
      //       Text(
      //         getTranslated('cost_summery', context),
      //         style: poppinsSemiBold.copyWith(
      //           fontSize: Dimensions.fontSizeLarge,
      //         ),
      //       ),
      //       const SizedBox(height: 8),
      //       Container(
      //         padding: const EdgeInsets.all(16),
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(16),
      //           color: Colors.white,
      //         ),
      //         child: Column(
      //           children: [],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      if (!ResponsiveHelper.isDesktop(context)) const AmountWidget(),
    ]);
  }
}
