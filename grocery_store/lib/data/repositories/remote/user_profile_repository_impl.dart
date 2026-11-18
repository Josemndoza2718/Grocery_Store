import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/domain/repositories/remote/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<UserProfile> getProfile(String uid) async {
    final data = (await _user(uid).get()).data() ?? const {};
    return UserProfile(lastStoreId: data['lastStoreId'] as String?);
  }

  @override
  Future<void> setLastStoreId(String uid, String storeId) {
    // merge: creates the profile if it does not exist (e.g. users created
    // from the Firebase console) without touching the other fields.
    return _user(uid).set({'lastStoreId': storeId}, SetOptions(merge: true));
  }
}
