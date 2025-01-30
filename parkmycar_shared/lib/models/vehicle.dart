import '../util/validators.dart';
import 'identifiable.dart';
import 'serializer.dart';

enum VehicleType { unknown, car, motorcycle, truck }

class Vehicle extends Identifiable {
  String regNr;
  String personId;
  VehicleType type;

  Vehicle(this.regNr, this.personId,
      [this.type = VehicleType.unknown, String? id])
      : super(id);

  static bool isValidVehicleTypeValue(String? value) {
    // Valid value = 1, 2, 3
    if (value != null && RegExp(r'^[1-3]{1}$').hasMatch(value)) {
      return true;
    }
    return false;
  }

  @override
  bool isValid() {
    return Validators.isValidRegNr(regNr) &&
        Validators.isValidId(personId.toString());
  }

  @override
  String toString() {
    return "Id: $id, RegNr: $regNr, Fordonstyp: $type, Ägare (ID): $personId";
  }
}

class VehicleSerializer extends Serializer<Vehicle> {
  @override
  Map<String, dynamic> toJson(Vehicle item) {
    return {
      'id': item.id,
      'regNr': item.regNr,
      'type': item.type.index,
      'personId': item.personId,
    };
  }

  @override
  Vehicle fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['regNr'] as String,
      json['personId'] as String,
      VehicleType.values[json['type']],
      json['id'] as String,
    );
  }
}
