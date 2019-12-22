import 'package:equatable/equatable.dart';
import 'package:flashsigns/src/models/sign.dart';
import 'package:video_player/video_player.dart';

abstract class WorkingSignState extends Equatable {
  const WorkingSignState();

  @override
  List<Object> get props => [];
}

class WorkingSignLoading extends WorkingSignState {}

class WorkingSignLoaded extends WorkingSignState {
  final Sign sign;
  final VideoPlayerController videoController;
  final bool isAnswerVisible;

  WorkingSignLoaded(this.sign, this.videoController, { this.isAnswerVisible = false });

  @override
  List<Object> get props => [sign, isAnswerVisible];

  @override
  String toString() => 'WorkingSignLoaded { sign: [${sign.id}] ${sign.description}, isAnswerVisible: $isAnswerVisible }';
}

class WorkingSignNotLoaded extends WorkingSignState {}
