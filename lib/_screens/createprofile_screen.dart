import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:leap/_screens/home_screen.dart';

import '../auth_service.dart';
import '../providers/navigator.dart';
import '../reusable_widgets/reusable_widget.dart';

import 'package:http/http.dart';

class CreateProfileScreen extends StatefulWidget {
  final userDetails;
  const CreateProfileScreen({Key? key, this.userDetails}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  XFile? _image;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _year = TextEditingController();

  final List<String> gender_list = <String>['Male', 'Female'];
  final List<String> course_list = <String>['BSIT', 'BEED', 'BSED', 'BSHM'];
  String dropdownValue = "";
  String coursedropdownValue = "";

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

  makePostRequest(requestBody, loadingContext) async {
    print(requestBody);
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    print("backendUrl::$backendUrl/api/users/create");
    final uri = Uri.parse("$backendUrl/api/users/create");
    final headers = {'content-type': 'application/json'};
    Map<String, dynamic> body = requestBody;
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    print(response);

    if(statusCode == 200){
      Navigator.pop(loadingContext);
      NavigatorController().pushAndRemoveUntil(context, HomeScreen(), false);
    } else {
      Navigator.pop(loadingContext);
      _showErrorDialogBox('Unexpected Error occured!');
    }

  }

  _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print(image);
    });
  }

  Future _initRetrieval() async {
    if(widget.userDetails != null){
      var ud = widget.userDetails;
      _username.text = ud['username'];
      _firstname.text = ud['first_name'];
      _lastname.text = ud['last_name'];
      _address.text = ud['address'];
      _birthday.text = ud['birthday'];
      _year.text = ud['year'];
      dropdownValue = ud['gender'];
      coursedropdownValue = ud['course'];
    }
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if(widget.userDetails == null) const Align(
                    alignment: Alignment.centerLeft,
                    child: Text( 'Create your profile',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 30
                        )
                    ),
                  ),
                  if(widget.userDetails == null) const Align(
                    alignment: Alignment.centerLeft,
                    child: Text( 'We need to know you well',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 15
                        )
                    ),
                  ),
                  if(widget.userDetails == null) const SizedBox(
                      height: 50
                  ),
                  InkWell(
                    onTap: _getImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: (_image != null) ? ClipPath(
                        clipper: CircleClipper(),
                        child: Image.file(
                          File(_image!.path),
                        ),
                      ) : const Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                  const SizedBox(
                      height: 30
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
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value!;
                        print("dropdownValue:: $dropdownValue");
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
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd");

                        String formattedDate = dateFormat.format(pickedDate);
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

                      // ignore: use_build_context_synchronously
                      makePostRequest({
                        'uid': user.uid,
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
                      }, loadingContext);

                      /*Future<void> addUser() {
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
                      addUser();*/
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

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}