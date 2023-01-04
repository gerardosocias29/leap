import 'package:flutter/material.dart';

class NavigatorController {

  pushAndRemoveUntil(context, screen, route){
    return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => screen), (route) => false );
  }

  pushReplacement(context, screen){
    return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => screen) );
  }

}