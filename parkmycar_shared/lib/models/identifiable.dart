import 'package:uuid/uuid.dart';

abstract class Identifiable {
  final String id;

  Identifiable([String? id]) : id = id ?? const Uuid().v4();
  
  bool isValid();
}
