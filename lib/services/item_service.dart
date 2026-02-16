import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getItems() {
    return _db
        .collection("items")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> addItem(Map<String, dynamic> data) {
    return _db.collection("items").add(data);
  }

  Future<void> markResolved(String docId) {
    return _db.collection("items").doc(docId).update({
      "status": "RESOLVED",
    });
  }

  Future<void> updateItem(String docId, Map<String, dynamic> data) {
    return _db.collection("items").doc(docId).update(data);
  }

  Future<void> deleteItem(String docId) {
    return _db.collection("items").doc(docId).delete();
  }
}
