import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../globals.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<double> _totalParkingIncome;
  late Future<List<PopularParkingSpace>> _popularParkingSpaceList;
  late Stream<List<Parking>> _ongoingParkingsStream;

  Future<List<PopularParkingSpace>> getPopularParkingSpaces() async {
    var parkingSpaces = await ParkingSpaceFirebaseRepository().getAll();
    var parkings = await ParkingFirebaseRepository().getAll();

    // TODO Ersätta med bättre relationer mellan Parking och ParkingSpace
    List<PopularParkingSpace> list = List.empty(growable: true);
    for (int i = 0; i < parkingSpaces.length; i++) {
      var parkingSpace = parkingSpaces[i];
      try {
        int parkingCount = parkings
            .where((element) => element.parkingSpaceId == parkingSpace.id)
            .length;
        if (parkingCount > 0) {
          list.add(PopularParkingSpace(parkingSpace, parkingCount));
        }
      } catch (e) {
        //debugPrint('Error getting Parking:${parkingSpace.id}');
      }
    }

    // Sort by number of parkings and get top 10
    // TODO Be able to get top 10 ParkingSpaces directly from the db instead
    list.sort((a, b) => b.parkingCount.compareTo(a.parkingCount));
    list = list.take(10).toList();

    // Added delay to demonstrate loading animation
    return Future.delayed(Duration(milliseconds: 250), () => list);
  }

  Future<double> getTotalParkingIncome() async {
    var items = await ParkingFirebaseRepository().getAll();
    items = items.where((element) => !element.isOngoing).toList();
    return items.fold<double>(0, (sum, item) => sum + item.totalCost);
  }

  @override
  void initState() {
    super.initState();
    _totalParkingIncome = getTotalParkingIncome();
    _popularParkingSpaceList = getPopularParkingSpaces();
    _ongoingParkingsStream =
        ParkingFirebaseRepository().getOngoingParkingsStream();
  }

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 12, bottom: 12, left: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text('Aktiva parkeringar',
                        style: Theme.of(context).textTheme.titleLarge),
                    // IconButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         _ongoingParkings = getOngoingParkings();
                    //       });
                    //     },
                    //     icon: Icon(Icons.refresh))
                  ],
                ),
                SizedBox(height: 20),
                StreamBuilder(
                    stream: _ongoingParkingsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Expanded(
                          child: SelectableText('Error: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Expanded(
                            child: Text('Finns inga pågående parkeringar.'),
                          );
                        }
                        debugPrint('Has data: ${snapshot.data}');

                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Parking item = snapshot.data![index];
                              return ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(item.parkingSpace!.streetAddress),
                                  subtitle: Text(
                                      '${item.parkingSpace!.postalCode} ${item.parkingSpace!.city}\n'
                                      'Tid: ${dateTimeFormatShort.format(item.startTime)} - '
                                      '${dateTimeFormatShort.format(item.endTime)}'));
                            },
                          ),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ],
            ),
          ),
          VerticalDivider(
            width: 40,
          ),
          //SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: _totalParkingIncome,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                            'Summa inkomst: ${double.parse(snapshot.data!.toStringAsFixed(2))} kr',
                            style: Theme.of(context).textTheme.titleLarge);
                      }
                      return CircularProgressIndicator();
                    }),
                SizedBox(height: 30),
                Text('10 populäraste adresser',
                    style: Theme.of(context).textTheme.titleLarge),
                FutureBuilder(
                    future: _popularParkingSpaceList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _popularParkingSpaceList =
                                    getPopularParkingSpaces();
                              });
                            },
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var item = snapshot.data![index];
                                return ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(
                                      '${index + 1}. ${item.parkingSpace.streetAddress}'),
                                  subtitle: Text(
                                      '${item.parkingSpace.postalCode} ${item.parkingSpace.city}\n'
                                      'Antal parkeringar: ${item.parkingCount} st'),
                                );
                              },
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Expanded(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      return CircularProgressIndicator();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PopularParkingSpace {
  ParkingSpace parkingSpace;
  int parkingCount;

  PopularParkingSpace(this.parkingSpace, this.parkingCount);
}
