import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class SignOutDialogWidget extends StatelessWidget {
  const SignOutDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated('want_to_sign_out', context),
                  style: poppinsBold.copyWith(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                !auth.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                getTranslated('no', context),
                                style: poppinsMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              auth.signOut().then((value) {
                                if (context.mounted) {
                                  showCustomSnackBarHelper(
                                      getTranslated(
                                          'logout_successful', context),
                                      isError: false);

                                  if (ResponsiveHelper.isWeb()) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteHelper.getMainRoute(),
                                        (route) => false);
                                  } else {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteHelper.getLoginRoute(),
                                        (route) => false);
                                  }
                                }
                              });
                            },
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Text(getTranslated('yes', context),
                                  style: poppinsMedium.copyWith(
                                      color: Theme.of(context).primaryColor)),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: CustomLoaderWidget(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
