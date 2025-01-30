import '../models/parking_space.dart';
import 'firebase_repository.dart';

class ParkingSpaceFirebaseRepository extends FirebaseRepository<ParkingSpace> {
  ParkingSpaceFirebaseRepository()
      : super(
            serializer: ParkingSpaceSerializer(),
            collectionId: 'parking_space');
}
