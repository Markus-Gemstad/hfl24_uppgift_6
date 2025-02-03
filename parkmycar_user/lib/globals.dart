import 'package:intl/intl.dart';

/// Use for formating date and time
final DateFormat timeOnlyFormat = DateFormat('HH:mm');
final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final DateFormat dateTimeFormatShort = DateFormat('yyMMdd HH:mm:ss');

int delayLoadInMilliseconds = 500;

final Duration suggestedParkingEndTime =
    Duration(minutes: 1); // Subtracted from current time
final Duration notifyParkingEndTime =
    Duration(seconds: 20); // Subtracted from end time
final Duration extendEndTimeBy = Duration(minutes: 1);
