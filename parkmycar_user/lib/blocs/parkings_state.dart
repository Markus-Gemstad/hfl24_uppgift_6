part of 'parkings_bloc.dart';

sealed class ParkingsState extends Equatable {}

class ParkingsInitial extends ParkingsState {
  @override
  List<Object?> get props => [];
}

class ParkingsLoading extends ParkingsState {
  @override
  List<Object?> get props => [];
}

class ParkingsLoaded extends ParkingsState {
  final List<Parking> parkings;
  final Parking? pending;

  ParkingsLoaded({required this.parkings, this.pending});

  @override
  List<Object?> get props => [parkings, pending];
}

class ParkingsError extends ParkingsState {
  final String message;
  ParkingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
