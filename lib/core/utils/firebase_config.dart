import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static FirebaseOptions get options {
    return FirebaseOptions(
      apiKey:  dotenv.env['API_KEY']!,
      appId: dotenv.env['APP_ID']!,
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['PROJECT_ID']!,
      authDomain: dotenv.env['AUTH_DOMAIN']!,
      storageBucket: dotenv.env['STORAGE_BUCKET']!,
      measurementId: dotenv.env['MEASUREMENT_ID']!,
    );
  }
}