import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subject/app/domain/user/models/user_model.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fb = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  final Logger logger = Logger();

  // 이메일과 비밀번호로 로그인
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      logger.i("[SUCCESS-Service] signInWithEmailAndPassword: $email");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String failMsg = "";

      switch (e.code) {
        case 'invalid-credential':
          failMsg = '이메일과 비밀번호를 확인해주세요.';
          break;
        case 'invalid-email':
          failMsg = '유효하지 않은 이메일입니다.';
          break;
        case 'user-not-found':
          failMsg = '사용자를 찾을 수 없습니다';
          break;
        case 'wrong-password':
          failMsg = '비밀번호를 확인해 주세요';
          break;
        case 'too-many-requests':
          failMsg = '반복적인 요청으로 잠시 후 다시 시도해 주세요';
          break;
        default:
          failMsg = '알 수 없는 요청입니다.';
          break;
      }

      logger.e("[Error-Service] signInWithEmailAndPassword: $email $e");
      throw Exception(failMsg);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      logger.i("[SUCCESS-Service] signOut");
    } catch (e) {
      logger.e("[Error-Service] signOut: $e");
    }
  }

  // 회원가입
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _createUser(email, password, userCredential, name);
      logger.i("[SUCCESS-Service] createUserWithEmailAndPassword : $email");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String failMsg = "";

      switch (e.code) {
        case 'email-already-in-use':
          failMsg = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          failMsg = '유효하지 않은 이메일입니다.';
          break;
        case 'operation-not-allowed':
          failMsg = '사용이 중지된 이메일입니다.';
          break;
        case 'weak-password':
          failMsg = '암호가 너무 단순 합니다.';
          break;
        default:
          failMsg = 'e ${e.code}';
          break;
      }
      logger.e("[Error-Service] createUserWithEmailAndPassword: $email $e");
      throw Exception(failMsg);
    }
  }

  // 회원 DB 등록
  Future<void> _createUser(String email, String password,
      UserCredential userCredential, String name) async {
    try {
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        registerDate: Timestamp.now(),
        modifiedDate: Timestamp.now(),
      );

      await _fb
          .collection('users')
          .doc(userModel.email)
          .set(userModel.toJson());

      logger.i("[SUCCESS-Service] createUserWithEmailAndPassword : $email");
    } catch (e) {
      logger.e("[Error-Service] _createUser: $email $e");
    }
  }

  // 등록된 멤버리스트
  Future<List<UserModel>> fetchUserList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userDocumentSnapshot =
          await _fb.collection('users').get();

      if (userDocumentSnapshot.docs.isEmpty) return [];
      logger.i("[SUCCESS-Service] fetchUserList");

      return userDocumentSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      logger.e("[Error-Service] fetchUserList: $e");
      return [];
    }
  }

  // 내 정보
  Future<UserModel?> fetchMyUserData(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userDocumentSnapshot =
          await _fb.collection('users').where('email', isEqualTo: email).get();

      if (userDocumentSnapshot.docs.isEmpty) return null;
      logger.i("[SUCCESS-Service] fetchMyUserData $email");

      return UserModel.fromJson(userDocumentSnapshot.docs.first.data());
    } catch (e) {
      logger.e("[Error-Service] fetchMyUserData: $email $e");
      return null;
    }
  }
}
