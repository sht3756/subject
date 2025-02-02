import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subject/app/domain/user/models/user_model.dart';
import '../services/auth_service.dart';
import 'package:logger/logger.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  Rxn<UserModel> myUserData = Rxn<UserModel>();
  final AuthService _authService = AuthService();
  Rx<User?> firebaseUser = Rx<User?>(null);
  final Logger logger = Logger();

  @override
  void onInit() {
    super.onInit();
    logger.i("AuthController 초기화");
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
    logger.d("getInitialRoute : ${user != null}");
    return user != null ? '/' : '/sign_in';
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      logger.i("[SUCCESS] signOut");
    }catch(e){
      logger.e("[Error] signOut $e");
    }

  }

  // 로그인
  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      logger.i("[SUCCESS] signIn $email");
    } catch (e) {
      logger.e("[Error] signIn : $email, $e");
    }
  }

  // 회원가입
  Future<bool> register(String email, String password, String name) async {
    try {
      final User? user = await _authService.createUserWithEmailAndPassword(
          email, password, name);

      if (user != null) {
        logger.i("[SUCCESS] register $email");
        return true;
      } else {
        logger.i("[Fail] register $email");
        return false;
      }
    } catch(e) {
      logger.e("[Error] register : $e");
      return false;
    }

  }

  // 유저들 정보
  Future<List<UserModel>> fetchUserList() async {
    try {
      List<UserModel> userList = await _authService.fetchUserList();
      logger.i("[SUCCESS] fetchUserList");
      return userList;
    } catch (e) {
      logger.e("[Error] _fetchMyUserData : $e");
      return [];
    }
  }

  // 내 정보
  Future<void> _fetchMyUserData(String email) async {
    try {
      final UserModel? data = await _authService.fetchMyUserData(email);

      myUserData.value = data;
      logger.i("[SUCCESS] _fetchMyUserData : $email");
    } catch (e) {
      Get.snackbar('Error', '마이 데이터 가져오기 실패 ㅠㅠ');
      logger.e("[Error] _fetchMyUserData : $e");
    }
  }
}
