import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/vehicles_bloc.dart';
import 'vehicle_edit_dialog.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  Future<bool?> showDeleteDialog(Vehicle item, BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ta bort ${item.regNr}?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Avbryt')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Ta bort')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BlocBuilder<VehiclesBloc, VehiclesState>(
          builder: (context, vehiclesState) {
        return switch (vehiclesState) {
          VehiclesInitial() => Center(child: CircularProgressIndicator()),
          VehiclesLoading() => Center(child: CircularProgressIndicator()),
          VehiclesLoaded(vehicles: final vehicles, pending: final pending) =>
            (vehicles.isEmpty)
                ? SizedBox.expand(
                    // Show if no vehicles in list
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Finns inga fordon.'),
                    ),
                  )
                : ListView.builder(
                    // Else show list
                    padding: const EdgeInsets.all(12.0),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      Vehicle item = vehicles[index];
                      bool isPending = item.id == pending?.id;
                      return ListTile(
                        enabled: !isPending,
                        leading: Icon(Icons.directions_car),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button per vehicle
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  Vehicle? vehicle = await showDialog<Vehicle>(
                                    context: context,
                                    builder: (context) =>
                                        VehicleEditDialog(vehicle: item),
                                  );

                                  debugPrint(vehicle.toString());

                                  if (vehicle != null &&
                                      vehicle.isValid() &&
                                      context.mounted) {
                                    String personId = context
                                        .read<AuthBloc>()
                                        .state
                                        .person!
                                        .id;
                                    context.read<VehiclesBloc>().add(
                                        UpdateVehicle(
                                            vehicle: vehicle,
                                            personId: personId));
                                  }
                                }),
                            // Delete button per vehicle
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  var delete =
                                      await showDeleteDialog(item, context);
                                  if (delete == true && context.mounted) {
                                    String personId = context
                                        .read<AuthBloc>()
                                        .state
                                        .person!
                                        .id;
                                    context.read<VehiclesBloc>().add(
                                        DeleteVehicle(
                                            vehicle: item, personId: personId));
                                  }
                                }),
                          ],
                        ),
                        title: Text(item.regNr),
                      );
                    },
                  ),
          VehiclesError(message: final message) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: $message'),
            ),
        };
      }),
      Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            // Add new vehicle button
            onPressed: () async {
              Vehicle? vehicle = await showDialog<Vehicle>(
                context: context,
                builder: (context) => VehicleEditDialog(),
              );

              debugPrint(vehicle.toString());

              if (vehicle != null && vehicle.isValid() && context.mounted) {
                String personId = context.read<AuthBloc>().state.person!.id;
                context
                    .read<VehiclesBloc>()
                    .add(CreateVehicle(vehicle: vehicle, personId: personId));
              }
            },
            child: Icon(Icons.add),
          )),
    ]);
  }
}
