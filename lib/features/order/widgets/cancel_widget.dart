import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/rating_provider.dart';
import 'package:provider/provider.dart';

class ReturnScreen extends StatefulWidget {
  final int orderId;
  const ReturnScreen({required this.orderId, super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  String _errorMessage = '';
  // Variable to hold the error message
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(20.0), // Circular edges
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Do you want to cancel the order?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          //   SizedBox(height: 20),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(5, (index) {
          //       return GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             _selectedStars = index + 1;
          //             _errorMessage = ''; // Clear error message on new selection
          //           });
          //         },
          //         child: Image.asset(
          //           index < _selectedStars
          //               ? 'assets/image/selectedstar.png'
          //               : 'assets/image/unselectedstar.png',
          //           width: 40,
          //           height: 40,
          //         ),
          //       );
          //     }),
          //   ),
          SizedBox(height: 20),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Cancelation Reason...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                ),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_feedbackController.text.trim().isEmpty) {
                    setState(() {
                      _errorMessage =
                          'Please type the reason'; // Show error message
                    });
                  } else {
                    String feedback = _feedbackController.text;
                    // Process the rating and feedback
                    print('Feedback: $feedback');
                    Provider.of<RatingProvider>(context, listen: false)
                        .cancelOrder(
                            orderId: widget.orderId,
                            reason: feedback,
                            bearerToken: Provider.of<AuthProvider>(context,
                                    listen: false)
                                .getUserToken());
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => AlertDialog(
                    //     title: Text('Thank You!'),
                    //     content: Text('Your feedback has been submitted.'),
                    //     actions: [
                    //       TextButton(
                    //         onPressed: () => Navigator.pop(context),
                    //         child: Text('OK'),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).primaryColor, // Button color
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (_errorMessage
              .isNotEmpty) // Display the error message if it's not empty
            SizedBox(height: 10),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
