import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../util/validators.dart';

class FinalizeRegistrationWidget extends StatelessWidget {
  FinalizeRegistrationWidget({
    super.key,
    required this.authId,
    required this.email,
  });

  final String authId;
  final String email;

  final TextEditingController _usernameController = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    bool pending =
        (authState.status == AuthStateStatus.authenticatedNoPersonPending);

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Var god avsluta din registrering:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 16,
              ),
              Form(
                key: _key,
                child: Center(
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      enabled: !pending,
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(), labelText: 'Namn'),
                      validator: (value) => Validators.isValidName(value)
                          ? null
                          : 'Ange ett giltigt namn.',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: pending
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
                        onPressed: () {
                          if (_key.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                AuthFinalizeRegistration(
                                    _usernameController.text, authId, email));
                          }
                        },
                        child: const Text('Spara och logga in'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
