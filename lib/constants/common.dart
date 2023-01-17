import 'package:flutter/material.dart';

const primaryBgColor = Color(0xfff3e5f5);
const primaryColor = Color(0xff673ab7);
const chatColor = Color.fromARGB(255, 158, 111, 238);


Widget transText({required String text, double size=0 ,Color? color,bool bold = false}){


  return Text(
    text,
    style: TextStyle(
      color: color,
      fontFamily: 'SofiSans',
      letterSpacing: 1,
      fontSize: size!=0?size:null,
      fontWeight: bold?FontWeight.bold:null
    ),
  );

}