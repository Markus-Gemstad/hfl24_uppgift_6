import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/globals.dart';
import 'package:provider/provider.dart';

class ParkingStartDialog extends StatefulWidget {
  const ParkingStartDialog(this.parkingSpace, {super.key});

  final ParkingSpace parkingSpace;

  @override
  State<ParkingStartDialog> createState() => _ParkingStartDialogState();
}

class _ParkingStartDialogState extends State<ParkingStartDialog> {
  late ParkingSpace parkingSpace;
  late String _selectedVehicleId;
  DateTime _selectedEndTime = DateTime.now().add(suggestedParkingEndTime);

  Future<List<Vehicle>> getAllVehicles() async {
    final repo = VehicleFirebaseRepository();
    var items = await repo.getAll('regNr');

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      Person? currentPerson = context.read<AuthBloc>().state.person;

      // TODO Ersätt med bättre relationer mellan Vehicle och Person
      items = items
          .where((element) => element.personId == currentPerson!.id)
          .toList();
    } else {
      items = List.empty();
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    parkingSpace = widget.parkingSpace;
  }

  @override
  Widget build(BuildContext context) {
    Person? currentPerson = context.read<AuthBloc>().state.person;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Starta parkering'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ListTile(
                leading: Hero(
                    tag: 'parkingicon${parkingSpace.id}',
                    transitionOnUserGestures: true,
                    child: Image.asset(
                      'assets/parking_icon.png',
                      width: 60.0,
                    )),
                title: Text(parkingSpace.streetAddress),
                subtitle:
                    Text('${parkingSpace.postalCode} ${parkingSpace.city}\n'
                        'Pris per timme: ${parkingSpace.pricePerHour} kr'),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeOnlyFormat.format(_selectedEndTime),
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: Text('Välj sluttid', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      final TimeOfDay? timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (timeOfDay != null) {
                        setState(() {
                          _selectedEndTime = timeOfDayToDateTime(timeOfDay,
                              dateTime: _selectedEndTime);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateFormat.format(_selectedEndTime),
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child:
                        Text('Välj slutdatum', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      final DateTime? dateTime = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 7)),
                        initialDate: DateTime.now(),
                      );
                      if (dateTime != null) {
                        setState(() {
                          _selectedEndTime = dateTime;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fordon:', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 20),
                  FutureBuilder(
                    future: getAllVehicles(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          _selectedVehicleId = snapshot.data!.first.id;
                          return DropdownMenu(
                            initialSelection: snapshot.data!.first,
                            dropdownMenuEntries: snapshot.data!
                                .map<DropdownMenuEntry<Vehicle>>(
                                    (Vehicle vehicle) {
                              return DropdownMenuEntry<Vehicle>(
                                  value: vehicle, label: vehicle.regNr);
                            }).toList(),
                            onSelected: (value) {
                              _selectedVehicleId = value!.id;
                            },
                          );
                        } else {
                          return Text(
                            '(fordon saknas)',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      return CircularProgressIndicator();
                    },
                  )
                ],
              ),
              const SizedBox(height: 40),
              FilledButton(
                child: Text('Starta parkering', style: TextStyle(fontSize: 24)),
                onPressed: () async {
                  Parking parking = Parking(
                      currentPerson!.id,
                      _selectedVehicleId,
                      parkingSpace.id,
                      DateTime.now(),
                      _selectedEndTime,
                      parkingSpace.pricePerHour);
                  parking.parkingSpace = parkingSpace;
                  Navigator.of(context).pop(parking);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime timeOfDayToDateTime(TimeOfDay timeOfDay, {DateTime? dateTime}) {
  if (dateTime != null) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour,
        timeOfDay.minute);
  } else {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }
}
