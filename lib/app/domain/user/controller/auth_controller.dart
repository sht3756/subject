import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subject/app/domain/user/models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  Rxn<UserModel> myUserData = Rxn<UserModel>();
  final AuthService _authService = AuthService();

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Firebase Auth 상태 감지
    firebaseUser.bindStream(_authService.authStateChanges());

    ever(firebaseUser, (User? user) {
      if (user == null) {
        // 로그아웃 상태시, 회원가입 페이지로 이동
        Get.offAllNamed('/sign_in');
      } else {
        _fetchMyUserData(user.email!);
      }
    });
  }

  // 현재 유저
  User? get user => firebaseUser.value;

  // 초기 라우트
  String getInitialRoute() {
    return user != null ? '/' : '/sign_in';
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
  Future<bool> register(String email, String password, String name) async {
    final User? user = await _authService.createUserWithEmailAndPassword(
        email, password, name);

    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  // 유저들 정보
  Future<List<UserModel>> fetchUserList() async {
    final List<UserModel> userList = await _authService.fetchUserList();

    return userList;
  }

  // 내 정보
  Future<void> _fetchMyUserData(String email) async {
    final UserModel? data = await _authService.fetchMyUserData(email);

    myUserData.value = data;
  }
}
