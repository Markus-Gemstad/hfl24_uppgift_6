import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:provider/provider.dart';

class VehicleEditDialog extends StatefulWidget {
  const VehicleEditDialog({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  State<VehicleEditDialog> createState() => _VehicleEditDialogState();
}

class _VehicleEditDialogState extends State<VehicleEditDialog> {
  Vehicle? _vehicle;
  VehicleType? _vehicleType = VehicleType.car;
  final TextEditingController _regNrTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _regNr;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      _vehicle = widget.vehicle;
      isEditMode = true;
      _regNrTextController.text = _vehicle!.regNr;
      _vehicleType = _vehicle!.type;
    }

    _regNrTextController.addListener(() {
      final String text = _regNrTextController.text.toUpperCase();
      _regNrTextController.value =
          _regNrTextController.value.copyWith(text: text);
    });
  }

  void saveForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authState = context.read<AuthBloc>().state;
      Person? currentPerson = authState.person;

      if (isEditMode) {
        _vehicle = Vehicle(_regNr!, currentPerson!.id,
            _vehicleType as VehicleType, _vehicle!.id);
      } else {
        _vehicle =
            Vehicle(_regNr!, currentPerson!.id, _vehicleType as VehicleType);
      }
      Navigator.pop(context, _vehicle);
    }
  }

  @override
  void dispose() {
    _regNrTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Skapa nytt fordon"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _regNrTextController,
                maxLength: 6,
                autofocus: true,
                // focusNode: FocusNode(),
                onSaved: (newValue) => _regNr = newValue,
                validator: (value) {
                  if (!Validators.isValidRegNr(value)) {
                    return 'Ange ett giltigt regnr.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => saveForm(context),
                onChanged: (value) {
                  setState(() {
                    // if (value.length == 6) {
                    //   _regnrIsValid = Validators.isValidRegNr(value);
                    // } else {
                    //   _regnrIsValid = false;
                    // }
                  });
                },
                decoration: InputDecoration(hintText: "Ange regnr (XXXNNN)"),
              ),
              RadioListTile<VehicleType>(
                title: const Text('Bil'),
                value: VehicleType.car,
                groupValue: _vehicleType,
                onChanged: (VehicleType? value) {
                  setState(() {
                    _vehicleType = value;
                  });
                },
              ),
              RadioListTile<VehicleType>(
                title: const Text('Motocykel'),
                value: VehicleType.motorcycle,
                groupValue: _vehicleType,
                onChanged: (VehicleType? value) {
                  setState(() {
                    _vehicleType = value;
                  });
                },
              ),
              RadioListTile<VehicleType>(
                title: const Text('Lastbil'),
                value: VehicleType.truck,
                groupValue: _vehicleType,
                onChanged: (VehicleType? value) {
                  setState(() {
                    _vehicleType = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Avbryt")),
          TextButton(
              onPressed: () => saveForm(context), child: const Text("Spara")),
        ],
      ),
    );
  }
}
