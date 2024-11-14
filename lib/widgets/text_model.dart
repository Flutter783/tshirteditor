import 'package:flutter/material.dart';

class TextModel {
  String text;
  TextStyle textStyle;
  bool isSelected;
  TextAlign textAlign;
  double top;
  double left;
  double angle;
  double valueX;
  double valueY;
  TextModel({required this.text, required this.textStyle, this.isSelected = true, this.textAlign=TextAlign.center, this.top=0, this.left=0, this.angle=0, this.valueX = 0.0, this.valueY = 0.0});
  void updateTextSize(double newSize) {
    textStyle = textStyle.copyWith(fontSize: newSize);
  }
}