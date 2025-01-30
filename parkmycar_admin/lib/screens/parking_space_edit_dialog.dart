import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

class ParkingSpaceEditDialog extends StatefulWidget {
  const ParkingSpaceEditDialog({super.key, this.parkingSpace});

  final ParkingSpace? parkingSpace;

  @override
  State<ParkingSpaceEditDialog> createState() => _ParkingSpaceEditDialogState();
}

class _ParkingSpaceEditDialogState extends State<ParkingSpaceEditDialog> {
  final _formKey = GlobalKey<FormState>();

  ParkingSpace? _parkingSpace;
  bool _isEditMode = false;

  String? _streetAddress;
  String? _postalCode;
  String? _city;
  int? _pricePerHour;

  @override
  void initState() {
    if (widget.parkingSpace != null) {
      _parkingSpace = widget.parkingSpace;
      _isEditMode = true;
    }

    super.initState();
  }

  void saveForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isEditMode) {
        _parkingSpace = ParkingSpace(_streetAddress!, _postalCode!, _city!,
            _pricePerHour!, _parkingSpace!.id);
      } else {
        _parkingSpace =
            ParkingSpace(_streetAddress!, _postalCode!, _city!, _pricePerHour!);
      }
      Navigator.pop(context, _parkingSpace);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 10, right: 20, bottom: 20, left: 20),
        child: SizedBox(
          width: (screenSize.width > 500) ? 460 : null,
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('Redigera parkeringsplats',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    CloseButton(),
                  ]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Gatuadress'),
                          initialValue: widget.parkingSpace?.streetAddress,
                          autofocus: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              (Validators.isValidStreetAddress(value))
                                  ? null
                                  : 'Ange en giltig gatuadress.',
                          onSaved: (newValue) => _streetAddress = newValue,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Postnummer'),
                          initialValue: widget.parkingSpace?.postalCode,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          validator: (value) =>
                              (Validators.isValidPostalCode(value))
                                  ? null
                                  : 'Ange ett giltigt postnummer.',
                          onSaved: (newValue) => _postalCode = newValue,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Ort'),
                          initialValue: widget.parkingSpace?.city,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => (Validators.isValidCity(value))
                              ? null
                              : 'Ange en giltig ort.',
                          onSaved: (newValue) => _city = newValue,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Pris per timme'),
                          initialValue:
                              widget.parkingSpace?.pricePerHour.toString(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              (Validators.isValidPricePerHour(value))
                                  ? null
                                  : 'Ange ett giltigt pris.',
                          onSaved: (newValue) =>
                              _pricePerHour = int.tryParse(newValue!),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: [
                              FilledButton.tonal(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Avbryt')),
                              FilledButton(
                                  onPressed: () => saveForm(context),
                                  child: Text('Spara')),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
