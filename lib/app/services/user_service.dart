import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'users';

  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('username')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).add(user.toMap());
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> toggleStatus(String userId, bool currentStatus) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update({'isActive': !currentStatus});
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
