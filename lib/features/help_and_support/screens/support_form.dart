import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/help_and_support/domain/reposotories/form_api.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Contact"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fill out the form, and we’ll provide personalized advice for your nutrition goals.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Full Name"),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: "Enter your full name",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        const Text("Email Address (Optional)"),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: "Enter your email",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text('Phone Number'),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            hintText: "+974",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        const Text('Additional Message'),
                        TextFormField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: "Message...",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await ApiService().sendContactMessage(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  message: messageController.text.trim(),
                                );
                                nameController.clear();
                                emailController.clear();
                                phoneController.clear();
                                messageController.clear();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Send message",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  // final TextEditingController messageController = TextEditingController();
  // // String? token;

  // // @override
  // // void initState() {
  // //   super.initState();
  // //   _loadToken();
  // // }

  // // Future<void> _loadToken() async {
  // //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  // //   setState(() {
  // //     token = prefs.getString('token') ?? '';
  // //   });
  // // }

  // @override
  // void dispose() {
  //   // Dispose of the controllers when the widget is removed from the widget tree
  //   nameController.dispose();
  //   emailController.dispose();
  //   phoneController.dispose();
  //   messageController.dispose();
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final screenWidth = MediaQuery.of(context).size.width;

  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: const Text("Contact"),
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ),
  //     body: SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Container(
  //           color: Colors.white,
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 "Fill out the form, and we’ll provide personalized advice for your nutrition goals.",
  //                 style: TextStyle(fontSize: 16),
  //               ),
  //               const SizedBox(height: 20),
  //               Padding(
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text("Full Name"),
  //                     TextField(
  //                       controller: nameController,
  //                       decoration: const InputDecoration(
  //                         hintText: "Enter your full name",
  //                         border: OutlineInputBorder(),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 15),
  //                     const Text("Email Address (Optional)"),
  //                     TextField(
  //                       controller: emailController,
  //                       decoration: const InputDecoration(
  //                         hintText: "Enter your email",
  //                         border: OutlineInputBorder(),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 15),
  //                     const Text('Phone Number'),
  //                     TextField(
  //                       controller: phoneController,
  //                       decoration: const InputDecoration(
  //                         hintText: "+974",
  //                         border: OutlineInputBorder(),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                       ),
  //                       keyboardType: TextInputType.phone,
  //                     ),
  //                     const SizedBox(height: 15),
  //                     const Text('Additional Message'),
  //                     TextField(
  //                       controller: messageController,
  //                       decoration: const InputDecoration(
  //                         hintText: "Message...",
  //                         border: OutlineInputBorder(),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                       ),
  //                       maxLines: 3,
  //                     ),
  //                     const SizedBox(height: 20),
  //                     SizedBox(
  //                       width: double.infinity,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           // String? token =
  //                           //     await SharedPref!.getstring("'token'");
  //                           await ApiService().sendContactMessage(
  //                             name: nameController.text.trim(),
  //                             email: emailController.text.trim(),
  //                             phone: phoneController.text.trim(),
  //                             message: messageController.text.trim(),
  //                           );
  //                           nameController.clear();
  //                           emailController.clear();
  //                           phoneController.clear();
  //                           messageController.clear();
  //                           Navigator.pop(context);
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.green,
  //                           padding: const EdgeInsets.symmetric(vertical: 16),
  //                         ),
  //                         child: const Text(
  //                           "Send message",
  //                           style: TextStyle(color: Colors.white),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
// class ContactScreen extends StatelessWidget {
//   const ContactScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     var nameController = TextEditingController();
//     var emailController = TextEditingController();
//     var phoneController = TextEditingController();
//     var messageController = TextEditingController();

//     return Scaffold(
//       //  backgroundColor: Colors.green, // Set the scaffold background to green
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Contact"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             color: Colors.white, // Set form container background to white
//             padding:
//                 const EdgeInsets.all(16.0), // Add padding for inner content
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Fill out the form, and we’ll provide personalized advice for your nutrition goals.",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Full Name"),
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           hintText: "Enter your full name",
//                           border: OutlineInputBorder(),
//                           filled:
//                               true, // Ensure the TextField background stays white
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       const Text("Email Address (Optional)"),
//                       TextField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           hintText: "Enter your email",
//                           border: OutlineInputBorder(),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       const Text('Phone Number'),
//                       TextField(
//                         controller: phoneController,
//                         decoration: const InputDecoration(
//                           hintText: "+974",
//                           border: OutlineInputBorder(),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         keyboardType: TextInputType.phone,
//                       ),
//                       const SizedBox(height: 15),
//                       const Text('Additional Message'),
//                       TextField(
//                         controller: messageController,
//                         decoration: const InputDecoration(
//                           hintText: "Message...",
//                           border: OutlineInputBorder(),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         maxLines: 3,
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await ApiService().sendContactMessage(
//                               name: nameController.text.trim(),
//                               email: emailController.text.trim(),
//                               phone: phoneController.text.trim(),
//                               message: messageController.text.trim(),
//                             );
//                             // Alternatively, use Provider to call the API
//                             // Provider.of<ContactFormProvider>(context, listen: false).submitContactForm(
//                             //   name: nameController.text.trim(),
//                             //   email: emailController.text.trim(),
//                             //   phone: phoneController.text.trim(),
//                             //   message: messageController.text.trim(),
//                             // );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text(
//                             "Send message",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ContactScreen extends StatelessWidget {
//   const ContactScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     var nameController = TextEditingController();
//     var emailController = TextEditingController();
//     var phoneController = TextEditingController();
//     var messageController = TextEditingController();
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Contact"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             color: Colors.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Fill out the form, and we’ll provide personalized advice for your nutrition goals.",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Full Name"),
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           hintText: "Enter your full name",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       const Text("Email Address (Optional)"),
//                       TextField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           hintText: "Enter your email",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       const Text('Phone Number'),
//                       TextField(
//                         controller: phoneController,
//                         decoration: const InputDecoration(
//                           hintText: "+974",
//                           border: OutlineInputBorder(),
//                         ),
//                         keyboardType: TextInputType.phone,
//                       ),
//                       const SizedBox(height: 15),
//                       const Text('Additionally message'),
//                       TextField(
//                         controller: messageController,
//                         decoration: const InputDecoration(
//                           hintText: "Message...",
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 3,
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await ApiService().sendContactMessage(
//                               name: nameController.text.trim(),
//                               email: emailController.text.trim(),
//                               phone: phoneController.text.trim(),
//                               message: messageController.text.trim(),
//                             );
//                             // Provider.of<ContactFormProvider>(context,
//                             //         listen: false)
//                             //     .submitContactForm(
//                             //   name: nameController.text.trim(),
//                             //   email: emailController.text.trim(),
//                             //   phone: phoneController.text.trim(),
//                             //   message: messageController.text.trim(),
//                             // );
//                           },
//                           child: Text(
//                             "Send message",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
