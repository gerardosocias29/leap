import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leap/_screens/home_screen.dart';

import '../auth_service.dart';
import '../providers/navigator.dart';
import '../reusable_widgets/reusable_widget.dart';

import 'package:http/http.dart' as http;

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {

  final TextEditingController _username = TextEditingController();
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _year = TextEditingController();

  final List<String> gender_list = <String>['Male', 'Female'];
  final List<String> course_list = <String>['BSIT', 'BSCS', 'Other'];

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
    String dropdownValue = gender_list.first;
    String coursedropdownValue = course_list.first;

    return Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text( 'Create your profile',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 30
                        )
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text( 'We need to know you well',
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
                    decoration: reusableInputDecoration(context, 'Username', 'Type your username'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _username,
                    onSaved: (value) {
                      // _authData['email'] = value!;
                    },
                  ),
                  const SizedBox(
                      height: 30
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 15.0),
                          child: TextFormField(
                            decoration: reusableInputDecoration(context, 'First Name', 'Type your first name'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: _firstname,
                            onSaved: (value) {
                              // _authData['email'] = value!;
                            },
                          ),
                        )
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15.0),
                          child: TextFormField(
                            decoration: reusableInputDecoration(context, 'Last Name', 'Type your last name'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: _lastname,
                            onSaved: (value) {
                              // _authData['email'] = value!;
                            },
                          ),
                        )
                      ),
                    ]
                  ),
                  const SizedBox(
                      height: 30
                  ),
                  DropdownButtonFormField(
                    decoration: reusableInputDecoration(context, 'Gender', 'Select Gender'),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      // _authData['password'] = value!;
                    },
                    items: gender_list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                  ),
                  const SizedBox(
                      height: 30
                  ),
                  TextFormField(
                    decoration: reusableInputDecoration(context, 'Address', 'Type your address'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _address,
                    onSaved: (value) {
                      // _authData['email'] = value!;
                    },
                  ),
                  const SizedBox(
                    height: 30
                  ),
                  TextFormField(
                    decoration: reusableInputDecoration(context, 'Birthdate', 'Select your birthday', Icon(Icons.calendar_today, color: Theme.of(context).primaryColor)),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _birthday,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(DateTime.now().year-2),
                        firstDate: DateTime(1950,1,1),
                        lastDate: DateTime(DateTime.now().year-2),
                      );
                      if (pickedDate != null) {
                        String formattedDate = DateFormat.yMMMd().format(pickedDate);
                        setState(() {
                          _birthday.text = formattedDate.toString(); //set output date to TextField value.
                        });
                      } else {}
                    },
                  ),
                  const SizedBox(
                    height: 30
                  ),
                  DropdownButtonFormField(
                    decoration: reusableInputDecoration(context, 'Course', 'Select Course'),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      // _authData['password'] = value!;
                    },
                    items: course_list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        coursedropdownValue = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30
                  ),
                  TextFormField(
                    decoration: reusableInputDecoration(context, 'Course Year', 'Type your course year'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _year,
                    onSaved: (value) {
                      // _authData['email'] = value!;
                    },
                  ),
                  const SizedBox(
                    height: 30
                  ),
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return ;
                      }
                      _formKey.currentState?.save();
                      var loadingContext = context;
                      progressDialogue(loadingContext);
                      CollectionReference users = FirebaseFirestore.instance.collection('users');
                      var user = await AuthService().getCurrentUser();
                      print(user);
                      Future<void> addUser() {
                        return users.doc(user.uid).set({
                          'id': user.uid,
                          'address': _address.text,
                          'birthday': _birthday.text,
                          'course': coursedropdownValue,
                          'deleted_at': 0,
                          'email': user.email,
                          'first_name': _firstname.text,
                          'gender': dropdownValue,
                          'last_name': _lastname.text,
                          'phone': "",
                          'role_id': 1,
                          'school_id': 1,
                          'username': _username.text,
                          'year': _year.text,
                          'photoURL': "",
                        })
                        .then((value) => {
                          Navigator.pop(loadingContext),
                          NavigatorController().pushAndRemoveUntil(context, HomeScreen(), false),
                        })
                        .catchError((error) => {
                          Navigator.pop(loadingContext),
                          print("Failed to add user: $error")
                        });
                      }
                      addUser();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minWidth: double.infinity,
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: const Text(
                      'PROCEED',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60
                  ),
                ]
              )
            )
          )
        ),
      ),
    );
  }
}