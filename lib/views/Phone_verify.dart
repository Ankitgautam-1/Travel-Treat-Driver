import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver/Data/accountProvider.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Email_verify.dart';
import 'package:driver/views/Maps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class Prc extends StatefulWidget {
  FirebaseApp app;
  List<dynamic> data;
  Prc({required this.data, required this.app});
  @override
  _PrcState createState() => _PrcState(data: data, app: app);
}

class _PrcState extends State<Prc> {
  List<dynamic> data;
  FirebaseApp app;
  _PrcState({required this.data, required this.app});
  TextEditingController _1st = TextEditingController();
  TextEditingController _2nd = TextEditingController();
  TextEditingController _3rd = TextEditingController();
  TextEditingController _4th = TextEditingController();
  TextEditingController _5th = TextEditingController();
  TextEditingController _6th = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _otp = "";
  String verificationId = "";
  User? user;
  String _ph = "";
  @override
  void initState() {
    sendotp();
    super.initState();
  }

  Future sendotp() async {
    _ph = "+91" + data[2];
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _ph,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      timeout: const Duration(seconds: 100),
      verificationFailed: (FirebaseAuthException e) async {
        if (e.code == 'invalid-phone-number') {
          Get.snackbar("Phone Verfication", "Invalid phone number");
          print('The provided phone number is not valid.');
        } else if (e.code == "FirebaseTooManyRequestsException") {
          Get.snackbar("Phone Verfication", "SMS Services Error");
        }
        print(e);
      },
      codeSent: (verificationId, resendingToken) async {
        print("Otp is send ");
        Get.snackbar("", "",
            titleText: Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            messageText: Text(
              'A OTP Message is send to your Mobile number $_ph is verify it',
              style: TextStyle(
                fontSize: 11,
              ),
            ));
        this.verificationId = verificationId;
        print('$verificationId here it\'s');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    print(data[2]);
  }

  // ignore: non_constant_identifier_names
  Future<void> verify(String otp_code) async {
    try {
      print(' ver :$verificationId');
      PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp_code);
      print('Signed In');
      try {
        await auth.createUserWithEmailAndPassword(
            email: data[1], password: data[3]);
        user = auth.currentUser;
        user!.sendEmailVerification();

        Get.to(
          EmailVerify(data: data, app: app),
        );
      } catch (e) {
        Get.snackbar(
          "Phone verification",
          "Error occured $e",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error while Signin with phone ");
    }
  }

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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await auth.signOut();
              } catch (e) {}
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
              ),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Please don\'t share your OTP',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Image.asset(
                'asset/images/email_verification_bg.png',
                height: 300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _1st,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _2nd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _3rd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _4th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _5th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _6th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: () async {
                  _otp = _1st.text +
                      _2nd.text +
                      _3rd.text +
                      _4th.text +
                      _5th.text +
                      _6th.text;
                  print("Your otp is  $_otp");
                  await verify(_otp);
                },
                child: Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
