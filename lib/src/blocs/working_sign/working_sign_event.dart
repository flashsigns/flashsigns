import 'package:equatable/equatable.dart';
import 'package:flashsigns/src/models/sign.dart';

abstract class WorkingSignEvent extends Equatable {
  const WorkingSignEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkingList extends WorkingSignEvent {}

class ShowAnswer extends WorkingSignEvent {}

class MarkGoodAnswer extends WorkingSignEvent {
  final Sign sign;

  const MarkGoodAnswer(this.sign);

  @override
  List<Object> get props => [sign];

  @override
  String toString() => 'MarkGoodAnswer { sign: [${sign.id}] ${sign.description} }';
}

class MarkWrongAnswer extends WorkingSignEvent {
  final Sign sign;

  const MarkWrongAnswer(this.sign);

  @override
  List<Object> get props => [sign];

  @override
  String toString() => 'MarkWrongAnswer { sign: [${sign.id}] ${sign.description} }';
}