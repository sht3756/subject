import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "이메일",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthController.to.signIn(emailController.text.trim(),
                      passwordController.text.trim());
                  Get.offNamed('/todo');
                } catch (e) {
                  print(e);
                  Get.snackbar("Error", e.toString());
                }
              },
              child: const Text("로그인"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthController.to.register(emailController.text.trim(),
                      passwordController.text.trim());
                  Get.offNamed('/todo');
                } catch (e) {
                  print(e);
                  Get.snackbar("Error", e.toString());
                }
              },
              child: const Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
