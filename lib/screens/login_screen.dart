import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_app/components/already_have_an_account_acheck.dart';
import 'package:login_app/components/fb_login_btn.dart';
import 'package:login_app/components/rounded_button.dart';
import 'package:login_app/components/rounded_input_field.dart';
import 'package:login_app/components/rounded_password_field.dart';
import 'package:login_app/screens/components/background.dart';
import 'package:login_app/screens/components/divider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_svg/svg.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  FacebookLogin fbLogin = new FacebookLogin();
  final _auth = FirebaseAuth.instance;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
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
      final user = await _auth.signInWithEmailAndPassword(
          email: _authData['email'], password: _authData['password']);
      if (user != null) {
        Navigator.of(context).pushReplacementNamed((HomeScreen.routeName));
      }
    } catch (error) {
      var errorMessage = 'Authentication failed.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final AccessToken result =
        (await FacebookAuth.instance.login()) as AccessToken;

    // Create a credential from the access token
    final facebookAuthCredential =
        FacebookAuthProvider.credential(result.token);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
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
                  "LOGIN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/login.svg",
                  height: size.height * 0.35,
                ),
                SizedBox(height: size.height * 0.03),
                RoundedInputField(
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
                RoundedButton(
                  text: "LOGIN",
                  press: () {
                    _submit();
                  },
                ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  login: true,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignupScreen();
                        },
                      ),
                    );
                  },
                ),
                OrDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SocialIcon(
                      iconSrc: "assets/icons/facebook.svg",
                      press: () async {
                        signInWithFacebook();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
