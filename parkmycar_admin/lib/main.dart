import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:parkmycar_admin/firebase_options.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
              authRepository: AuthRepository(),
              personRepository: PersonFirebaseRepository())
            ..add(AuthUserSubscriptionRequested()),
        ),
        BlocProvider(
          create: (BuildContext context) => ThemeCubit(),
        ),
      ],
      child: ParkMyCarAdminApp(),
    ),
  );
}

class ParkMyCarAdminApp extends StatelessWidget {
  const ParkMyCarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkMyCar ADMIN',
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeCubit>().state,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Color.fromRGBO(242, 85, 85, 1),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Color.fromRGBO(242, 85, 85, 1),
      ),
      home: const AuthViewSwitcher(), //MainScreen(),
    );
  }
}

class AuthViewSwitcher extends StatelessWidget {
  const AuthViewSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (authState.status) {
        AuthStateStatus.initial => SizedBox.shrink(),
        AuthStateStatus.authenticated => const MainScreen(), // When logged in
        AuthStateStatus.authenticatedNoPersonPending ||
        AuthStateStatus.authenticatedNoPerson =>
          FinalizeRegistrationWidget(
              authId: authState.authId!, email: authState.email!),
        _ => const LoginScreen(title: 'ParkMyCar ADMIN'), // For all other cases
      },
    );
  }
}
