import 'dart:io';
import 'package:driver/Data/files.dart';
import 'package:driver/views/Documnetinfo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/views/Phone_verify.dart';
import 'package:driver/views/Signin.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  FirebaseApp app;
  SignUp({required this.app});
  @override
  _SignUpState createState() => _SignUpState(app: app);
}

class _SignUpState extends State<SignUp> {
  FirebaseApp app;
  _SignUpState({required this.app});
  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _ph = TextEditingController();
  TextEditingController _pass = TextEditingController();
  User? user;
  late List<String> _data;
  final _formkey = GlobalKey<FormState>();
  var _image;
  var _cabimage;

  FilePickerResult? documentspicker;
  List<File>? documents;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool image = false;
  bool cab_image = false;
  bool isobscure = true;
  bool isfiles = false;
  final picker = ImagePicker();
  void _create() async {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState!.validate()) {
      if (Provider.of<Files>(context, listen: false).file5 != null) {
        if (image) {
          Provider.of<ImageData>(context, listen: false)
              .updateimage(_image, _cabimage);
          print("Heree---------------------------------------------------");
          print(_image.toString());
          print("DONE================================================");
          _data = [
            _username.text,
            _email.text,
            _ph.text,
            _pass.text,
            _image.toString(),
          ];
          Get.to(
            Prc(data: _data, app: app), //phone  verify
          );
          print(_data);
        } else if (cab_image != true) {
          Get.snackbar("Account Creation", "cab image is not selected ",
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar("Account Creation", "profile is not selected ",
              snackPosition: SnackPosition.BOTTOM);
        }
        print("Files are ok");
      } else {
        Get.snackbar(
            "Account creation", "pls upload all documents or check more info",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void deleteprofile() {
    setState(() {
      image = false;
      _image = Image.asset('asset/images/profile.jpg');
    });
  }

  void deletecabimage() {
    setState(() {
      cab_image = false;
      _cabimage = Image.asset('asset/images/register_bg.jpg');
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        File _im = File(pickedFile.path);
        _image = _im;
        image = true;
        print("image-->$_image");
      } else {
        print('No image selected.');
      }
    });
  }

  Future getcabImage() async {
    final pickedFile_cab = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile_cab != null) {
        File givencabImage = File(pickedFile_cab.path);
        _cabimage = givencabImage;
        cab_image = true;
      } else {
        print('No image selected.');
      }
    });
  }

  Future getCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(
      () {
        if (pickedFile != null) {
          File _im = File(pickedFile.path);
          _image = _im;
          image = true;
          print(" image ${_image.toString().trim()}");
        } else {
          print('No image selected.');
        }
      },
    );
  }

  Future getCameraforcab() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(
      () {
        if (pickedFile != null) {
          File _im = File(pickedFile.path);
          _cabimage = _im;
          cab_image = true;
          print("cab car image ${_cabimage.toString().trim()}");
        } else {
          print('No image selected.');
        }
      },
    );
  }

  Widget get() {
    return Container(
      color: Colors.white,
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Choose your profile picture",
            style: GoogleFonts.openSans(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getImage,
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getCamera,
                child: Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: deleteprofile,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getcabImageModel() {
    return Container(
      color: Colors.white,
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Choose your cab image",
            style: GoogleFonts.openSans(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getcabImage,
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getCameraforcab,
                child: Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: deletecabimage,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style:
                        GoogleFonts.roboto(fontSize: 30, color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 115,
                            width: 140,
                            child: Stack(
                              clipBehavior: Clip.antiAlias,
                              fit: StackFit.expand,
                              children: [
                                !image
                                    ? CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'asset/images/profile.jpg'),
                                        backgroundColor: Colors.grey[200],
                                      )
                                    : CircleAvatar(
                                        child: ClipOval(
                                          child: SizedBox(
                                            width: 115,
                                            height: 140,
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    height: 46,
                                    width: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(0),
                                        primary: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.bottomSheet(get());
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 115,
                            width: 140,
                            child: Stack(
                              clipBehavior: Clip.antiAlias,
                              fit: StackFit.expand,
                              children: [
                                !cab_image
                                    ? CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'asset/images/register_bg.jpg'),
                                        backgroundColor: Colors.grey[200],
                                      )
                                    : CircleAvatar(
                                        child: ClipOval(
                                          child: SizedBox(
                                            width: 115,
                                            height: 140,
                                            child: Image.file(
                                              _cabimage,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    height: 46,
                                    width: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(0),
                                        primary: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.bottomSheet(getcabImageModel());
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Container(
                          width: 320,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: _username,
                             style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            validator: (val) => val!.length > 5
                                ? null
                                : "Username should be at least 6 charcter",
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black87),
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Username",
                              hintStyle: GoogleFonts.openSans(
                                  fontSize: 15, color: Colors.black54),
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
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Container(
                          width: 320,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: _email,
                             style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            validator: (val) =>
                                val!.isEmail ? null : "Enter valide email",
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.black87),
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Email",
                              hintStyle: GoogleFonts.openSans(
                                  fontSize: 15, color: Colors.black54),
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
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Container(
                          width: 320,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: _ph,
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            validator: (val) => val!.length == 10
                                ? null
                                : "Phone Number should be 10 digits",
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_android_rounded,
                                  color: Colors.black87),
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Phone number",
                              hintStyle: GoogleFonts.openSans(
                                  fontSize: 15, color: Colors.black54),
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
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Container(
                          width: 320,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            obscureText: isobscure,
                            controller: _pass,
                             style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            validator: (val) => val!.length > 5
                                ? null
                                : "password should be at least 6 charcter",
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: FaIcon(
                                  isobscure
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isobscure = !isobscure;
                                  });
                                },
                              ),
                              prefixIcon:
                                  Icon(Icons.password, color: Colors.black87),
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Password",
                              hintStyle: GoogleFonts.openSans(
                                  fontSize: 15, color: Colors.black54),
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
                        isfiles
                            ? Container(
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file1 !=
                                              null
                                          ? Icon(Icons.file_download_done)
                                          : Icon(Icons.error),
                                      title: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file1 !=
                                              null
                                          ? Text(Provider.of<Files>(context,
                                                  listen: false)
                                              .file1
                                              .toString()
                                              .split("/")
                                              .last,style: GoogleFonts.openSans(),)
                                          : Text('File not found',style: GoogleFonts.openSans(),),
                                    ),
                                    ListTile(
                                      leading: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file2 !=
                                              null
                                          ? Icon(Icons.file_download_done)
                                          : Icon(Icons.error),
                                      title: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file2 !=
                                              null
                                          ? Text(Provider.of<Files>(context,
                                                  listen: false)
                                              .file2
                                              .toString()
                                              .split("/")
                                              .last,style: GoogleFonts.openSans())
                                          : Text('File not found',style: GoogleFonts.openSans(),),
                                    ),
                                    ListTile(
                                      leading: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file3 !=
                                              null
                                          ? Icon(Icons.file_download_done)
                                          : Icon(Icons.error),
                                      title: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file3 !=
                                              null
                                          ? Text(Provider.of<Files>(context,
                                                  listen: false)
                                              .file3
                                              .toString()
                                              .split("/")
                                              .last,style: GoogleFonts.openSans())
                                          : Text('File not found',style: GoogleFonts.openSans(),),
                                    ),
                                    ListTile(
                                      leading: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file4 !=
                                              null
                                          ? Icon(Icons.file_download_done)
                                          : Icon(Icons.error),
                                      title: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file4 !=
                                              null
                                          ? Text(Provider.of<Files>(context,
                                                  listen: false)
                                              .file4
                                              .toString()
                                              .split("/")
                                              .last,style: GoogleFonts.openSans())
                                          : Text('File not found',style: GoogleFonts.openSans(),),
                                    ),
                                    ListTile(
                                      leading: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file5 !=
                                              null
                                          ? Icon(Icons.file_download_done)
                                          : Icon(Icons.error),
                                      title: Provider.of<Files>(context,
                                                      listen: false)
                                                  .file5 !=
                                              null
                                          ? Text(Provider.of<Files>(context,
                                                  listen: false)
                                              .file5
                                              .toString()
                                              .split("/")
                                              .last,style: GoogleFonts.openSans())
                                          : Text('File not found',style: GoogleFonts.openSans(),),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black87,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            Provider.of<Files>(context, listen: false)
                                .updatefile(null, null, null, null, null);
                            setState(() {});
                            documentspicker = await FilePicker.platform
                                .pickFiles(
                                    allowMultiple: true,
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'jpg']);
                            print(
                                "There is file ${Provider.of<Files>(context, listen: false).file5}");
                            if (documentspicker != null) {
                              documents = documentspicker!.paths
                                  .map((path) => File(path!))
                                  .toList();
                              print(
                                  "You have uploaded  ${documents!.length} files");

                              File file1, file2, file3, file4, file5;
                              if (documents!.length != 5) {
                                Get.snackbar(
                                  "Document Upload ",
                                  "Document Error pls select 5 file which are mentioned check more info ",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: Duration(seconds: 5),
                                );
                              } else {
                                file1 = documents![0];
                                file2 = documents![1];
                                file3 = documents![2];
                                file4 = documents![3];
                                file5 = documents![4];
                                print("$file1,$file2,$file3,$file4,$file5");
                                Provider.of<Files>(context, listen: false)
                                    .updatefile(
                                        file1, file2, file3, file4, file5);
                                setState(() {
                                  isfiles = true;
                                });
                              }
                            } else {}
                          },
                          child: Text(
                            "Upload Document",
                            style: GoogleFonts.openSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Document to be uploaded ?',
                              style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(Documentinfo());
                              },
                              child: Text(
                                'More info',
                                style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 8,
                            ),
                          ),
                          onPressed: _create,
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.openSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an Account ?',
                              style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.off(SignIn(app: app));
                              },
                              child: Text(
                                ' Sign In',
                                style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700),
                              ),
                            ),
                          ],
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
}
