import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../providers/navigator.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final userStorage = StorageProvider().userStorage();
  final _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool _showPassword = true;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _showErrorDialogBox(String message) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(message),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text( 'Create an account',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 30
                        )
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text( 'Connect with your friends today!',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15
                        )
                      ),
                    ),
                    const SizedBox(
                      height: 50
                    ),

                    TextFormField(
                      decoration: reusableInputDecoration(context, 'Email', 'Type your email address'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordFocusNode,
                      controller: _emailTextController,
                      validator: (value) {
                        RegExp regex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                        if (!regex.hasMatch(value!)) {
                          return 'Enter a Valid Email';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        // _authData['email'] = value!;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: 'Type your password',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _togglevisibility();
                          },
                          child: Icon(
                            _showPassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).primaryColor),
                        ),
                      ),
                      obscureText: _showPassword,
                      textInputAction: TextInputAction.done,
                      controller: _passwordTextController,
                      validator: (value) {
                        if (value!.isEmpty || value.length <= 7) {
                          return 'Password is too short!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // _authData['password'] = value!;
                      },
                    ),
                    const SizedBox(
                      height: 30  ,
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return ;
                        }
                        _formKey.currentState?.save();
                        var loadingContext = context;
                        progressDialogue(loadingContext);
                        AuthService().createUserWithEmailAndPassword(_emailTextController, _passwordTextController).then((value) async {
                          var user_id = (await AuthService().getUserId());
                          StorageProvider().storageAddItem(userStorage, 'user_id', user_id);
                          Navigator.pop(loadingContext);
                          NavigatorController().pushAndRemoveUntil(context, CreateProfileScreen(), false);
                        }).onError((error, stackTrace) {
                          Navigator.pop(loadingContext);
                          var errorString = error.toString();
                          var errorMessage = errorString.contains('[firebase_auth/email-already-in-use]') ? "This email is already in use." :
                          (errorString.contains('[firebase_auth/weak-password]') ? "The password is weak." : "Invalid email address or operations not allowed!");
                          _showErrorDialogBox(errorMessage);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minWidth: double.infinity,
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
                ),
              ),
          ),
        ),
      ),
    );
  }
}