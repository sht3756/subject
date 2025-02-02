import 'package:flutter/material.dart';

Offset centerDrag(
    Draggable<Object> draggable, BuildContext context, Offset position) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  return Offset(renderObject.size.width / 2, renderObject.size.height / 2);
}