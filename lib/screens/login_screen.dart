import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leap/providers/auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../auth_service.dart';

class LoginScreen extends StatefulWidget with ChangeNotifier{
  final routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool _showPassword = true;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  bool _isChecked = false;
  void _handleRemeberme(value) {
    _isChecked = value;
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

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return '';
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).login(
        _authData['email']!,
        _authData['password']!,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (error.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return error.message;
    } catch (error) {
      const errorMessage = 'Authentication failed, please try again later.';
      print(error);
      _showErrorDialogBox(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
        Fluttertoast.showToast(
          msg: "Finally",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 12.0
        );
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 100, bottom: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text( 'Hi, Welcome to LEAP! 👋',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 30
                            )
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text( 'Have a great day!',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15
                            )
                          ),
                        )
                      ],
                    )
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                      hintText: 'Type your email address',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocusNode,
                    validator: (value) {
                      RegExp regex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                      if (!regex.hasMatch(value!)) {
                        return 'Enter a Valid Email';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _authData['email'] = value!;
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
                    //controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length <= 7) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
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
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: _submit,
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
                        text: "Sign up with Google",
                        onPressed: () {
                          AuthService().signInWithGoogle();
                        },
                      ),
                    ]
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Text('Don\'t have an account?    ', textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.5
                                )
                              ),
                              GestureDetector(
                                onTap: () {
                                  Fluttertoast.showToast(
                                    msg: "Sign Up",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 12.0
                                  );
                                },
                                child: Text("Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    height: 1,
                                    color: Theme.of(context).primaryColor
                                  )
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ]
                  )
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

}