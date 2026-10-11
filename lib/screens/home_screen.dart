import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/screens/components/background.dart';
import 'package:login_app/screens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

User? loggedInUser;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? firstName;
  String? lastName;
  String imageUrl =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
  @override
  void initState() {
    loggedInUser = _auth.currentUser;

    getData();
    super.initState();
  }

  void getData() async {
    final user = loggedInUser;
    if (user == null) return;
    var document = _firestore.collection('users').doc(user.uid);
    document.get().then((documentSnapshot) {
      final data = documentSnapshot.data();
      if (data != null) {
        setState(() {
          firstName = data['firstName'] as String?;
          lastName = data['lastName'] as String?;
          imageUrl = data['image'] != null
              ? data['image'] as String
              : "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
        });
      }
    });
  }

  void uploadImage() async {
    print("HRER AT THE IMAGE UPLOAD");
    final imagePicker = ImagePicker();
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      final user = loggedInUser;

      if (image != null && user != null) {
        var file = File(image.path);
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images/${user.uid}');
        try {
          final snapshot = await storageReference.putFile(file);
          final value = await snapshot.ref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({'image': value});
          setState(() {
            imageUrl = value;
          });
        } catch (onError) {
          print(onError);
        }
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
                "${loggedInUser?.email ?? ''}",
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
                firstName ?? 'first name',
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
                lastName ?? 'last name',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  foregroundColor: Colors.white,
                  elevation: 5.0,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.purple),
                  ),
                ),
                onPressed: () {
                  uploadImage();
                },
                child: const Text("Upload Image",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            ],
          ),
        ));
  }
}
