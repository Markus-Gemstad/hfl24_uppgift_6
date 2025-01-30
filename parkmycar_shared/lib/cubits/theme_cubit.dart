import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void changeThemeMode(ThemeMode mode) {
    emit(mode);
  }

  @override
  ThemeMode fromJson(Map<String, dynamic> json) {
    switch (json['theme'] as String) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Map<String, dynamic> toJson(ThemeMode state) {
    return {'theme': state.toString().split('.').last};
  }
}
