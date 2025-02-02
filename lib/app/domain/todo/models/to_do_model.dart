import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoModel {
  final String id;
  final String title;
  final String content;
  final double? weight;
  final String status;
  final String worker;
  final Timestamp? createDate;
  bool? isDelete;

  ToDoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.weight,
    required this.status,
    required this.worker,
    required this.createDate,
    this.isDelete,
  });

  factory ToDoModel.fromJson(Map<String, dynamic> json) {
    return ToDoModel(
      id : json['id'],
      title : json['title'],
      content : json['content'],
      weight : json['weight'],
      status : json['status'],
      worker : json['worker'],
      createDate : json['createDate'],
      isDelete: json['isDelete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'weight': weight,
      'status': status,
      'worker': worker,
      'createDate' : createDate,
      'isDelete' : isDelete,
    };
  }
}
