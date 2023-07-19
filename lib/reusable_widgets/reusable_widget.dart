import 'dart:convert';

import 'package:achievement_view/achievement_view.dart';
import 'package:achievement_view/achievement_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import '../api.dart';

showErrorDialogBox(context, String message) async {
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

showDeleteConfirmationDialog(context, callback) async {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Attention!'),
      content: const Text('You are about to delete this item, do you wish to proceed?'),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Cancel'),
        ),
        MaterialButton(
          child: const Text("Yes"),
          onPressed: () {
            callback();
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

showNotificationDialog(context, String message, [String? title]) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text( title ?? 'Instructions'),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(message)
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text( title != null ? 'Close' : 'Agree'),
        ),
      ],
    ),
  );
}

progressDialogue(BuildContext context) {
  //set up the AlertDialog
  AlertDialog alert = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(),
    ),
  );
  showDialog(
    //prevent outside touch
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      //prevent Back button press
      return WillPopScope(onWillPop: () async => false, child: alert);
    },
  );
}

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

InputDecoration reusableInputDecoration(context, String label, String hint, [Icon? icon]){
  return InputDecoration(
    labelText: label,
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
    hintText: hint,
    suffixIcon: icon,
    hintStyle: const TextStyle(
      fontSize: 16,
    ),
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container firebaseUIButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

Column buildButtonColumn(Color color, Color splashColor, IconData icon,
  String label, Function func) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: Icon(icon),
        color: color,
        splashColor: splashColor,
        onPressed: () => func()),
      Container(
        margin: const EdgeInsets.only(top: 8.0),
        child: Text(label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: color)))
    ]);
}

AlertDialog idNumberDialog(context, [callback]){
  var idNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var isLoading = false;
  late var validId = "";
  checkUserIdNUmber(idNumber) async {
    print("idNumber:: $idNumber");
    isLoading = true;
    var urls = [
      'check-student-id/${idNumber}', // 0
    ];
    var datas = await Api().multipleGetRequest(urls);
    if(datas[0].length > 0){
      validId = idNumber;
      isLoading = false;
      callback(datas[0]);
      Navigator.pop(context);
      return false;
    } else {
      validId = "";
      _formKey.currentState!.validate();
      return true;
    }
  }

  return AlertDialog(
    title: const Text('Student ID Number'),
    content: SizedBox(
      width: double.maxFinite,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [

            TextFormField(
              decoration: reusableInputDecoration(context, 'ID Number', 'Your ID NUMBER'),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              controller: idNumberController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a valid ID Number';
                }
                if(validId == ""){
                  return 'Please enter a valid ID Number';
                }
                return null;
              },
              onSaved: (value) { },
            ),
          ],
        ),
      )
    ),
    actions: [
      TextButton(
        onPressed: () async {
          checkUserIdNUmber(idNumberController.text);
        },
        child: const Text('Check'),
      ),
    ]
  );

}

AlertDialog alertDialog(context, title, reference_id, shrinkWrap, type, [callback, item = '']) {
  var url = (type == "Lesson") ? "lessons/create" : (type == "Topic") ? "topics/create" : "";
  var text_title = '';
  var text_content = '';
  if(type == 'update_lesson'){
    url = "lessons/update/${item['id']}";
    text_title = item['lesson_name'];
    text_content = (item['lesson_details'] == null || item['lesson_details'] == '') ? '' : item['lesson_details'];
  }
  if(type == 'update_topic'){
    url = "topics/update/${item['id']}";
    text_title = item['topic_title'];
    text_content = (item['topic_details'] == null || item['topic_details'] == '') ? '' : item['topic_details'];
  }

  makePostRequest(requestBody, loadingContext, url) async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    print("backendUrl::$backendUrl/api/$url");
    final uri = Uri.parse("$backendUrl/api/$url");
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
    print("statusCode::$statusCode");
    print(requestBody);
    if(callback != null){
      callback();
    }
    Navigator.pop(loadingContext);
  }

  makePutRequest(data, loadingContext, url) async {
    print(data);
    var response = await Api().putRequest(data, url);
    print(response);
    if(callback != null){
      callback();
    }
    Navigator.pop(context);
  }

  var titleController = TextEditingController(text: text_title);
  var contentController = TextEditingController(text: text_content);
  return AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: double.maxFinite,
      child: ListView(
        shrinkWrap: shrinkWrap,
        children: [
          TextFormField(
            decoration: reusableInputDecoration(context, 'Title', '$type Title'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: titleController,
            onSaved: (value) {
              // _authData['email'] = value!;
            },
          ),
          const SizedBox(
            height: 30
          ),
          TextFormField(
            controller: contentController,
            decoration: reusableInputDecoration(context, 'Content', '$type Content'),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 8,
          )
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      if(type != "update_lesson" && type != "update_topic") TextButton(
        onPressed: () {
          // Send them to your email maybe?
          var title = titleController.text;
          var content = contentController.text;
          var data;
          if(type == "Lesson"){
            data = {
              "lesson_name": title,
              "lesson_details": content,
              "chapter_id" : reference_id
            };
          } else {
            data = {
              "topic_title": title,
              "topic_details": content,
              "lesson_id" : reference_id
            };
          }
          makePostRequest(data, context, url);
          // Navigator.pop(context);
        },
        child: const Text('Save'),
      ) else TextButton(
        onPressed: () {
        // Send them to your email maybe?
        var title = titleController.text;
        var content = contentController.text;
        var data;
        if(type == "update_lesson"){
          data = {
            "lesson_name": title,
            "lesson_details": content,
            "chapter_id" : reference_id
          };
        } else {
          data = {
            "topic_title": title,
            "topic_details": content,
            "lesson_id" : reference_id
          };
        }
        makePutRequest(data, context, url);
        // Navigator.pop(context);
        },
        child: const Text('Update')
      ),
    ],
  );
}

AlertDialog alertDialogQuiz(context, title, topic_id, shrinkWrap, [callback, data = '']) {
  var url = 'quizzes/create';
  var url_update = 'quizzes/update/$topic_id';
  print(data);

  makePostRequest(requestBody, loadingContext, url) async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    print("backendUrl::$backendUrl/api/$url");
    final uri = Uri.parse("$backendUrl/api/$url");
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
    print("statusCode::$statusCode");
    print(requestBody);
    if(callback != null){
      callback();
    }
    Navigator.pop(context);
  }

  makePutRequest(data, loadingContext, url) async {
    var response = await Api().putRequest(data, url);
    print(response);
    if(callback != null){
      callback();
    }
    Navigator.pop(context);
  }

  var questionController = TextEditingController(text: data!='' ? data['quiz_question'] : '');
  var choicesController = TextEditingController(text: data!='' ? data['quiz_choices'] : '');
  var answerController = TextEditingController(text: data!='' ? data['quiz_answer'] : '');
  var timeLimitController = TextEditingController(text: data!='' ? data['timer'].toString() : '');

  final List<String> quiz_type = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> answer_type = <String>['Choices', 'Speak'];
  String quizTypeDropdownValue = quiz_type.first;
  String answerTypeDropdownValue = answer_type.first;

  return AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: double.maxFinite,
      child: ListView(
        shrinkWrap: shrinkWrap,
        children: [
          TextFormField(
            decoration: reusableInputDecoration(context, 'Quiz Question', 'Quiz Question'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: questionController,
            onSaved: (value) {
              // _authData['email'] = value!;
            },
          ),
          const SizedBox(
              height: 30
          ),
          TextFormField(
            controller: choicesController,
            decoration: reusableInputDecoration(context, 'Quiz Choices', 'Quiz Choices (comma separated)'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(
              height: 30
          ),
          TextFormField(
            controller: answerController,
            decoration: reusableInputDecoration(context, 'Quiz Answer', 'Quiz Answer'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(
            height: 30,
          ),
          DropdownButtonFormField(

            decoration: reusableInputDecoration(context, 'Quiz Type', 'Select Quiz Type'),
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              // _authData['password'] = value!;
            },
            items: quiz_type.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              quizTypeDropdownValue = (value! ?? '') as String;
            },
            value: data!='' ? data['quiz_type'][0].toUpperCase() + data['quiz_type'].substring(1) : quizTypeDropdownValue, // need to capitalize first letter
          ),
          const SizedBox(
            height: 30,
          ),
          DropdownButtonFormField(
            decoration: reusableInputDecoration(context, 'Answer Mode', 'Select Answer Mode'),
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              // _authData['password'] = value!;
            },
            items: answer_type.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              answerTypeDropdownValue = (value! ?? '') as String;
            },
            value: data!='' ? data['answer_type'][0].toUpperCase() + data['answer_type'].substring(1) : answerTypeDropdownValue,
          ),
          const SizedBox(
            height: 30
          ),
          TextFormField(
            controller: timeLimitController,
            decoration: reusableInputDecoration(context, 'Quiz Time Limit', 'Quiz Time Limit'),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      if(data == '') TextButton(
        onPressed: () {
          // Send them to your email maybe?
          var question = questionController.text;
          var choices = choicesController.text;
          var answer = answerController.text;
          var timelimit = timeLimitController.text;

          var data = {
            'quiz_type' : quizTypeDropdownValue.toLowerCase(),
            'answer_type': answerTypeDropdownValue.toLowerCase(),
            'quiz_question' : question,
            'quiz_answer' : answer,
            'quiz_choices' : choices,
            'timer' : timelimit*1,
            'topic_id' : topic_id,
          };

          makePostRequest(data, context, url);
          // Navigator.pop(context);
        },
        child: const Text('Save'),
      )
      else TextButton(
        onPressed: () {
          // Send them to your email maybe?
          var question = questionController.text;
          var choices = choicesController.text;
          var answer = answerController.text;
          var timelimit = timeLimitController.text;

          var data = {
            'quiz_type' : quizTypeDropdownValue.toLowerCase(),
            'answer_type': answerTypeDropdownValue.toLowerCase(),
            'quiz_question' : question,
            'quiz_answer' : answer,
            'quiz_choices' : choices,
            'timer' : timelimit
          };

          makePutRequest(data, context, url_update);
          // Navigator.pop(context);
        },
        child: const Text('Update'),
      ),
    ],
  );
}

showAchievementView(context, achievement){
  print('#' * 200);
  print('Achievement View');
  AchievementView(
      context,
      title: achievement['achievement_name'],
      subTitle: achievement['achievement_details'],
      //onTab: _onTabAchievement,
      icon: const Icon(Icons.star_border_outlined, color: Colors.white,),
      //typeAnimationContent: AnimationTypeAchievement.fadeSlideToUp,
      //borderRadius: 5.0,
      color: Theme.of(context).primaryColor,
      //textStyleTitle: TextStyle(),
      //textStyleSubTitle: TextStyle(),
      alignment: Alignment.topCenter,
      duration: Duration(seconds: 3),
      isCircle: true,
      listener: (status) async {
        //AchievementState.opening
        //AchievementState.open
        //AchievementState.closing
        //AchievementState.closed
        var stat = (status == AchievementState.closed);
        if(stat){
          print("status:: $status");
          var res = await Api().putRequest({'data':'data'}, 'user_achievement/update/${achievement['user_achievement_id']}');
          print(res);
        }
      }
  ).show();
}

privacyPolicyStatement() {
  return 'DATA PRIVACY POLICY STATEMENT\n\nThis application is committed to protecting the privacy and accuracy of confidential information to the extent possible, subject to provisions of the law. Other than as required by laws that guarantee public access to certain types of information, or in response to subpoenas or other legal instruments that authorize access, personally identifiable information is not actively shared. Re-distributing or selling personal information collected on our web servers is strictly prohibited.\n\nINFORMATION COLLECTED\n\nThis application collects the following information: Student’s last name, first name, middle name, gender, address, birthdate, student id number, email address, course, and year.\n\nUSE OF COLLECTED DATA\n\nThe data, which was collected from the students’ users are fed into the systems database, which is used to store the data collected and gathered. The student’s data will help the admin to know whom are those students excel in using the English grammar and English pronunciation.\n\nDISTRIBUTION OF COLLECTED INFORMATION\n\nWe will not disclose, without your consent, personal information collected about you, except for certain explicit circumstances in which disclosure is required by law.\n\nWe will not distribute or sell personal information to third-party organizations.';
}