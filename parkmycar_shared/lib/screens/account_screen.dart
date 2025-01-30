import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../parkmycar_shared.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen(
      {super.key,
      this.isEditMode = true,
      this.doPop = false,
      this.verticalAlign = MainAxisAlignment.center});

  final bool isEditMode;
  final bool doPop;
  final MainAxisAlignment verticalAlign;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;

  Future<bool> savePerson(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return false;

      _formKey.currentState!.save();

      try {
        if (widget.isEditMode) {
          // Update name of currently logged in person
          final authState = context.read<AuthBloc>().state;
          if (authState.status == AuthStateStatus.authenticated) {
            authState.person?.name = _name!; // Update name in state

            // Update name in person repo
            await PersonFirebaseRepository().update(authState.person!);

            // Update password in firebase authorization
            if (_password != null && _password != '') {
              await AuthRepository().changePassword(password: _password!);
              _password = null;
            }
          }
        } else {
          // Register new person in firebase authorization
          UserCredential userCred = await AuthRepository()
              .register(email: _email!, password: _password!);

          // Save new person in database
          await PersonFirebaseRepository()
              .create(Person(_name!, _email!, userCred.user!.uid));
        }

        String successMessage =
            (widget.isEditMode) ? 'Person uppdaterad!' : 'Person skapad!';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(successMessage)));

        return true; // Everything is okay
      } on SignUpWithEmailAndPasswordFailure catch (e) {
        debugPrint(e.toString());
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      } catch (e) {
        debugPrint(e.toString());
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              const SnackBar(content: Text('Person kunde inte sparas!')));
      }
    }
    return false; // Something went wrong
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    Person? currentPerson = authState.person;
    String title = (widget.isEditMode) ? 'Redigera konto' : 'Skapa konto';

    bool isGoogleUser = false;
    if (FirebaseAuth.instance.currentUser != null) {
      for (var e in FirebaseAuth.instance.currentUser!.providerData) {
        if (e.providerId == 'google.com') {
          isGoogleUser = true;
          break;
        }
      }
    }

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: widget.verticalAlign,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                TextFormField(
                  initialValue: currentPerson?.name,
                  validator: (value) => Validators.isValidName(value)
                      ? null
                      : 'Ange ett giltigt namn.',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  autofocus: true,
                  onSaved: (newValue) => _name = newValue,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Namn'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: currentPerson?.email,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) => Validators.isValidEmail(value)
                      ? null
                      : 'Ange en giltig e-postadress',
                  readOnly: widget.isEditMode,
                  onSaved: (newValue) => _email = newValue,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: (widget.isEditMode)
                          ? 'E-post (går inte att ändra)'
                          : 'E-post'),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: !isGoogleUser,
                  child: TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Lösenord',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) =>
                        Validators.isValidPassword(value, true)
                            ? null
                            : 'Ange ett giltigt lösenord (6-12 tecken)',
                    onSaved: (newValue) => _password = newValue,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: widget.doPop,
                      child: ElevatedButton(
                        child: const Text('Avbryt'),
                        onPressed: () {
                          if (widget.doPop) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    FilledButton(
                      child: const Text('Spara'),
                      onPressed: () async {
                        bool ok = await savePerson(context);
                        if (ok && widget.doPop) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.isEditMode,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text('Byt tema',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                            label: Text('Ljust'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                            label: Text('Mörkt'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: Icon(Icons.auto_mode),
                            label: Text('Auto'),
                          ),
                        ],
                        selected: <ThemeMode>{
                          // context.read<ThemeCubit>().state
                          Provider.of<ThemeCubit>(context).state
                        },
                        onSelectionChanged: (p0) {
                          // context.read<ThemeCubit>().changeThemeMode(p0.first);
                          Provider.of<ThemeCubit>(context, listen: false)
                              .changeThemeMode(p0.first);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
