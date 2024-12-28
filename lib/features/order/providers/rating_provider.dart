// Define the RatingProvider class
import 'package:flutter_grocery/features/order/domain/reposotories/order_cancel_repo.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/rating_repo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';

class RatingProvider with ChangeNotifier {
  // A method to submit the review through ratingService
  Future<void> cancelOrder(
      {required int orderId,
      required String reason,
      required String bearerToken}) async {
    bool success = await orderCancelService(
      orderId: orderId,
      reason: reason,
      bearerToken: bearerToken,
    );

    if (success) {
      showCustomSnackBarHelper('Order Cancelled', isError: false);
      print('cancelled');
      notifyListeners();
    } else {
      showCustomSnackBarHelper('Cancellation Failed', isError: true);
      print('cancel error');
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required int orderId,
    required int rating,
    required String comment,
    required String bearerToken,
  }) async {
    try {
      // Call the ratingService method to submit the review
      await ratingService(
        orderId: orderId,
        rating: rating,
        comment: comment,
        bearerToken: bearerToken,
      );
      // Notify listeners if the review is successfully submitted
      notifyListeners();
    } catch (error) {
      // Handle errors
      print('Error submitting review: $error');
      // Optionally notify listeners about the error
      notifyListeners();
    }
  }
}
