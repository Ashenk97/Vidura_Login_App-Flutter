import 'package:flutter/material.dart';
import 'package:login_app/components/text_field_container.dart';
import 'package:login_app/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> validator;
  final ValueChanged<String> onSaved;
  final bool confirm;
  final TextEditingController controller;
  const RoundedPasswordField(
      {Key key, this.validator, this.onSaved, this.confirm, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        controller: controller,
        validator: validator,
        onSaved: onSaved,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: confirm ? "Confirm Password" : "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
