import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/rating_provider.dart';
import 'package:flutter_grocery/features/order/screens/order_details_screen.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:provider/provider.dart';

class RatingScreen extends StatefulWidget {
  final String orderId;

  const RatingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int selectedStars = 5;
  String feedback = '';
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('rate_your_order', context),
          isBackButtonExist: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                    },
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: getTranslated('share_your_feedback', context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
                onChanged: (value) {
                  feedback = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.navigator!.push(
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                              orderModel: null,
                              orderId: int.parse(widget.orderId)),
                        ),
                      );
                    },
                    child: Text(getTranslated('skip', context)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final String token =
                          Provider.of<AuthProvider>(context, listen: false)
                              .getUserToken();

                      Provider.of<RatingProvider>(context, listen: false)
                          .submitReview(
                        orderId: int.parse(widget.orderId),
                        rating: selectedStars,
                        comment: feedback,
                        bearerToken: token,
                      )
                          .then((_) {
                        showCustomSnackBarHelper(
                          getTranslated(
                              'review_submitted_successfully', context),
                          isError: false,
                        );
                        Get.navigator!.push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                                orderModel: null,
                                orderId: int.parse(widget.orderId)),
                          ),
                        );
                      }).catchError((error) {
                        showCustomSnackBarHelper(
                          getTranslated('review_submission_failed', context),
                          isError: true,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(getTranslated('submit', context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Then in your NotificationHelper, replace showDialog with navigation:
void handleRatingNavigation(String orderId) {
  Get.navigator!.push(
    MaterialPageRoute(
      builder: (context) => RatingScreen(orderId: orderId),
    ),
  );
}
