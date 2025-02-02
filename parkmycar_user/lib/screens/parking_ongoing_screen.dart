import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/blocs/notification_bloc.dart';

import '../blocs/active_parking_bloc.dart';
import '../globals.dart';

class ParkingOngoingScreen extends StatefulWidget {
  const ParkingOngoingScreen({super.key, required this.onEndParking});

  final Function onEndParking;

  @override
  State<ParkingOngoingScreen> createState() => _ParkingOngoingScreenState();
}

class _ParkingOngoingScreenState extends State<ParkingOngoingScreen> {
  Timer? _timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeParkingState = context.watch<ActiveParkingBloc>().state;
    Parking? ongoingParking = activeParkingState.parking;

    // If the parking is ongoing and the end time has passed, remove
    // the ongoing parking from the active parking state
    if (ongoingParking != null &&
        ongoingParking.endTime.isBefore(DateTime.now())) {
      context.read<ActiveParkingBloc>().add(ActiveParkingEnd(ongoingParking));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pågående parkering'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ListTile(
                leading: Hero(
                  tag: 'parkingicon${ongoingParking!.parkingSpace!.id}',
                  child: Image.asset(
                    'assets/parking_icon.png',
                    width: 60.0,
                  ),
                ),
                title: Text(ongoingParking.parkingSpace!.streetAddress),
                subtitle: Text(
                    '${ongoingParking.parkingSpace!.postalCode} ${ongoingParking.parkingSpace!.city}\n'
                    'Pris per timme: ${ongoingParking.parkingSpace!.pricePerHour} kr'),
              ),
              SizedBox(height: 20),
              Text(
                  'Starttid: ${dateTimeFormat.format(ongoingParking.startTime)}'),
              Text('Sluttid: ${dateTimeFormat.format(ongoingParking.endTime)}'),
              SizedBox(height: 20.0),
              BlocBuilder<ActiveParkingBloc, ActiveParkingState>(
                builder: (context, state) {
                  if (state.status == ParkingStatus.starting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.status == ParkingStatus.active ||
                      state.status == ParkingStatus.extending) {
                    return buildOngoingBody(ongoingParking, context);
                  } else {
                    return Text('error...');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Column buildOngoingBody(Parking ongoingParking, BuildContext context) {
    return Column(
      children: [
        Text('Förfluten tid: ${ongoingParking.elapsedTimeToString()}',
            style: TextStyle(
                fontSize: 20,
                color: (ongoingParking.isSoonOverdue)
                    ? Colors.red
                    : Colors.black)),
        Text('Kostnad: ${ongoingParking.elapsedCostToString()}',
            style: TextStyle(fontSize: 20)),
        SizedBox(height: 10.0),
        Visibility(
            visible: ongoingParking.isSoonOverdue,
            child: Text(
              'OBS! Din parkeringstid går snart ut!',
              style: TextStyle(fontSize: 16, color: Colors.red),
            )),
        SizedBox(height: 20.0),
        // TextButton(
        //   onPressed: () {
        //     context.read<NotificationBloc>().add(ScheduleNotification(
        //         id: ongoingParking.id,
        //         title: "Din parkering håller på att gå ut",
        //         content:
        //             "Din parkering på ${ongoingParking.parkingSpace!.streetAddress} håller på att gå ut.",
        //         deliveryTime: DateTime.now().add(Duration(seconds: 20))));
        //   },
        //   child: const Text('Visa notis om 20 sek'),
        // ),
        ElevatedButton(
          onPressed: () {
            DateTime newEndTime = ongoingParking.endTime.add(extendEndTimeBy);
            // If new time is overdue, extend with 1 minute from now
            // if (newEndTime.isBefore(DateTime.now())) {
            //   newEndTime = DateTime.now().add(Duration(minutes: 1));
            // }

            context
                .read<ActiveParkingBloc>()
                .add(ActiveParkingExtend(ongoingParking, newEndTime));

            // Cancel the old notification - no need, the new will overrite the old
            // context
            //     .read<NotificationBloc>()
            //     .add(CancelNotification(id: ongoingParking.id));

            // Create a new notification for the extended parking
            context.read<NotificationBloc>().add(ScheduleNotification(
                id: ongoingParking.id,
                title: "Din parkeringstid går snart ut!",
                content:
                    "Parkeringstiden på ${ongoingParking.parkingSpace!.streetAddress} går snart ut.",
                deliveryTime: newEndTime.subtract(notifyParkingEndTime),
                payload: ongoingParking.id));
          },
          child: Text('Förläng sluttid med 1 minut'),
        ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            context.read<ActiveParkingBloc>().add(
                ActiveParkingEnd(ongoingParking, newEndTime: DateTime.now()));

            context
                .read<NotificationBloc>()
                .add(CancelNotification(id: ongoingParking.id));
          },
          child: Text('Avsluta parkering', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
