import 'package:firebase_core/firebase_core.dart';

// ============================================================
//  إعدادات Firebase  (الخطوة الوحيدة المطلوبة عشان يشتغل أونلاين)
// ============================================================
//  1) من Firebase Console: Project settings > Your apps > Web app (</>)
//  2) انسخي القيم من firebaseConfig وحطيها هنا مكان كلمة PASTE
//  3) لو سبتيها زي ما هي، التطبيق بيشتغل في "وضع تجريبي" على الجهاز بس
// ============================================================

const String kFirebaseApiKey = 'PASTE_YOUR_WEB_API_KEY';
const String kFirebaseAuthDomain = 'pharma-sales-60f42.firebaseapp.com';
const String kFirebaseProjectId = 'pharma-sales-60f42';
const String kFirebaseStorageBucket = 'pharma-sales-60f42.firebasestorage.app';
const String kFirebaseMessagingSenderId = '803944874540';
const String kFirebaseAppId = '1:803944874540:web:3a2740fe0c37e8c1080789';

/// الإيميلات اللي بتتسجل كـ "أدمن" (رئيس المبيعات). أي حد غيرهم بيتسجل مندوب.
/// لازم نفس القايمة تتحط في ملف firestore.rules كمان.
const List<String> kAdminEmails = ['selenasameh31@gmail.com'];

/// بتبقى true لما تحطي إعدادات Firebase الحقيقية.
bool get kFirebaseConfigured => !kFirebaseApiKey.startsWith('PASTE');

FirebaseOptions get firebaseWebOptions => const FirebaseOptions(
      apiKey: kFirebaseApiKey,
      authDomain: kFirebaseAuthDomain,
      projectId: kFirebaseProjectId,
      storageBucket: kFirebaseStorageBucket,
      messagingSenderId: kFirebaseMessagingSenderId,
      appId: kFirebaseAppId,
    );
