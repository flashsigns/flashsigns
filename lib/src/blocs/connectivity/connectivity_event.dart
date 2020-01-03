import 'package:connectivity/connectivity.dart';
import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class SubscribeConnectivity extends ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult connectivityResult;

  const ConnectivityChanged(this.connectivityResult);

  @override
  List<Object> get props => [connectivityResult];

  @override
  String toString() => 'ConnectivityChanged { connectivityResult: $connectivityResult }';
}

class UnsubscribeConnectivity extends ConnectivityEvent {}
