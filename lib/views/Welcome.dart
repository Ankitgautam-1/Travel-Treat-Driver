import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:driver/Data/accountProvider.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Maps.dart';
import 'package:driver/views/Signin.dart';
import 'package:driver/views/Signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Welcome extends StatefulWidget {
  FirebaseApp app;
  Welcome({required this.app});
  @override
  _WelcomeState createState() => _WelcomeState(app: app);
}

class _WelcomeState extends State<Welcome> {
  bool isloading = false;
  FirebaseApp app;
  UserCredential? userCredential;
  User? user;
  var result;
  _WelcomeState({required this.app});
  String? username;
  String? email;
  String? image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 160),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 150),
                child: Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 150),
                child: Text(
                  'Travel Treat',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Image.asset(
                'asset/images/register_bg.jpg',
                width: 360,
              ),
              SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                  primary: Colors.black87,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onPressed: () {
                  Get.to(SignIn(app: app));
                },
                child: Text(
                  ' Sign In ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      height: 25,
                    ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an Account ?',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(SignUp(app: app));
                    },
                    child: Text(
                      ' Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
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
