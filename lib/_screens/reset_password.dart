import 'package:leap/_screens/signin_screen.dart';
import 'package:leap/reusable_widgets/reusable_widget.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../providers/navigator.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
                        child: Text( 'Password Reset',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 30
                          )
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text( 'We should help each other',
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
                        height: 30  ,
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        MaterialButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return ;
                            }
                            _formKey.currentState?.save();
                            setState(() {
                              _isLoading = true;
                            });
                            AuthService().sendPasswordResetEmail( email: _emailTextController.text).then((value){
                              NavigatorController().pushAndRemoveUntil(context, SignInScreen(), false);
                            }).onError((error, stackTrace) {
                              var errorString = error.toString();
                              var errorMessage = errorString.contains('[firebase_auth/user-not-found]') ? "There is no user record corresponding to this email. The user may have been deleted" : "Operations are not allowed!";
                              _showErrorDialogBox(errorMessage);
                              setState(() {
                                _isLoading = false;
                              });
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
                    ],
                  ),
                )),
          )),
    );
  }
}
