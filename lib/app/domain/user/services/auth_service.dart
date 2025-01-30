import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subject/app/domain/user/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fb = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // 이메일과 비밀번호로 로그인
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 회원가입
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _createUser(email, password);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // 회원 DB 등록
  Future<void> _createUser(email, password) async {
    try {
      String uid = await firebaseAuthCreateUser(email, password);

      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        name: 'shin',
        registerDate: Timestamp.now(),
        modifiedDate: Timestamp.now(),
      );

      await _fb
          .collection('members')
          .doc(userModel.email)
          .set(userModel.toJson());
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
          failMsg = '이메일을 인증하여 주세요. 메일 주소로 인증 메일을 보내 드렸습니다.';
          break;
        case 'weak-password':
          failMsg = '암호가 너무 단순 합니다.';
          break;
      }
      throw Exception(failMsg);
    }
  }

  Future<String> firebaseAuthCreateUser(String email, String password) async {
    // firebase auth 등록
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return userCredential.user!.uid;
  }

  // 등록된 멤버리스트
  Future<List<UserModel>> fetchMemberList() async {
    QuerySnapshot<Map<String, dynamic>> memberSnapshot =
        await _fb.collection('members').get();

    if (memberSnapshot.docs.isEmpty) return [];

    return memberSnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}
