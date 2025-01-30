import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../parkmycar_shared.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Är du säker på att du vill logga ut?'),
          ),
          FilledButton(
            onPressed: () async =>
                context.read<AuthBloc>().add(AuthLogoutRequested()),
            child: const Text('Logga ut'),
          ),
        ],
      ),
    );
  }
}
