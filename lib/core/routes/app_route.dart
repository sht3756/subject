import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/todo/views/to_do_screen.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';
import 'package:subject/app/domain/user/views/sign_in_screen.dart';
import 'package:subject/core/bindings/auth_binding.dart';
import 'package:subject/core/bindings/to_do_binding.dart';

class AppRouter {
  static List<GetPage> pageLists = [
    GetPage(
      name: '/sign_in',
      page: () => const SignInScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/',
      page: () => const ToDoScreen(),
      binding: ToDoBiding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthController.to.user == null) {
      return const RouteSettings(name: '/sign_in');
    }
    return null;
  }
}
