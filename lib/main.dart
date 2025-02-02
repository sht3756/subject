import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';
import 'package:subject/core/utils/firebase_config.dart';

import 'core/bindings/auth_binding.dart';
import 'core/routes/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: FirebaseConfig.options);
  Get.put(AuthController());
  runApp(const MyApp());
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