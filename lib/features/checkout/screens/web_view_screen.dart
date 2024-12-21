import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final Function(String orderId) onPaymentSuccess;
  final Function(String orderId) onPaymentFailed;

  const WebViewScreen({
    Key? key,
    required this.url,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String finishedUrl) {
            _extractPaymentStatus();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _extractPaymentStatus() async {
    try {
      // Extract page content using JavaScript
      final String pageContent = await _controller.runJavaScriptReturningResult(
        "document.body.innerText",
      ) as String;

      // Remove outer quotes and unescape JSON string
      final String unescapedContent =
          pageContent.replaceAll(r'\"', '"').replaceAll(RegExp(r'^"|"$'), '');

      // Parse JSON from the unescaped string
      final Map<String, dynamic> response = jsonDecode(unescapedContent);
      final String orderId = response['order_id'] ?? '';
      // Check payment status and navigate accordingly
      if (response['payment_status'] == 'Success') {
        widget.onPaymentSuccess(orderId); // Navigate to success screen
      } else if (response['payment_status'] == 'Failed') {
        widget.onPaymentFailed(orderId); // Navigate to failed screen
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show the cancel payment dialog when the back button is pressed
        _showCancelPaymentDialog(context);
        return false; // Prevent automatic navigation back
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment Gateway"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _showCancelPaymentDialog(context);
            },
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }

  void _showCancelPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Adjusts the size of the column to fit its content
            children: [
              // Image at the top
              Image.asset(
                'assets/image/card-payment-cancel.png',
                width: MediaQuery.of(context).size.width *
                    0.29, // Adjust width using MediaQuery
                height: MediaQuery.of(context).size.width *
                    0.29, // Adjust height proportionally
                fit: BoxFit
                    .contain, // Ensures the image is contained within the given size
              ),
              const SizedBox(height: 10), // Spacing between image and text
              // Text below the image
              Text(
                "Do you really want to cancel your payment?",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // Center align the text
              ),
            ],
          ),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Yes button with increased width
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context)
                          .pop(); // Go back to the previous page
                      _showPaymentFailedBottomSheet(
                          context); // Show BottomSheet
                    },
                    child: const Text("Yes"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Button background color
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // No button with increased width
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("No"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 241, 239, 239),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPaymentFailedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Oops, Payment Failed",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the BottomSheet
                  // You can add code here to retry the payment or reload WebView
                  _retryPayment(); // Example of retrying payment
                },
                child: const Text(
                  "Try Again",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50), // Button width
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle retrying payment, like reloading WebView
  void _retryPayment() {
    // You can implement reloading the WebView or any retry mechanism
    _controller.loadRequest(Uri.parse(widget.url)); // Reload the payment page
  }
}
// class WebViewScreen extends StatefulWidget {
//   final String url;
//   final Function(String orderId) onPaymentSuccess;
//   final Function(String orderId) onPaymentFailed;
//   // final VoidCallback onPaymentSuccess;
//   // final VoidCallback onPaymentFailed;

//   const WebViewScreen({
//     Key? key,
//     required this.url,
//     required this.onPaymentSuccess,
//     required this.onPaymentFailed,
//   }) : super(key: key);

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String finishedUrl) {
//             _extractPaymentStatus();
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   Future<void> _extractPaymentStatus() async {
//     try {
//       // Extract page content using JavaScript
//       final String pageContent = await _controller.runJavaScriptReturningResult(
//         "document.body.innerText",
//       ) as String;

//       // Remove outer quotes and unescape JSON string
//       final String unescapedContent =
//           pageContent.replaceAll(r'\"', '"').replaceAll(RegExp(r'^"|"$'), '');

//       // Parse JSON from the unescaped string
//       final Map<String, dynamic> response = jsonDecode(unescapedContent);
//       final String orderId = response['order_id'] ?? '';
//       // Check payment status and navigate accordingly
//       if (response['payment_status'] == 'Success') {
//         widget.onPaymentSuccess(orderId); // Navigate to success screen
//       } else if (response['payment_status'] == 'Failed') {
//         widget.onPaymentFailed(orderId); // Navigate to failed screen
//       }
//     } catch (e) {
//       print('Error parsing JSON: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Gateway"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             _showCancelPaymentDialog(context);
//           },
//         ),
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//     // return Scaffold(
//     //   appBar: AppBar(
//     //     title: const Text("Payment Gateway"),
//     //   ),
//     //   body: WebViewWidget(controller: _controller),
//     // );
//   }

//   void _showCancelPaymentDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           // title: const Text("Cancel Payment"),
//           content: Text(
//             "Do you really want to cancel your payment?",
//             style: TextStyle(
//               fontSize: MediaQuery.of(context).size.width * 0.05,
//               color: Colors.black,
//             ),
//           ),
//           actions: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Yes button with increased width
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width *
//                       0.7, // Adjust the width as needed
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the dialog
//                       Navigator.of(context)
//                           .pop(); // Go back to the previous page
//                     },
//                     child: const Text("Yes"),
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.green, // Text color white
//                       minimumSize: Size(
//                           double.infinity, 40), // Increase height if needed
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                     height: 10), // Add some space between the buttons
//                 // No button with increased width
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width *
//                       0.7, // Adjust the width as needed
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the dialog
//                     },
//                     child: const Text("No"),
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.black,
//                       backgroundColor: Color.fromARGB(
//                           255, 241, 239, 239), // Text color white
//                       minimumSize: Size(
//                           double.infinity, 40), // Increase height if needed
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// void _showCancelPaymentDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Cancel Payment"),
//         content: Text("Do you really want to cancel your payment?",
//             style: poppinsMedium.copyWith(
//                 fontSize: MediaQuery.of(context).size.width * 0.05,
//                 color: Colors.black)),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text("No"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//               Navigator.of(context).pop(); // Go back to the previous page
//             },
//             child: const Text("Yes"),
//           ),
//         ],
//       );
//     },
//   );
// }
//}

// class WebViewScreen extends StatefulWidget {
//   final String url;
//   final VoidCallback onPaymentSuccess;
//   final VoidCallback onPaymentFailed;

//   const WebViewScreen({
//     Key? key,
//     required this.url,
//     required this.onPaymentSuccess,
//     required this.onPaymentFailed,
//   }) : super(key: key);

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize WebViewController
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String finishedUrl) {
//             // Run JavaScript to extract the response content
//             _extractPaymentStatus();
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   Future<void> _extractPaymentStatus() async {
//     try {
//       // Extract page content using JavaScript
//       final String pageContent = await _controller.runJavaScriptReturningResult(
//         "document.body.innerText",
//       ) as String;

//       // Log the content for debugging
//       print("Page content: $pageContent");

//       // Attempt to parse the string as JSON
//       final Map<String, dynamic> response = jsonDecode(pageContent);

//       // Check for the `Payment_status` field and redirect
//       if (response['Payment_status'] == 'Success') {
//         widget.onPaymentSuccess(); // Navigate to success screen
//       } else if (response['Payment_status'] == 'Failed') {
//         widget.onPaymentFailed(); // Navigate to failed screen
//       }
//     } catch (e) {
//       print('Error parsing JSON: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Gateway"),
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }

// class WebViewScreen extends StatefulWidget {
//   final String url;
//   final VoidCallback onPaymentCompleted;

//   const WebViewScreen({
//     Key? key,
//     required this.url,
//     required this.onPaymentCompleted,
//   }) : super(key: key);

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize WebViewController
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String finishedUrl) {
//             // Check for payment success based on the URL or page content
//             if (finishedUrl.contains('success')) {
//               widget.onPaymentCompleted(); // Call completion callback
//             }
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.contains('cancel')) {
//               // Handle cancel scenarios
//               Navigator.pop(context);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url)); // Load the URL
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Gateway"),
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
// class WebViewScreen extends StatelessWidget {
//   final String url;
//   final VoidCallback onPaymentCompleted;

//   WebViewScreen({required this.url, required this.onPaymentCompleted});

//   @override
//   Widget build(BuildContext context) {
//     // Create a WebViewController
//     final WebViewController controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String finishedUrl) {
//             // Check for payment success based on the URL or page content
//             if (finishedUrl.contains('success')) {
//               onPaymentCompleted(); // Call completion callback
//             }
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.contains('cancel')) {
//               // Handle cancel scenarios
//               Navigator.pop(context);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(url)); // Load the URL

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Payment Gateway"),
//       ),
//       body: WebViewWidget(controller: controller),
//     );
//   }
// }
