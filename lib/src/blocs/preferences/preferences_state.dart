import 'package:equatable/equatable.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesUnknown extends PreferencesState {}

class PreferencesChanged extends PreferencesState {
  final bool useMobileData;

  const PreferencesChanged(this.useMobileData);

  @override
  List<Object> get props => [useMobileData];

  @override
  String toString() => "PreferencesChanged { useMobileData: $useMobileData }";
}
