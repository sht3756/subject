class ToDoModel {
  final String id;
  final String title;
  final String content;
  final int index;
  final String status;
  final String worker;

  ToDoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.index,
    required this.status,
    required this.worker,
  });

  factory ToDoModel.fromJson(Map<String, dynamic> json) {
    return ToDoModel(
      id : json['id'],
      title : json['title'],
      content : json['content'],
      index : json['index'],
      status : json['status'],
      worker : json['worker'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'index': index,
      'status': status,
      'worker': worker,
    };
  }
}
