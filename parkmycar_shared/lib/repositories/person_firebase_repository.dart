import '../models/person.dart';
import 'firebase_repository.dart';

class PersonFirebaseRepository extends FirebaseRepository<Person> {
  PersonFirebaseRepository()
      : super(serializer: PersonSerializer(), collectionId: 'person');

  Future<Person?> getByAuthId(String authId) async {
    final snapshot = await fireStore
        .collection(collectionId)
        .where("authId", isEqualTo: authId)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final json = snapshot.docs.first.data();

    return serializer.fromJson(json);
  }
}
