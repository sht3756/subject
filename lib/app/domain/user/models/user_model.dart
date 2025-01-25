class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime registerDate;
  final DateTime modifiedDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.registerDate,
    required this.modifiedDate,
  });
}
