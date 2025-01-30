import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../util/validators.dart';
import 'identifiable.dart';
import 'parking_space.dart';
import 'serializer.dart';

class Parking extends Identifiable {
  String personId;
  String vehicleId;
  String parkingSpaceId;
  int pricePerHour;

  DateTime startTime;
  DateTime endTime;

  // Can be set when loading parking spaces from the side.
  // Otherwise use the parkingSpaceId.
  ParkingSpace? parkingSpace;

  /// Get price per minute
  double get pricePerMinute => pricePerHour / 60;

  /// Get price per second
  double get pricePerSecond => pricePerHour / 3600;

  Duration get totalTime {
    return endTime.difference(startTime);
  }

  /// Get total cost of this parking
  double get totalCost {
    double result = pricePerSecond * totalTime.inSeconds;
    return double.parse(result.toStringAsFixed(2));
  }

  String totalTimeToString([bool short = false]) {
    return timeToString(startTime, endTime, short);
  }

  String elapsedTimeToString([bool short = false]) {
    return timeToString(startTime, DateTime.now(), short);
  }

  static timeToString(DateTime startTime, DateTime endTime,
      [bool short = false]) {
    Duration elapsedTime = endTime.difference(startTime);

    int days = elapsedTime.inDays;
    int hours = elapsedTime.inHours % 24;
    int minutes = elapsedTime.inMinutes % 60;
    int seconds = elapsedTime.inSeconds % 60;

    String elapsedString = '';

    if (days > 0) {
      if (days == 1) {
        elapsedString = (short) ? '${days}d ' : '$days dag ';
      } else {
        elapsedString = (short) ? '${days}d ' : '$days dagar ';
      }
    }
    if (hours > 0) {
      elapsedString += (short) ? '${hours}t ' : '$hours tim ';
    }
    if (minutes > 0) {
      elapsedString += (short) ? '${minutes}m ' : '$minutes min ';
    }
    elapsedString += (short) ? '${seconds}s' : '$seconds sek';

    return elapsedString;
  }

  /// Get elapsed cost of this parking
  String elapsedCostToString() {
    var now = DateTime.now();
    Duration elapsedTime = now.difference(startTime);
    double result = pricePerSecond * elapsedTime.inSeconds;
    return '${result.toStringAsFixed(2)} kr';
  }

  bool get isOngoing {
    var now = DateTime.now();
    return (now.isAfter(startTime) && now.isBefore(endTime));
  }

  bool get isOverdue {
    var now = DateTime.now();
    return (now.isAfter(endTime));
  }

  Parking(this.personId, this.vehicleId, this.parkingSpaceId, this.startTime,
      this.endTime, this.pricePerHour,
      [String? id])
      : super(id);

  @override
  bool isValid() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return Validators.isValidId(personId.toString()) &&
        Validators.isValidId(vehicleId.toString()) &&
        Validators.isValidId(parkingSpaceId.toString()) &&
        Validators.isValidDateTime(formatter.format(startTime)) &&
        Validators.isValidDateTime(formatter.format(endTime));
  }

  @override
  String toString() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return 'Id: $id, Starttid: ${formatter.format(startTime)}, Sluttid: ${formatter.format(endTime)}, '
        'Pris per timme: $pricePerHour, FordonsId: $vehicleId, ParkeringsplatsId: $parkingSpaceId, '
        'PersonId: $personId';
  }
}

class ParkingSerializer extends Serializer<Parking> {
  @override
  Map<String, dynamic> toJson(Parking item) {
    return {
      'id': item.id,
      'personId': item.personId,
      'vehicleId': item.vehicleId,
      'parkingSpaceId': item.parkingSpaceId,
      'startTime': Timestamp.fromDate(item.startTime),
      'endTime': Timestamp.fromDate(item.endTime),
      'pricePerHour': item.pricePerHour,
    };
  }

  @override
  Parking fromJson(Map<String, dynamic> json) {
    return Parking(
      json['personId'] as String,
      json['vehicleId'] as String,
      json['parkingSpaceId'] as String,
      (json['startTime'] as Timestamp).toDate(),
      (json['endTime'] as Timestamp).toDate(),
      json['pricePerHour'] as int,
      json['id'] as String,
    );
  }
}
