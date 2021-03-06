// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:driver/Data/accountProvider.dart';
// import 'package:driver/Data/image.dart';
// import 'package:driver/Data/userData.dart';
// import 'package:driver/models/userAccount.dart';
// import 'package:driver/views/Maps.dart';
// import 'package:driver/views/Signup.dart';
// import 'package:driver/views/Welcome.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Dashboard extends StatefulWidget {
//   final FirebaseApp app;
//   Dashboard({required this.app});
//   @override
//   _DashboardState createState() => _DashboardState(app: app);
// }

// class _DashboardState extends State<Dashboard> {
//   final FirebaseApp app;
//   final geo = Geoflutterfire();
//   final _firestore = FirebaseFirestore.instance;

//   _DashboardState({required this.app});
//   int selectedindex = 0;
//   PageController _pagecontroller = PageController();
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   void _onpagechanged(int index) {
//     setState(() {
//       selectedindex = index;
//     });
//   }

//   void _onnavigationmenu(int selectedindex) {
//     _pagecontroller.jumpToPage(selectedindex);
//   }

//   void logoutgoogleuser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('Username');
//     await prefs.remove('Email');
//     await prefs.remove('Ph');
//     await prefs.remove('Uid');
//     await prefs.remove('Image');
//     await prefs.remove('emph');
//     await FirebaseAuth.instance.signOut();
//     if (Provider.of<ImageData>(context, listen: false).image != null) {
//       Provider.of<ImageData>(context, listen: false).updateimage(null);
//     }
//     UserAccount userAccount = UserAccount(
//       Email: "",
//       Image: "",
//       Ph: "",
//       Uid: "",
//       Username: "",
//     );
//     Provider.of<AccountProvider>(context, listen: false)
//         .updateuseraccount(userAccount);
//     Provider.of<UserData>(context, listen: false).updatepickuplocation(null);
//     Get.off(
//       Welcome(app: app),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Dashboard");
//     print("geo:$geo");
//     print("_firestore:$_firestore");
//     return SafeArea(
//         child: Scaffold(
//       key: _scaffoldKey,
//       body: PageView(
//         controller: _pagecontroller,
//         children: [
//           Stack(
//             children: [
//               Maps(app: app),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15, left: 20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Color.fromRGBO(255, 255, 255, .7),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     tooltip: "Menu",
//                     onPressed: () {
//                       _scaffoldKey.currentState!.openDrawer();
//                     },
//                     icon: Icon(Icons.menu),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Welcome(app: app),
//           SignUp(app: app),
//         ],
//         onPageChanged: _onpagechanged,
//         physics: NeverScrollableScrollPhysics(),
//       ),
//       drawer: Drawer(
//         elevation: 1,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               profile(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         elevation: 0.2,
//         iconSize: 18,
//         backgroundColor: Color.fromRGBO(30, 30, 30, 1),
//         currentIndex: selectedindex,
//         type: BottomNavigationBarType.fixed,
//         selectedFontSize: 12,
//         items: [
//           BottomNavigationBarItem(
//               tooltip: 'Booking',
//               icon: Icon(CupertinoIcons.location_solid,
//                   color: selectedindex == 0 ? Colors.blue : Colors.white60),
//               title: Text('Maps',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color:
//                           selectedindex == 0 ? Colors.blue : Colors.white60))),
//           BottomNavigationBarItem(
//             tooltip: 'Create a plan',
//             icon: Icon(
//                 selectedindex == 1
//                     ? CupertinoIcons.news_solid
//                     : CupertinoIcons.news,
//                 color: selectedindex == 1 ? Colors.blue : Colors.white60),
//             title: Text(
//               'Plan',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: selectedindex == 1 ? Colors.blue : Colors.white60,
//               ),
//             ),
//           ),
//           BottomNavigationBarItem(
//               tooltip: 'User account',
//               icon: Container(
//                 padding: EdgeInsets.only(top: 6),
//                 child: CircleAvatar(
//                   radius: 15,
//                   backgroundImage: FileImage(File(
//                       Provider.of<AccountProvider>(context, listen: false)
//                           .userAccount
//                           .Image!)),
//                 ),
//               ),
//               title: Text('',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color:
//                           selectedindex == 2 ? Colors.blue : Colors.white60)))
//         ],
//         onTap: _onnavigationmenu,
//       ),
//     ));
//   }

//   Widget profile() {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             color: Color.fromRGBO(30, 30, 30, 1),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Center(
//                   child: Provider.of<ImageData>(context, listen: false).image ==
//                           null
//                       ? CircleAvatar(
//                           backgroundColor: Colors.black26,
//                           radius: 55,
//                           backgroundImage: FileImage(File(
//                               Provider.of<AccountProvider>(context,
//                                       listen: false)
//                                   .userAccount
//                                   .Image!)),
//                         )
//                       : CircleAvatar(
//                           backgroundColor: Colors.black26,
//                           radius: 55,
//                           backgroundImage: FileImage(
//                               Provider.of<ImageData>(context, listen: false)
//                                   .image!),
//                         ),
//                 ),
//                 SizedBox(
//                   height: 35,
//                 ),
//                 Text(
//                   Provider.of<AccountProvider>(context, listen: false)
//                       .userAccount
//                       .Username
//                       .capitalize!
//                       .toString(),
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   Provider.of<AccountProvider>(context, listen: false)
//                       .userAccount
//                       .Email,
//                   style: TextStyle(fontSize: 13, color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.home_rounded,
//             ),
//             title: Text('Home'),
//             selected: true,
//             onTap: () {
//               print("Home visited");
//             },
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.account_box,
//             ),
//             title: Text('Account'),
//             selected: false,
//             onTap: () {
//               print("accont visited");
//             },
//           ),
//           ListTile(
//             leading: FaIcon(FontAwesomeIcons.car),
//             title: Text('My trips'),
//             selected: false,
//             onTap: () {
//               print("Trip visited");
//             },
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.settings,
//             ),
//             title: Text('Settings'),
//             selected: false,
//             onTap: () {
//               print("settings visited");
//             },
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.logout_rounded,
//             ),
//             title: Text('Log Out'),
//             selected: false,
//             onTap: () {
//               logoutgoogleuser();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
