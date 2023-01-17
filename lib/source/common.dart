import 'package:flutter/material.dart';

const primaryBgColor = Color(0xfff3e5f5);
const primaryColor = Color(0xff673ab7);

Widget transText({required String text, double size=0}){


  return Text(
    text,
    style: TextStyle(
      //color: Colors.white,
      fontFamily: 'SofiSans',
      letterSpacing: 1,
      fontSize: size!=0?size:null,
    ),
  );

}