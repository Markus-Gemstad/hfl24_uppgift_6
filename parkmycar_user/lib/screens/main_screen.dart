import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/active_parking_bloc.dart';
import '../blocs/parking_spaces_bloc.dart';
import '../blocs/parkings_bloc.dart';
import '../blocs/vehicles_bloc.dart';
import 'history_screen.dart';
import 'parking_screen.dart';
import 'vehicle_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ParkingScreen(),
      VehicleScreen(),
      HistoryScreen(),
      AccountScreen(),
      LogoutScreen(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          String personId = context.read<AuthBloc>().state.person!.id;
          return VehiclesBloc(repository: VehicleFirebaseRepository())
            ..add(LoadVehicles(personId: personId));
        }),
        BlocProvider(create: (context) {
          String personId = context.read<AuthBloc>().state.person!.id;
          return ParkingsBloc(
              repository: ParkingFirebaseRepository(),
              repositorySpace: ParkingSpaceFirebaseRepository())
            ..add(LoadParkings(personId: personId));
        }),
        BlocProvider(create: (context) {
          return ParkingSpacesBloc(repository: ParkingSpaceFirebaseRepository())
            ..add(LoadParkingSpaces());
        }),
        BlocProvider(
          create: (context) {
            String personId = context.read<AuthBloc>().state.person!.id;
            return ActiveParkingBloc(
                parkingRepository: ParkingFirebaseRepository())
              ..add(ActiveParkingInit(personId))
              ..add(ActiveParkingSubscriptionRequested(personId));
          },
        ),
      ],
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentScreenIndex = index;
            });
          },
          selectedIndex: _currentScreenIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.local_parking, color: Colors.blue),
              label: 'Parkera',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car_filled),
              label: 'Fordon',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Historik',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Konto',
            ),
            NavigationDestination(
              icon: Icon(Icons.logout),
              label: 'Logga ut',
            ),
          ],
        ),
        body: SafeArea(
          // child: screens[_currentScreenIndex],
          child: IndexedStack(
            key: const GlobalObjectKey('IndexedStack'),
            index: _currentScreenIndex,
            children: screens,
          ),
        ),
      ),
    );
  }
}
