import 'package:equatable/equatable.dart';
import 'package:flashsigns/src/models/sign.dart';

abstract class WorkingSignState extends Equatable {
  const WorkingSignState();

  @override
  List<Object> get props => [];
}

class WorkingSignLoading extends WorkingSignState {}

class WorkingSignLoaded extends WorkingSignState {
  final Sign sign;

  const WorkingSignLoaded(this.sign);

  @override
  List<Object> get props => [sign];

  @override
  String toString() => 'WorkingSignLoaded { sign: $sign }';
}

class WorkingSignNotLoaded extends WorkingSignState {}
