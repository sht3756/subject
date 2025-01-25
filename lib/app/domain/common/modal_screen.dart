import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModalScreen extends StatefulWidget {
  final String id;

  const ModalScreen({super.key, required this.id});

  @override
  State<ModalScreen> createState() => _ModalScreenState();
}

class _ModalScreenState extends State<ModalScreen> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('This is the modal content.'),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
