import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trans_pay/constants/common.dart';

dateTile({required String text}) {
  return Center(
      child: Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: dateColor,
          ),
          child: transText(text: text, color: Colors.white)));
}
