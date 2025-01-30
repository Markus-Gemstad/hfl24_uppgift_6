import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/parking_spaces_bloc.dart';
import 'parking_space_screen.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentScreenIndex = 0;

  final destinations = const <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.local_parking),
      label: 'Parkeringar',
    ),
    NavigationDestination(
      icon: Icon(Icons.query_stats),
      label: 'Statistik',
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
  ];

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ParkingSpaceScreen(),
      StatisticsScreen(),
      AccountScreen(
        verticalAlign: MainAxisAlignment.start,
      ),
      LogoutScreen(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return ParkingSpacesBloc(repository: ParkingSpaceFirebaseRepository())
            ..add(LoadParkingSpaces());
        }),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Show bottom menu if width less than 600
          if (constraints.maxWidth < 600) {
            return Scaffold(
              bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (int index) {
                    setState(() {
                      _currentScreenIndex = index;
                    });
                  },
                  selectedIndex: _currentScreenIndex,
                  destinations: destinations),
              body: SafeArea(
                // child: screens[_currentScreenIndex],
                child: IndexedStack(
                  key: const GlobalObjectKey('IndexedStack'),
                  index: _currentScreenIndex,
                  children: screens,
                ),
              ),
            );
          } else {
            // Show left menu if width is 600 or more
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                      extended: constraints.maxWidth >= 800,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _currentScreenIndex = index;
                        });
                      },
                      destinations: destinations
                          .map(NavigationRailDestinationFactory
                              .fromNavigationDestination)
                          .toList(),
                      selectedIndex: _currentScreenIndex),
                  Expanded(
                    // child: screens[_currentScreenIndex],
                    child: IndexedStack(
                      key: const GlobalObjectKey('IndexedStack'),
                      index: _currentScreenIndex,
                      children: screens,
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class NavigationRailDestinationFactory {
  static NavigationRailDestination fromNavigationDestination(
    NavigationDestination destination,
  ) {
    return NavigationRailDestination(
      icon: destination.icon,
      selectedIcon: destination.selectedIcon,
      label: Text(destination.label),
    );
  }
}
