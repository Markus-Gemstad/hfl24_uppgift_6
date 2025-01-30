import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../parkmycar_shared.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthBloc>().state.status;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final bool isLoading = (authStatus == AuthStateStatus.authenticating);

    final formKey = GlobalKey<FormState>();
    final usernameFocus = FocusNode();
    final passwordFocus = FocusNode();

    String? email;
    String? password;

    saveAndLogin() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        context.read<AuthBloc>().add(AuthLoginRequested(email!, password!));
      }
    }

    return Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, AuthState state) {
        if (state.status == AuthStateStatus.unauthenticated) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Fel vid inloggning')));
        }
      },
      child: Center(
        child: Form(
          key: formKey,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                //Text(authStatus.toString()),
                const SizedBox(height: 32),
                TextFormField(
                  focusNode: usernameFocus,
                  autofocus: true,
                  initialValue: 'test@testson.se',
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'E-postadress',
                    prefixIcon: Icon(Icons.person),
                  ),
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) => Validators.isValidEmail(value)
                      ? null
                      : 'Ange en giltig e-postadress',
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  onSaved: (newValue) => email = newValue,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: passwordFocus,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Lösenord',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) => Validators.isValidPassword(value)
                      ? null
                      : 'Ange ett giltigt lösenord (6-12 tecken)',
                  onFieldSubmitted: (_) => saveAndLogin(),
                  onSaved: (newValue) => password = newValue,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isLoading
                      ? FilledButton(
                          onPressed: () {},
                          child: const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : FilledButton(
                          onPressed: saveAndLogin,
                          child: const Text('Logga in'),
                        ),
                ),
                const SizedBox(height: 32),
                IconButton(
                  onPressed: () => AuthRepository().signInWithGoogle(),
                  padding: const EdgeInsets.all(0.0),
                  icon: Image.asset(
                    'assets/signinwith_google_light.png',
                    height: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Eller saknar du konto?'),
                TextButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AccountScreen(
                                isEditMode: false,
                                doPop: true,
                              )));
                    },
                    child: const Text('Skapa nytt konto')),
                Visibility(
                  visible: kDebugMode,
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () async => createBaseData(),
                          child: const Text('DEBUG: Fyll på med basdata')),
                      TextButton(
                          onPressed: () async => createParkingSpaces(),
                          child: const Text(
                              'DEBUG: Fyll på med parkeringsplatser')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

Future<void> createBaseData() async {
  Person? person = await PersonFirebaseRepository()
      .create(Person("Test Testson", "test@testson.se", ''));

  final vehicleRepo = VehicleFirebaseRepository();
  await vehicleRepo.create(Vehicle("ABC123", person!.id, VehicleType.car));
  await vehicleRepo
      .create(Vehicle("BCD234", person.id, VehicleType.motorcycle));
}

Future<void> createParkingSpaces() async {
  var parkingSpaceRepo = ParkingSpaceFirebaseRepository();
  await parkingSpaceRepo
      .create(ParkingSpace('Nya Stadens Torg 1', '531 31', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Gamla Stadens Torg 4', '531 32', 'Lidköping', 15));
  await parkingSpaceRepo
      .create(ParkingSpace('Esplanaden 6', '531 33', 'Lidköping', 35));
  await parkingSpaceRepo
      .create(ParkingSpace('Rådagatan 10', '531 35', 'Lidköping', 50));
  await parkingSpaceRepo
      .create(ParkingSpace('Östbygatan 18', '531 37', 'Lidköping', 25));
  await parkingSpaceRepo
      .create(ParkingSpace('Stenportsgatan 9', '531 40', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Kållandsgatan 22', '531 44', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Skaragatan 5', '531 30', 'Lidköping', 50));
  await parkingSpaceRepo
      .create(ParkingSpace('Sockerbruksgatan 15', '531 40', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Mariestadsvägen 2', '531 60', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Torggatan 3', '531 31', 'Lidköping', 10));
  await parkingSpaceRepo
      .create(ParkingSpace('Hamngatan 12', '531 32', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Västra Hamngatan 5', '531 33', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Framnäsvägen 1', '531 36', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Götgatan 7', '531 31', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Östra Hamnen 10', '531 32', 'Lidköping', 10));
  await parkingSpaceRepo
      .create(ParkingSpace('Viktoriagatan 14', '531 30', 'Lidköping', 30));
  await parkingSpaceRepo
      .create(ParkingSpace('Majorsallén 3', '531 40', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Hovbygatan 20', '531 41', 'Lidköping', 15));
  await parkingSpaceRepo
      .create(ParkingSpace('Kvarngatan 9', '531 42', 'Lidköping', 45));
}
