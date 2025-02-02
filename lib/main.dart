import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';

import 'core/bindings/auth_binding.dart';
import 'core/routes/app_route.dart';
import 'package:logger/logger.dart';

void main() async {
  final Logger logger = Logger();

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Get.put(AuthController());
    runApp(const MyApp());
  }, (error, stackTrace) {
    logger.w('[runZonedGuarded!] $error, $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO',
      initialBinding: AuthBinding(),
      initialRoute: AuthController.to.getInitialRoute(),
      getPages: AppRouter.pageLists,
      defaultTransition: Transition.noTransition,
    );
  }
}
