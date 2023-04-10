import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:leap/_screens/reset_password.dart';
import 'package:leap/api.dart';
import 'package:leap/auth_service.dart';
import 'package:leap/utils/color_utils.dart';

import '../_screens/home_screen.dart';
import '../_screens/signup_screen.dart';
import '../providers/navigator.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}
class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final userStorage = StorageProvider().userStorage();

  bool _showPassword = true;

  void _togglevisibility() {
    print(StorageProvider().storageGetItem(userStorage, 'user_id') == null);
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  bool _isChecked = false;
  void _handleRemeberme(value) {
    _isChecked = value;
    FirebaseAuth.instance.setPersistence(_isChecked ? Persistence.LOCAL : Persistence.SESSION);
    setState(() {
      _isChecked = value;
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

  getUserDetails(id, loadingContext) async {
    var urls = [
      'users/$id', // 0
    ];
    var datas = await Api().multipleGetRequest(urls);
    var userDetail = datas[0];
    if(userDetail['status'] == false){
      Navigator.pop(loadingContext);
      NavigatorController().pushAndRemoveUntil(context, CreateProfileScreen(), false);
    } else {
      Navigator.pop(loadingContext);
      NavigatorController().pushAndRemoveUntil(context, HomeScreen(), false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("FFF"),
            hexStringToColor("FFF"),
            hexStringToColor("FFF")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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
                    child: Text( 'Hi, Welcome to LEMA! 👋',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30
                      )
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text( 'Have a great day!',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15
                      )
                    ),
                  ),
                  const SizedBox(
                    height: 50,
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
                          _showPassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).primaryColor,),
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
                  forgetPassword(),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Remember Me"),
                    activeColor: Theme.of(context).primaryColor,
                    value: _isChecked,
                    onChanged: _handleRemeberme,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(
                    height: 10,
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
                      AuthService().signInWithEmailAndPassword(_emailTextController, _passwordTextController).then((value) async {

                        var user_id = (await AuthService().getUserId());
                        StorageProvider().storageAddItem(userStorage, 'user_id', user_id);
                        getUserDetails(user_id, loadingContext);
                      }).onError((error, stackTrace) {
                        Navigator.pop(loadingContext);
                        var errorString = error.toString();
                        var errorMessage = errorString.contains('[firebase_auth/user-not-found]') ? "This user does not exist." :
                        (errorString.contains('[firebase_auth/wrong-password]') ? "The password is invalid." : "Empty Email or Password!");
                        _showErrorDialogBox(errorMessage);
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minWidth: double.infinity,
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: const Divider()
                        )
                      ),
                      const Text('Or with'),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20.0),
                          child: const Divider()
                        )
                      ),
                    ]
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SignInButton(
                          Buttons.Google,
                          text: "Sign in with Google",
                          onPressed: () {
                            var loadingContext = context;
                            progressDialogue(loadingContext);
                            AuthService().signInWithGoogle().then((value) async {
                              var user_id = (await AuthService().getUserId());
                              getUserDetails(user_id, loadingContext);
                            }).onError((error, stackTrace) {
                              Navigator.pop(loadingContext);
                              var errorString = error.toString();
                              var errorMessage = errorString.contains('[firebase_auth/user-disabled]') ? "This user has been disabled." :
                              (errorString.contains('[firebase_auth/invalid-verification-code]') ? "The user has invalid verification code." : "Operations are not allowed!");
                              _showErrorDialogBox(errorMessage);
                            });
                          },
                        ),
                      ]
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  signUpOption(),
                ],
              )
            ),
          ),
        )
      ),
    );

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 60,
        ),
        const Text("Don't have account?",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignUpScreen()), (route) => true );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
  
}
