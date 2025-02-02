# subject

## 설치 및 실행 방법
- 프로젝트 클론
```bash
git clone https://github.com/sht3756/subject.git
```
- .env파일에 API 중요 문서 복사후 붙여넣기

- 프로젝트 실행
```bash
flutter pub get
flutter run 
```

## 기술
- Flutter(Web),  Cloud FireStore(서버)  

## 패키지
```bash
  get: ^4.6.6
  flutter_dotenv: ^5.2.1
  firebase_core: ^3.10.1
  firebase_auth: ^5.4.1
  firebase_storage: ^12.4.1
  cloud_firestore: ^5.6.2
  logger: ^2.5.0
```

## 폴더구조 및 설명

``` bash
📂 lib/
│   📄 main.dart
│   📄 firebase_options.dart
│
├── 📂 core/
│   ├── 📂 utils/               # 유틸리티 및 공통 기능
│   │   ├── 📄 firebase_config.dart # Firebase 환경 설정
│   │   ├── 📄 drag_anchor.dart    # 드래그 앵커 관련 코드
│   │
│   ├── 📂 bindings/             # GetX 바인딩 파일
│   │   ├── 📄 auth_binding.dart   # Auth 인증 관련 바인딩
│   │   ├── 📄 to_do_binding.dart  # TODO 관리 관련 바인딩
│   │
│   ├── 📂 routes/               # 라우팅 관련 코드
│   │   ├── 📄 app_route.dart      # 앱 내 라우트 정의
│
├── 📂 app/
│   ├── 📂 domain/               # 비즈니스 로직 및 데이터 계층
│   │   ├── 📂 user/              # 사용자 관련 도메인
│   │   │   ├── 📂 models/        # 사용자 모델
│   │   │   │   ├── 📄 user_model.dart
│   │   │   ├── 📂 controller/    # 사용자 auth 인증 컨트롤러
│   │   │   │   ├── 📄 auth_controller.dart
│   │   │   ├── 📂 views/         # 사용자 관련 화면
│   │   │   │   ├── 📄 sign_in_screen.dart
│   │   │   ├── 📂 services/      # 사용자 관련 서비스
│   │   │   │   ├── 📄 auth_service.dart
│   │
│   │   ├── 📂 todo/              # TODO 관련 도메인
│   │   │   ├── 📂 models/        # TODO 모델
│   │   │   │   ├── 📄 to_do_model.dart
│   │   │   ├── 📂 controller/    # TODO 컨트롤러
│   │   │   │   ├── 📄 to_do_controller.dart
│   │   │   ├── 📂 views/         # TODO 관련 화면
│   │   │   │   ├── 📄 to_do_screen.dart
│   │   │   │   ├── 📂 widgets/   # TODO 화면에 사용될 위젯들
│   │   │   │   │   ├── 📄 confirm_modal.dart  # confirm 삭제 모달
│   │   │   │   │   ├── 📄 to_do_column.dart   # 공통 컬럼 모달
│   │   │   │   │   ├── 📄 add_to_do_button.dart  # 공통 추가 버튼
│   │   │   │   │   ├── 📄 to_do_card.dart  # 공통 TODO 카드 
│   │   │   ├── 📂 services/      # TODO 관련 서비스
│   │   │   │   ├── 📄 to_do_service.dart
│   │
│   │   ├── 📂 common/            # 공통적으로 사용되는 UI 요소
│   │   │   ├── 📄 modal_screen.dart  # 모달 스크린

```
## 스크린샷

### Web
| 화면 | 이미지 |
|------|--------|
| 로그인 | <img width="1510" alt="Image" src="https://github.com/user-attachments/assets/1e9130a0-d075-48c7-8c66-2eb831644e59" />|
| 회원가입 |<img width="1510" alt="Image" src="https://github.com/user-attachments/assets/c2ce26e8-2b1a-4c9e-bdfc-97f66fe6c083" />|
| 컨펌모달 | <img width="1510" alt="Image" src="https://github.com/user-attachments/assets/b753050a-3351-41a9-893c-49aee828411f" />|
| 생성모달 | <img width="1510" alt="Image" src="https://github.com/user-attachments/assets/5d753299-66cc-4cdd-9f57-74687f878c86" />|
| 디테일 모달 | <img width="1510" alt="Image" src="https://github.com/user-attachments/assets/b982ad73-7d0e-4741-a384-3adfcff0d859" />|
| 리스트 |<img width="1510" alt="Image" src="https://github.com/user-attachments/assets/1947feec-9a6e-473c-8120-5712a31ec155" />|
| 수정 모달 |<img width="1510" alt="Image" src="https://github.com/user-attachments/assets/a90dadb4-ca4c-4f87-8893-5fcfb5b05c13" />|

---







