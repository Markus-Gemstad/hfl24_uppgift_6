import '../models/vehicle.dart';
import 'firebase_repository.dart';

class VehicleFirebaseRepository extends FirebaseRepository<Vehicle> {
  VehicleFirebaseRepository()
      : super(serializer: VehicleSerializer(), collectionId: 'vehicle');
}
