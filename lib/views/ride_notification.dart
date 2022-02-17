// import 'dart:math';

// import 'package:circular_profile_avatar/circular_profile_avatar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:slide_to_act/slide_to_act.dart';

// class RideReq extends StatefulWidget {
//   final dynamic userData;
//   const RideReq({Key? key, required this.userData}) : super(key: key);

//   @override
//   _RideReqState createState() => _RideReqState(userData: userData);
// }

// class _RideReqState extends State<RideReq> {
//   final dynamic userData;
//   _RideReqState({required this.userData});
//   Stream timer_stream = Stream.periodic(Duration(seconds: 1), (time) {
//     print("time $time");
//     return time;
//   });
//   @override
//   Widget build(BuildContext context) {
//     print((MediaQuery.of(context).size.height * 0.5).toString());

//     return Scaffold(
//       body: StreamBuilder(
//           initialData: 0,
//           stream: timer_stream,
//           builder: (builder, ctx) {
//             return Container(
//               child: Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(5),
//                 width: MediaQuery.of(context).size.width * 0.75,
//                 height: min(
//                   350,
//                   MediaQuery.of(context).size.height * 0.5,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     LinearProgressIndicator(
//                       value: (0.5),
//                       backgroundColor: Colors.grey.shade400,
//                       valueColor: AlwaysStoppedAnimation(Colors.grey.shade700),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         CircularProfileAvatar(
//                           userData["image"],
//                           imageFit: BoxFit.cover,
//                           radius: 45,
//                           cacheImage: true,
//                           initialsText: Text("Ankit"),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Ankit Gautam",
//                               style: TextStyle(
//                                   color: Colors.grey.shade800,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             Text(
//                               "35 Km | 25 Min",
//                               style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w300),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     Text(
//                       "Pickup",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade800),
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Text(
//                         "Description that is too long in text format(Here Data is coming from API) jdlksaf j klkjjflkdsjfkddfdfsdfds",
//                         style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey.shade600),
//                       ),
//                     ),
//                     Text(
//                       "Destination",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade800),
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Text(
//                         "Description that is too long in text format(Here Data is coming from API) jdlksaf j klkjjflkdsjfkddfdfsdfds",
//                         style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey.shade600),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4,
//                     ),
//                     SlideAction(
//                       text: "Slide to accept",
//                       textStyle: TextStyle(color: Colors.grey.shade400),
//                       sliderButtonIconPadding: 9,
//                       height: 40,
//                       sliderButtonIconSize: 20,
//                       sliderButtonIcon: Icon(
//                         Iconsax.arrow_right_1,
//                         size: 15,
//                         color: Colors.white,
//                       ),
//                       onSubmit: () {
//                         Future.delayed(
//                           Duration(seconds: 1),
//                         );
//                       },
//                       innerColor: Colors.green.shade700,
//                       outerColor: Colors.white,
//                     ),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     SlideAction(
//                       submittedIcon: Icon(
//                         Iconsax.close_circle4,
//                         size: 15,
//                         color: Colors.red.shade700,
//                       ),
//                       text: "Slide to cancel",
//                       textStyle: TextStyle(color: Colors.grey.shade400),
//                       sliderButtonIconPadding: 9,
//                       height: 40,
//                       sliderButtonIconSize: 20,
//                       reversed: true,
//                       sliderButtonIcon: Icon(
//                         Iconsax.close_circle4,
//                         size: 15,
//                         color: Colors.white,
//                       ),
//                       onSubmit: () {
//                         Future.delayed(
//                           Duration(seconds: 1),
//                         );
//                       },
//                       innerColor: Colors.red.shade600,
//                       outerColor: Colors.white,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
