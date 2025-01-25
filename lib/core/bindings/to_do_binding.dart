import 'package:get/get.dart';
import 'package:subject/app/domain/todo/controller/to_do_controller.dart';

class ToDoBiding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ToDoController>(() => ToDoController());
  }
}