import 'package:equatable/equatable.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class LoadPreferences extends PreferencesEvent {}

class SetUseMobileData extends PreferencesEvent {
  final bool useMobileData;

  const SetUseMobileData(this.useMobileData);

  @override
  List<Object> get props => [useMobileData];

  @override
  String toString() => 'SetUseMobileData { useMobileData: $useMobileData }';
}
