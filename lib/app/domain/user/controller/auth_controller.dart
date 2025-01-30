import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subject/app/domain/user/models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final AuthService _authService = AuthService();

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Firebase Auth 상태 감지
    firebaseUser.bindStream(_authService.authStateChanges());

    ever(firebaseUser, (User? user) {
      if (user == null) { // 로그아웃 상태시, 회원가입 페이지로 이동
        Get.offAllNamed('/sign_in');
      }
    });
  }

  // 현재 유저
  User? get user => firebaseUser.value;

  // 초기 라우트
  String getInitialRoute() {
    return user != null ? '/todo' : '/sign_in';
  }

  // 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // 로그인
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  // 회원가입
  Future<bool> register(email, password) async {
    final User? user =
        await _authService.createUserWithEmailAndPassword(email, password);

    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  // 유저들 정보
  Future<List<UserModel>> fetchMemberList() async {
    final List<UserModel> members = await _authService.fetchMemberList();

    return members;
  }
}
