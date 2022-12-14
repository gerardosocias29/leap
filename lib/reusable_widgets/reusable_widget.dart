import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

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

AlertDialog alertDialog(context, title, reference_id, shrinkWrap, type) {
  var url = (type == "Lesson") ? "lessons/create" : (type == "Topic") ? "topics/create" : "";

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
    Navigator.pop(loadingContext);
  }

  var titleController = TextEditingController();
  var contentController = TextEditingController();
  return AlertDialog(
    title: Text(title),
    content: ListView(
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
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
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
        child: const Text('Send'),
      ),
    ],
  );
}