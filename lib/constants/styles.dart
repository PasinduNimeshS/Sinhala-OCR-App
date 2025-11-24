import 'package:flutter/material.dart';

const TextStyle descriptionStyle = TextStyle(
  fontSize: 12,
  color: Color(0xffB43F3F),
  fontWeight: FontWeight.w400,
);

const texInputDecoration = InputDecoration(
  hintText: "Email",
  fillColor: Color(0xffF9D8C5),
  hintStyle: TextStyle(color: Color(0xffB43F3F), fontSize: 12),
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffFF8225), width: 2),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffB43F3F), width: 2),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
);
