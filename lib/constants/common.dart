import 'package:flutter/material.dart';

const primaryBgColor = Color(0xfff3e5f5);
const primaryColor = Color(0xff673ab7);
const senterChatColor = Color.fromARGB(255, 82, 52, 134);
const recieverChatColor = Color.fromARGB(255, 150, 126, 190);
const debitColor = Color.fromARGB(255, 212, 21, 7);
const credittedColor = Color.fromARGB(255, 16, 143, 20);

Widget transText(
    {required String text,
    double size = 0,
    Color? color,
    bool bold = false,
    TextOverflow? overflow}) {
  return Text(
    text,
    style: TextStyle(
        color: color,
        fontFamily: 'SofiSans',
        letterSpacing: 1,
        fontSize: size != 0 ? size : null,
        fontWeight: bold ? FontWeight.bold : null,
        overflow: overflow),
  );
}

isNumeric(string) => num.tryParse(string) != null;

getId(String data) {
  return data.substring(0, data.indexOf('_'));
}

getName(String data) {
  return data.substring(data.indexOf('_') + 1);
}
