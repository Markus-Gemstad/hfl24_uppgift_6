import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/identifiable.dart';
import '../models/serializer.dart';
import 'repository_interface.dart';

abstract class FirebaseRepository<T extends Identifiable>
    implements RepositoryInterface<T> {
  Serializer<T> serializer;
  final String collectionId;
  final fireStore = FirebaseFirestore.instance;

  FirebaseRepository({required this.serializer, required this.collectionId});

  @override
  Future<T?> create(T item) async {
    await fireStore
        .collection(collectionId)
        .doc(item.id)
        .set(serializer.toJson(item));
    return item;
  }

  /// Send item serialized as json over http to server
  @override
  Future<T?> update(T item) async {
    await fireStore
        .collection(collectionId)
        .doc(item.id)
        .set(serializer.toJson(item));
    return item;
  }

  @override
  Future<T?> getById(String id) async {
    final snapshot = await fireStore.collection(collectionId).doc(id).get();
    final json = snapshot.data();
    if (json == null) {
      throw Exception("Object with id $id not found.");
    }
    return serializer.fromJson(json);
  }

  /// Use compare to sort the list
  @override
  Future<List<T>> getAll(
      [String? orderByField, bool descending = false]) async {
    QuerySnapshot<Map<String, dynamic>> snapshots;
    if (orderByField != null) {
      snapshots = await fireStore
          .collection(collectionId)
          .orderBy(orderByField, descending: descending)
          .get();
    } else {
      snapshots = await fireStore.collection(collectionId).get();
    }
    final docs = snapshots.docs;
    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;
      return json;
    }).toList();

    return jsons.map((json) => serializer.fromJson(json)).toList();
  }

  @override
  Future<bool> delete(String id) async {
    await fireStore.collection(collectionId).doc(id).delete();
    return true;
  }
}
