import 'package:flutter/material.dart';

Widget addToDoButton(VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    ),
  );
}
