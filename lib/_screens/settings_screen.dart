import 'package:flutter/material.dart';
import 'package:leap/api.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../reusable_widgets/reusable_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _distanceToField;
  final TextEditingController _schoolName = TextEditingController(text: 'Buenavista Community College');
  late final TextfieldTagsController _coursesController = TextfieldTagsController();
  final TextEditingController _couseAdd = TextEditingController();
  late var courseText = '';

  late var listsCourses = [];
  late var _isloading = false;

  bool _schooIsUpdate = false;
  void _toggleUpdateSave() async {

    if(_schooIsUpdate){
      print('value:: ${_schoolName.text}');
      var response = await Api().postRequest({'school_name': _schoolName.text}, 'school/update/1');
      print(response.body);
    }

    setState(() {
      _schooIsUpdate = !_schooIsUpdate;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var urls = [
      'school/get',
      'courses/get'
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      _schoolName.text = datas[0]['school_name'];
      listsCourses = datas[1];
      _isloading = false;
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'School Name',
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
                    hintText: 'Type school name',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _toggleUpdateSave();
                      },
                      child: Icon(
                        _schooIsUpdate ? Icons.check_circle_outline_rounded : Icons.edit_rounded,
                        color: _schooIsUpdate ? Colors.green : Theme.of(context).primaryColor),
                    ),
                  ),
                  // obscureText: _showPassword,
                  enableInteractiveSelection: true,
                  readOnly: !_schooIsUpdate,
                  textInputAction: TextInputAction.done,
                  controller: _schoolName,
                  onSaved: (value) {
                    // _authData['password'] = value!;
                  },
                ),
                const SizedBox( height: 20),

                Stack(
                  children: [
                    Positioned(
                      top: 17,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        // padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10)
                        ),
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(top: 12, bottom: 5),
                            alignment: Alignment.center,
                            color: Colors.white,
                            child: Text(
                              "Available Courses",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5.0,
                              children: List<Widget>.generate(
                                listsCourses.length,
                                (int index) {
                                  return InputChip(
                                    label: Text(listsCourses[index]['course_name']),
                                    selectedColor: Theme.of(context).primaryColor,
                                    backgroundColor: Theme.of(context).primaryColorLight,
                                    checkmarkColor: Theme.of(context).primaryColor,
                                    deleteIconColor: Colors.red,
                                    onDeleted: () async {
                                      var response = await Api().postRequest({
                                        'course_name': listsCourses[index]['course_name']
                                      }, 'courses/delete/${listsCourses[index]['id']}');
                                      print(response);
                                      setState(() {
                                        listsCourses.removeWhere((element) => element == listsCourses[index]);
                                        // inputs = inputs - 1;
                                      });
                                    },
                                  );
                                }
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox( height: 10),
                TextFormField(
                  decoration: reusableInputDecoration(context, 'Add Course', 'Type New Courses'),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  controller: _couseAdd,
                  onChanged: (value) {
                    courseText = value;
                  },
                  onSaved: (value) { },
                  onEditingComplete: () async {
                    var response = await Api().postRequest({
                      'course_name' : courseText
                    }, 'courses/create');
                    print(response);
                    setState(() {
                      _couseAdd.text = '';
                      _initRetrieval();
                    });
                  }
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}