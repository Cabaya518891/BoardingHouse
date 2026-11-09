import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreFunction {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> readFromCollection() {
    return _firestore.collection('notes').snapshots();
  }

  Future<void> addNoteToCollection(Map<String, dynamic> data) async {
    await _firestore.collection('notes').add(data);
  }

  Future<void> updateNoteInCollection(String id, Map<String, dynamic> data) async {
    await _firestore.collection('notes').doc(id).update(data);
  }

  Future<void> deleteNoteFromCollection(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}