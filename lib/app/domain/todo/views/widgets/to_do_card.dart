import 'package:flutter/material.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';

Widget scheduleCard(
  ToDoModel item, {
  bool isDragging = false,
  VoidCallback? deleteOnPressed,
}) {
  return Opacity(
    opacity: isDragging ? 0.5 : 1.0,
    child: SizedBox(
      height: 120,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: isDragging ? 10 : 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: deleteOnPressed,
                    icon: const Icon(Icons.delete),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(item.weight.toString()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.id),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: item.worker.isNotEmpty
                        ? Text(
                            item.worker.characters.first,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
