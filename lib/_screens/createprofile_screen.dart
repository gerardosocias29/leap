import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:leap/_screens/home_screen.dart';

import '../api.dart';
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
  late List<String> course_list = <String>[];
  final List<String> year_list = <String>['1', '2', '3', '4'];

  String dropdownValue = '';
  String coursedropdownValue = '';
  String yearDropdownValue = "1";
  int role_id = 1;
  final _formKey = GlobalKey<FormState>();
  late bool _isUpdate = false;
  late var _isloading = false;
  late bool isPhotoUpdate = false;
  late bool isGetImage = false;
  String photoURL = "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";
  late Uint8List imageBytes;

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

  makePutRequest(data, loadingContext, url) async {
    var response = await Api().putRequest(data, url);

    print(response);
    if(response['status']){
      Navigator.pop(loadingContext);
      // ignore: use_build_context_synchronously
      NavigatorController().pushAndRemoveUntil(context, const HomeScreen(), false);
    } else {
      Navigator.pop(loadingContext);
      _showErrorDialogBox('Unexpected Error occured!');
    }
  }

  _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final compressedImage = await compressImage(File(image.path));
      final bytes = await compressedImage!.readAsBytes();
      setState(() {
        isPhotoUpdate = true;
        isGetImage = true;
        photoURL = base64Encode(bytes);
        imageBytes = base64Decode(photoURL);
      });
    }
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minHeight: 200,
      minWidth: 200,
    );
    return result;
  }

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var urls = [
      'courses/get'
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      // course_list.clear();
      for(var x=0; x<datas[0].length; x++) {
        course_list.insert(x, datas[0][x]['course_name']);
      }

      if(widget.userDetails != null){
        var ud = widget.userDetails;

        if(ud['birthday'] != null){
          var originalDate = DateTime.parse(ud['birthday']);
          DateFormat dateFormat = DateFormat("yyyy-MM-dd");
          String formattedDate = dateFormat.format(originalDate);
          _birthday.text = formattedDate.toString(); //se
        } else {
          _birthday.text = ud['birthday'];
        }

        // hasPhoto = (ud['photoURL'] != null);
        if(widget.userDetails['photoURL'] != null){
          imageBytes = base64Decode('${widget.userDetails['photoURL']}');
          isPhotoUpdate = true;
          isGetImage = false;
        }

        _username.text = ud['username'];
        _firstname.text = ud['first_name'];
        _lastname.text = ud['last_name'];
        _address.text = ud['address'];
        yearDropdownValue = (ud['year'] == null ) ? year_list.first : ud['year'];
        dropdownValue = (ud['gender'] == null ) ? gender_list.first : ud['gender'];
        coursedropdownValue = (ud['course'] == null ) ? course_list.first : ud['course'];
        role_id = ud['role_id'];
        setState(() {
          _isUpdate = true;
          _isloading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading ?
      Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ) : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
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
                    child: isPhotoUpdate || isGetImage ? CircleAvatar(
                      backgroundImage: MemoryImage(imageBytes),
                      radius: 50.0,
                    ) : CircleAvatar(
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
                    value: dropdownValue,
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
                    value: coursedropdownValue,
                  ),
                  const SizedBox(
                    height: 30
                  ),
                  DropdownButtonFormField(
                    decoration: reusableInputDecoration(context, 'Year', 'Select Year'),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      // _authData['password'] = value!;
                    },
                    items: year_list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        yearDropdownValue = value!;
                      });
                    },
                    value: yearDropdownValue,
                  ),
                  /*TextFormField(
                    decoration: reusableInputDecoration(context, 'Course Year', 'Type your course year'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _year,
                    onSaved: (value) {
                      // _authData['email'] = value!;
                    },
                  ),*/
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
                      var data = {
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
                        'role_id': role_id,
                        'school_id': 1,
                        'username': _username.text,
                        'year': yearDropdownValue,
                        'photoURL': photoURL,
                      };
                      if(_isUpdate){
                        // ignore: use_build_context_synchronously
                        makePutRequest(data, loadingContext, 'users/update/${widget.userDetails['id']}');
                      } else {
                        // ignore: use_build_context_synchronously
                        makePostRequest(data, loadingContext);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minWidth: double.infinity,
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      _isUpdate ? 'UPDATE' : 'PROCEED',
                      style: const TextStyle(
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