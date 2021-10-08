import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:driver/Data/accountProvider.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Maps.dart';
import 'package:driver/views/Signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// ignore: must_be_immutable
class SignIn extends StatefulWidget {
  FirebaseApp app;
  SignIn({required this.app});
  @override
  _SignInState createState() => _SignInState(app: app);
}

class _SignInState extends State<SignIn> {
  FirebaseApp app;
  String? username, email, ph, image = "";
  _SignInState({required this.app});
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<dynamic, dynamic>? result;
  bool _obscure = true;
  bool isloading = false;
  Future loginwithemail() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        setState(() {
          isloading = true;
        });
        try {
          await _auth.signInWithEmailAndPassword(
              email: _email.text, password: _pass.text);

          User? user = _auth.currentUser;
          var uid = user!.uid;
          print("Uid :$uid");

          final DatabaseReference db = FirebaseDatabase(app: app).reference();

          await db.child('Drivers').child(uid).get().then(
                (DataSnapshot? datasnapshot) => print(
                  result = datasnapshot!.value,
                ),
              );
          print("here");
          username = result!['Username'];
          email = result!['Email'];
          ph = result!['Phone'];
          image = result!['Image'];
          print("data:-$username ,$email,$image,$ph");

          UserAccount userAccount = UserAccount(
              Email: email!,
              Image: image!,
              Ph: ph!,
              Uid: uid,
              Username: username!);

          Provider.of<AccountProvider>(context, listen: false)
              .updateuseraccount(userAccount);
          bool cache_image = await File(image!).exists();
          print("cache_image:$cache_image");
          if (cache_image) {
            Provider.of<ImageData>(context, listen: false)
                .updateimage(File(image!));
          } else {
            firebase_storage.Reference ref = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child('Driver_Details')
                .child('/${user.uid}/${user.uid}');
            String url = await ref.getDownloadURL();
            print("url:->$url");
            Dio newimage = Dio();
            String savePath =
                Directory.systemTemp.path + '/' + user.uid + "_profile";
            await newimage.download(url, savePath,
                options: Options(responseType: ResponseType.bytes));
            db.child('Users').child(user.uid).update({"Image": savePath});
            Provider.of<ImageData>(context, listen: false)
                .updateimage(File(savePath));
            image = savePath;
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("Uid", user.uid);
          prefs.setString("Username", username!);
          prefs.setString("Email", email!);
          prefs.setString("Ph", ph!);
          prefs.setString("Image", image!);
          Get.offAll(Maps(app: app));
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            Get.snackbar("Sign In", "Error Occured usernot found",
                snackPosition: SnackPosition.BOTTOM);
          } else if (e.code == 'wrong-password') {
            Get.snackbar("Sign In", "Error Occured invalid password",
                snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          Get.snackbar("Sign In",
              "Your account has not been varified pls wait or contact us on Travelrtreathelp@gmail.com",
              duration: Duration(seconds: 10));
          _auth.signOut();
        }

        // print(user);
        //
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("Uid", user!.uid);

      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Get.snackbar("Sign In", "Error Occured  or his not been verified $e",
              snackPosition: SnackPosition.BOTTOM);
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Sign In", "Error Occured $e ",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar("Sign In", "Error Occured $e");
      }
      setState(() {
        isloading = false;
      });
    } else {
      print("Not valid");
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              Image.asset(
                'asset/images/taxi_app.jpg',
                width: 360,
              ),
              SizedBox(
                height: 28,
              ),
              Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 320,
                      child: TextFormField(
                        controller: _email,
                        validator: (val) => val!.contains('@gmail.com')
                            ? null
                            : "Enter valide email",
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.black87),
                          contentPadding: EdgeInsets.all(20),
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: .6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //input password
                    Container(
                      width: 320,
                      child: TextFormField(
                        obscureText: _obscure,
                        controller: _pass,
                        validator: (val) => val!.length > 6
                            ? null
                            : "password should be at least 6 charcter",
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: FaIcon(
                              _obscure
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                          prefixIcon:
                              Icon(Icons.password, color: Colors.black87),
                          contentPadding: EdgeInsets.all(20),
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: .6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onPressed: () async {
                  await loginwithemail();
                },
                child: Text(
                  ' Sign In ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
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
                      Get.off(SignUp(app: app));
                    },
                    child: Text(
                      ' Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              isloading ? CircularProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
