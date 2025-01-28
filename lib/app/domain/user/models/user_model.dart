import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final Timestamp registerDate;
  final Timestamp modifiedDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.registerDate,
    required this.modifiedDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      registerDate: json['registerDate'],
      modifiedDate: json['modifiedDate'],
    );
  }
  Map<String,dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'registerDate': registerDate,
      'modifiedDate': modifiedDate,
    };
  }
}
