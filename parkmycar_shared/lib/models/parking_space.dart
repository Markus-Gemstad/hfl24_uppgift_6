import '../util/validators.dart';
import 'identifiable.dart';
import 'serializer.dart';

class ParkingSpace extends Identifiable {
  String streetAddress;
  String postalCode;
  String city;
  int pricePerHour;

  ParkingSpace(
      this.streetAddress, this.postalCode, this.city, this.pricePerHour,
      [String? id])
      : super(id);

  @override
  bool isValid() {
    return (Validators.isValidStreetAddress(streetAddress) &&
        Validators.isValidPostalCode(postalCode) &&
        Validators.isValidCity(city) &&
        Validators.isValidPricePerHour(pricePerHour.toString()));
  }

  @override
  String toString() {
    return "Id: $id, Gatuadress: $streetAddress, Postnr: $postalCode, Ort: $city, Pris per timme: $pricePerHour";
  }
}

class ParkingSpaceSerializer extends Serializer<ParkingSpace> {
  @override
  Map<String, dynamic> toJson(ParkingSpace item) {
    return {
      'id': item.id,
      'streetAddress': item.streetAddress,
      'postalCode': item.postalCode,
      'city': item.city,
      'pricePerHour': item.pricePerHour,
    };
  }

  @override
  ParkingSpace fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      json['streetAddress'] as String,
      json['postalCode'] as String,
      json['city'] as String,
      json['pricePerHour'] as int,
      json['id'] as String,
    );
  }
}
