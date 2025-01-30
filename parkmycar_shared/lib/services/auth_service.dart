
// enum AuthStatus {
//   unauthenticated,
//   authenticating,
//   authenticated,
// }

// /// Whether a parking is ongoing.
// bool isOngoingParking = false;

// /// The current ongoing parking (if any)
// Parking? ongoingParking;

// class AuthService extends ChangeNotifier {
//   AuthStatus _status = AuthStatus.unauthenticated;
//   AuthStatus get status => _status;

//   Person? currentPerson;

//   Future<AuthStatus> login(String email, {bool admin = false}) async {
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       List<Person> all = await PersonHttpRepository.instance.getAll();
//       var filtered = all.where((e) => e.email == email);
//       if (filtered.isNotEmpty) {
//         currentPerson = filtered.first;
//         // if (!admin) {
//         await loadOngoingParking();
//         // debugPrint('loadOngoingParking');
//         // }
//         _status = AuthStatus.authenticated;
//       } else {
//         _status = AuthStatus.unauthenticated;
//       }
//     } catch (e) {
//       _status = AuthStatus.unauthenticated;
//     }
//     notifyListeners();
//     return _status;
//   }

//   void logout() {
//     currentPerson = null;
//     ongoingParking = null;
//     isOngoingParking = false;

//     _status = AuthStatus.unauthenticated;
//     notifyListeners();
//   }

//   Future<void> loadOngoingParking() async {
//     // if (isOngoingParking) return;
//     var items = await ParkingHttpRepository.instance.getAll();

//     // if (!mounted) return;
//     // var currentPerson = context.read<AuthService>().currentPerson;

//     // TODO Ersätt med bättre relationer mellan Parking och Person
//     items = items
//         .where((element) =>
//             element.isOngoing && element.personId == currentPerson!.id)
//         .toList();

//     debugPrint('loadOngoingParking() items:$items');
//     if (items.isNotEmpty) {
//       items[0].parkingSpace = await ParkingSpaceHttpRepository.instance
//           .getById(items[0].parkingSpaceId);
//       ongoingParking = items[0];
//       isOngoingParking = true;
//     }
//     debugPrint('loadOngoingParking() isOngoingParking:$isOngoingParking');
//   }
// }
