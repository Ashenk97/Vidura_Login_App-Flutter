import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_app/components/already_have_an_account_acheck.dart';
import 'package:login_app/components/rounded_button.dart';
import 'package:login_app/components/rounded_input_field.dart';
import 'package:login_app/components/rounded_password_field.dart';
import 'package:login_app/screens/components/background.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _passwordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'firstName': '',
    'lastName': '',
  };

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      });
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error Occurred'),
        content: Text(msg),
        actions: [
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: _authData['email'], password: _authData['password']);
      if (newUser != null) {
        final user = _auth.currentUser;
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'firstName': _authData['firstName'],
          'lastName': _authData['lastName'],
        });

        Navigator.of(context).pushReplacementNamed((HomeScreen.routeName));
      }
    } catch (error) {
      var errorMessage = 'Authentication failed.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "SIGN UP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/signup.svg",
                  height: size.height * 0.15,
                ),
                SizedBox(height: size.height * 0.03),
                RoundedInputField(
                    hintText: "First Name",
                    validator: (value) {
                      if (value.isEmpty || value.contains('[0-9]')) {
                        return 'Invalid Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['firstName'] = value;
                    }),
                RoundedInputField(
                    hintText: "Last Name",
                    validator: (value) {
                      if (value.isEmpty || value.contains('[0-9]')) {
                        return 'Invalid Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['lastName'] = value;
                    }),
                RoundedInputField(
                    icon: Icons.email,
                    hintText: "Your Email",
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    }),
                RoundedPasswordField(
                  confirm: false,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 5) {
                      return 'Invalid Password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                RoundedPasswordField(
                  confirm: true,
                  validator: (value) {
                    if (value.isEmpty || value != _passwordController.text) {
                      return 'Invalid Password';
                    }
                    return null;
                  },
                  onSaved: (value) {},
                ),
                RoundedButton(
                  text: "SIGN UP",
                  press: () {
                    _submit();
                  },
                ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  login: false,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
