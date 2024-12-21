// Define the RatingProvider class
import 'package:flutter_grocery/features/order/domain/reposotories/rating_repo.dart';

import 'package:flutter/material.dart';

class RatingProvider with ChangeNotifier {
  // A method to submit the review through ratingService
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
