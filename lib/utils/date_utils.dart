import 'package:flutter/material.dart';

dateStringFormat(date){
  return "${date.year.toString()}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
}