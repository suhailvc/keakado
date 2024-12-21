import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/onboarding/domain/models/onboarding_model.dart';

class OnBoardingWidget extends StatelessWidget {
  final OnBoardingModel onBoardingModel;
  final String imageUrl;
  const OnBoardingWidget(
      {Key? key, required this.onBoardingModel, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(
        children: [
          Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ],
      )
      // Expanded(
      //     flex: 10,
      //     child: Padding(
      //       padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      //       child: Image.asset(imageUrl),
      //     )),
      // Expanded(
      //   flex: 1,
      //   child: Text(
      //     onBoardingModel.title,
      //     style: poppinsMedium.copyWith(
      //       fontSize: Dimensions.fontSizeLarge,
      //       color: Theme.of(context).primaryColor,
      //     ),
      //     textAlign: TextAlign.center,
      //   ),
      // ),
      // Expanded(
      //   flex: 2,
      //   child: Text(
      //     onBoardingModel.description,
      //     style: poppinsLight.copyWith(
      //       fontSize: Dimensions.fontSizeLarge,
      //     ),
      //     textAlign: TextAlign.center,
      //   ),
      // )
    ]);
  }
}
