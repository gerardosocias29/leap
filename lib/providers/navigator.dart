import 'package:flutter/material.dart';

class NavigatorController {

  pushAndRemoveUntil(context, screen, route){
    return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => screen), (route) => false );
  }

}