import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityUnknown extends ConnectivityState {}
class ConnectivityNone extends ConnectivityState {}
class ConnectivityMobile extends ConnectivityState {}
class ConnectivityWifi extends ConnectivityState {}

