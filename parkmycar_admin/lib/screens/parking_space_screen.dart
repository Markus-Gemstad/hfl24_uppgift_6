import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_admin/blocs/parking_spaces_bloc.dart';
import 'package:parkmycar_admin/screens/parking_space_edit_dialog.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

class ParkingSpaceScreen extends StatelessWidget {
  const ParkingSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _SearchBar(),
            _SerchBody(),
          ],
        ),
        Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                ParkingSpace? newItem = await showDialog<ParkingSpace>(
                  context: context,
                  builder: (context) => ParkingSpaceEditDialog(),
                );

                //debugPrint(newItem.toString());

                if (newItem != null && newItem.isValid() && context.mounted) {
                  context
                      .read<ParkingSpacesBloc>()
                      .add(CreateParkingSpace(parkingSpace: newItem));
                }
              },
              child: Icon(Icons.add),
            )),
      ],
    );
  }
}

class _SerchBody extends StatelessWidget {
  Future<bool?> showDeleteDialog(ParkingSpace item, BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ta bort ${item.streetAddress}?'),
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
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ParkingSpacesBloc>().add(ReloadParkingSpaces());
          await context
              .read<ParkingSpacesBloc>()
              .stream
              .firstWhere((state) => state is ParkingSpacesLoaded);
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 840),
          child: BlocBuilder<ParkingSpacesBloc, ParkingSpacesState>(
            builder: (context, parkingSpacesState) {
              return switch (parkingSpacesState) {
                ParkingSpacesInitial() =>
                  Center(child: CircularProgressIndicator()),
                ParkingSpacesLoading() =>
                  Center(child: CircularProgressIndicator()),
                ParkingSpacesError(message: final message) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $message'),
                  ),
                ParkingSpacesLoaded(
                  parkingSpaces: final parkingSpaces,
                  pending: final pending
                ) =>
                  (parkingSpaces.isEmpty)
                      ? SizedBox.expand(
                          child: Text('Hittade inga parkeringsplatser.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: parkingSpaces.length,
                          itemBuilder: (context, index) {
                            var item = parkingSpaces[index];
                            bool isPending = item.id == pending?.id;
                            return ListTile(
                              enabled: !isPending,
                              leading: Image.asset(
                                'assets/parking_icon.png',
                                width: 30.0,
                              ),
                              title: Text(item.streetAddress),
                              subtitle: Text('${item.postalCode} ${item.city}\n'
                                  'Pris per timme: ${item.pricePerHour} kr'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        ParkingSpace? updatedItem =
                                            await showDialog<ParkingSpace>(
                                          context: context,
                                          builder: (context) =>
                                              ParkingSpaceEditDialog(
                                                  parkingSpace: item),
                                        );

                                        //debugPrint(updatedItem.toString());

                                        if (updatedItem != null &&
                                            updatedItem.isValid() &&
                                            context.mounted) {
                                          context.read<ParkingSpacesBloc>().add(
                                              UpdateParkingSpace(
                                                  parkingSpace: updatedItem));
                                        }
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        var delete = await showDeleteDialog(
                                            item, context);
                                        if (delete == true && context.mounted) {
                                          context.read<ParkingSpacesBloc>().add(
                                              DeleteParkingSpace(
                                                  parkingSpace: item));
                                        }
                                      }),
                                ],
                              ),
                            );
                          }),
              }; // End of switch
            }, // End of builder property
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late TextEditingController _searchController;
  late ParkingSpacesBloc _parkingSpacesBloc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_queryListener);
    _parkingSpacesBloc = context.read<ParkingSpacesBloc>();
  }

  void _queryListener() {
    _parkingSpacesBloc.add(SearchParkingSpaces(query: _searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(_queryListener);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SearchBar(
        leading: const Icon(Icons.search),
        // trailing: <Widget>[ // Use for clearing search
        //   const Icon(Icons.close),
        //   SizedBox(
        //     width: 6.0,
        //   ),
        // ],
        hintText: 'Sök gata...',
        controller: _searchController,
      ),
    );
  }
}
