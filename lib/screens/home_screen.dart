import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/screens/components/background.dart';
import 'package:login_app/screens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

User loggedInUser;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String firstName;
  String lastName;
  String imageUrl =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
  @override
  void initState() {
    loggedInUser = _auth.currentUser;

    getData();
    super.initState();
  }

  void getData() async {
    var document = _firestore.collection('users').doc(loggedInUser.uid);
    document.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(documentSnapshot.data()['firstName']);
        setState(() {
          firstName = documentSnapshot.data()['firstName'];
          lastName = documentSnapshot.data()['lastName'];
          imageUrl = documentSnapshot.data()['image'] != null
              ? documentSnapshot.data()['image']
              : "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
        });
      }
    });
  }

  void uploadImage() async {
    print("HRER AT THE IMAGE UPLOAD");
    final _imagePicker = ImagePicker();
    PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      image = await _imagePicker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        //Upload to Firebase
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images/' + loggedInUser.uid);
        UploadTask uploadTask = storageReference.putFile(file);
        uploadTask.whenComplete(() {
          storageReference.getDownloadURL().then((value) async {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(loggedInUser.uid)
                .update({'image': value});
            setState(() {
              imageUrl = value;
            });
          });
        }).catchError((onError) {
          print(onError);
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple.shade800,
          title: Text('Home Screen'),
          actions: [
            IconButton(
                onPressed: () {
                  _signOut();
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Background(
          //   width: MediaQuery.of(context).size.width,
          //   decoration: BoxDecoration(color: Colors.blueGrey),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Image(
                  image: NetworkImage(imageUrl),
                  width: 150,
                ),
                onTap: () {
                  uploadImage();
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'E-mail',
                style: TextStyle(fontSize: 15, color: Colors.purple),
              ),
              Text(
                "${loggedInUser.email}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'First Name',
                style: TextStyle(fontSize: 15, color: Colors.purple),
              ),
              Text(
                firstName != null ? firstName : 'first name',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Last Name',
                style: TextStyle(fontSize: 15, color: Colors.purple),
              ),
              Text(
                lastName != null ? lastName : 'last name',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              RaisedButton(
                child: Text("Upload Image",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                onPressed: () {
                  uploadImage();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple)),
                elevation: 5.0,
                color: Colors.purple.shade800,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                splashColor: Colors.grey,
              ),
            ],
          ),
        ));
  }
}
