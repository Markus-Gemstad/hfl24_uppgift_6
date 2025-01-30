import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/blocs/parkings_bloc.dart';

import '../globals.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        String personId = context.read<AuthBloc>().state.person!.id;
        context.read<ParkingsBloc>().add(ReloadParkings(personId: personId));
        await context
            .read<ParkingsBloc>()
            .stream
            .firstWhere((state) => state is ParkingsLoaded);
      },
      child: BlocBuilder<ParkingsBloc, ParkingsState>(
        builder: (context, parkingsState) {
          return switch (parkingsState) {
            ParkingsInitial() => Center(child: CircularProgressIndicator()),
            ParkingsLoading() => Center(child: CircularProgressIndicator()),
            ParkingsLoaded(parkings: final parkings) => (parkings.isEmpty)
                ? SizedBox.expand(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Finns ingen historik.'),
                          SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: () {
                                String personId =
                                    context.read<AuthBloc>().state.person!.id;
                                context
                                    .read<ParkingsBloc>()
                                    .add(LoadParkings(personId: personId));
                              },
                              child: Text('Uppdatera'))
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: parkings.length,
                    itemBuilder: (context, index) {
                      var item = parkings[index];
                      return ListTile(
                          leading:
                              Icon(Icons.local_parking, color: Colors.blue),
                          subtitle: Text('${item.parkingSpace!.streetAddress}, '
                              '${item.parkingSpace!.postalCode} ${item.parkingSpace!.city}\n'
                              'Tid: ${dateTimeFormatShort.format(item.startTime)} - '
                              '${dateTimeFormatShort.format(item.endTime)}\n'
                              'Pris: ${item.totalCost} kr (${item.totalTimeToString(true)})'));
                    },
                  ),
            ParkingsError(message: final message) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $message'),
              ),
          };
        },
      ),
    );
  }
}
