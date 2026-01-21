import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference get _profileDoc =>
      _db.collection('users').doc(userId).collection('profile').doc('main');

  Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _profileDoc.get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    await _profileDoc.set({
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'email': FirebaseAuth.instance.currentUser?.email,
    }, SetOptions(merge: true));
  }
}
