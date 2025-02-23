import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/common/widgets/phone_number_field_widget.dart';
import 'package:flutter_grocery/features/address/widgets/add_address_widget.dart';
import 'package:provider/provider.dart';

class AddressDetailsWidget extends StatefulWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final FocusNode addressNode;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController florNumberController;
  final TextEditingController landMarkController;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode landMarkNode;
  final FocusNode florNode;
  final String countryCode;
  final Function(String value) onValueChange;

  const AddressDetailsWidget(
      {Key? key,
      required this.contactPersonNameController,
      required this.contactPersonNumberController,
      required this.addressNode,
      required this.nameNode,
      required this.numberNode,
      required this.isEnableUpdate,
      required this.fromCheckout,
      required this.address,
      required this.streetNumberController,
      required this.houseNumberController,
      required this.stateNode,
      required this.houseNode,
      required this.florNumberController,
      required this.florNode,
      required this.countryCode,
      required this.onValueChange,
      required this.landMarkController,
      required this.landMarkNode})
      : super(key: key);

  @override
  State<AddressDetailsWidget> createState() => _AddressDetailsWidgetState();
}

class _AddressDetailsWidgetState extends State<AddressDetailsWidget> {
  final TextEditingController locationTextController = TextEditingController();

  @override
  void dispose() {
    locationTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: ColorResources.cartShadowColor.withOpacity(0.2),
                  blurRadius: 10,
                )
              ],
            )
          : const BoxDecoration(),
      padding: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeLarge,
            )
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 24.0),
          //   child: Text(
          //     getTranslated('delivery_address', context),
          //     style:
          //     Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6), fontSize: Dimensions.fontSizeLarge),
          //   ),
          // ),

          const SizedBox(height: 16),
          // for Address Field
          labelWidget("address_line_01", widget.addressNode),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          CustomTextFieldWidget(
            fillColor: const Color(0xFFF5F5F5),
            hintText: getTranslated('address_line_02', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.next,
            focusNode: widget.addressNode,
            nextFocus: widget.stateNode,
            controller: locationTextController
              ..text = locationProvider.address ?? '',
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          labelWidget("street", widget.stateNode),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          CustomTextFieldWidget(
            fillColor: const Color(0xFFF5F5F5),
            hintText: getTranslated('ex_10_th', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.next,
            focusNode: widget.stateNode,
            nextFocus: widget.landMarkNode,
            controller: widget.streetNumberController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          labelWidget("Land Mark (Optional)", widget.stateNode),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          CustomTextFieldWidget(
            fillColor: const Color(0xFFF5F5F5),
            hintText: getTranslated('Land Mark', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.next,
            focusNode: widget.landMarkNode,
            nextFocus: widget.houseNode,
            controller: widget.landMarkController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(
            children: [
              labelWidget("Building No", widget.houseNode),
              SizedBox(width: MediaQuery.of(context).size.width * 0.28),
              labelWidget("Zone", widget.houseNode),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            children: [
              Expanded(
                child: CustomTextFieldWidget(
                  fillColor: const Color(0xFFF5F5F5),
                  hintText: getTranslated('ex_2', context),
                  isShowBorder: true,
                  inputType: TextInputType.streetAddress,
                  inputAction: TextInputAction.next,
                  focusNode: widget.houseNode,
                  nextFocus: widget.florNode,
                  controller: widget.houseNumberController,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(
                child: CustomTextFieldWidget(
                  fillColor: const Color(0xFFF5F5F5),
                  hintText: getTranslated('ex_2b', context),
                  isShowBorder: true,
                  inputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                  focusNode: widget.florNode,
                  nextFocus: widget.nameNode,
                  controller: widget.florNumberController,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Name

          labelWidget("contact_person_name", widget.nameNode),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          CustomTextFieldWidget(
            fillColor: const Color(0xFFF5F5F5),
            hintText: getTranslated('enter_contact_person_name', context),
            isShowBorder: true,
            inputType: TextInputType.name,
            controller: widget.contactPersonNameController,
            focusNode: widget.nameNode,
            nextFocus: widget.numberNode,
            inputAction: TextInputAction.next,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Number

          labelWidget("contact_person_number", widget.numberNode),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          PhoneNumberFieldWidget(
            onValueChange: widget.onValueChange,
            countryCode: widget.countryCode,
            phoneNumberTextController: widget.contactPersonNumberController,
            phoneFocusNode: widget.numberNode,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if (ResponsiveHelper.isDesktop(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: AddAddressWidget(
                landMrkController: widget.landMarkController,
                isEnableUpdate: widget.isEnableUpdate,
                fromCheckout: widget.fromCheckout,
                contactPersonNumberController:
                    widget.contactPersonNumberController,
                contactPersonNameController: widget.contactPersonNameController,
                address: widget.address,
                streetNumberController: widget.streetNumberController,
                houseNumberController: widget.houseNumberController,
                floorNumberController: widget.florNumberController,
                countryCode: widget.countryCode,
              ),
            )
        ],
      ),
    );
  }

  StatefulBuilder labelWidget(String label, FocusNode node) {
    return StatefulBuilder(builder: (context, setState) {
      node.addListener(
        () {
          setState(() {});
        },
      );
      return Text(
        getTranslated(label, context),
        style: poppinsMedium.copyWith(
          color: node.hasFocus
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.9),
        ),
      );
    });
  }
}
