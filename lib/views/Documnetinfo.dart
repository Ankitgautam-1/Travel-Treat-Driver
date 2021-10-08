import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Documentinfo extends StatefulWidget {
  const Documentinfo({Key? key}) : super(key: key);

  @override
  _DocumentinfoState createState() => _DocumentinfoState();
}

class _DocumentinfoState extends State<Documentinfo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "Documnet Needed",
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "1.Driver's License.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "2.Registration Certificate.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "3.Vehicle Insurance.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "4.Contract Carriage Permit..",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "5.Tourist Taxi Permit.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 34,
                ),
                Text(
                    "Note : The Documnet name should relevanet example for Driver's license the file name should be Driver_license.pdf \n\nYou will get respond with in 2 weeks via mail for more info conntact us on Traveltreathelp@gmail.com"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
