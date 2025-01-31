import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  late bool isSignInMode = false;
  late bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSignInMode ? '회원가입' : '로그인',
                    style: const TextStyle(fontSize: 25),
                  ),
                  const SizedBox(height: 10),
                  if (isSignInMode) ...[
                    TextFormField(
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "이름",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                  ],
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "이메일",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이메일을 입력해주세요.';
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
                          .hasMatch(value)) {
                        return '올바른 이메일 형식을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "비밀번호",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      } else if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onHover: (bool hover) {
                      setState(() {
                        isHover = hover;
                      });
                    },
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          if (isSignInMode) {
                            await AuthController.to.register(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          } else {
                            await AuthController.to.signIn(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          }
                          Get.offNamed('/todo');
                        } catch (e) {
                          Get.snackbar("Error", e.toString());
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isSignInMode ? '가입하기' : '로그인',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isSignInMode ? '이미 계정이 있습니까?' : '계정이 없습니까?'),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSignInMode = !isSignInMode;
                          });
                        },
                        child: Text(
                          isSignInMode ? '여기에서 로그인하세요!' : '여기에서 가입하세요!',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
