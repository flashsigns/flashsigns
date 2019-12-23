import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_event.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_state.dart';
import 'package:flashsigns/src/models/sign.dart';
import 'package:flashsigns/src/resources/database_helper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class WorkingSignBloc extends Bloc<WorkingSignEvent, WorkingSignState> {
  final DatabaseHelper signsRepository;

  List<Sign> _signs;
  VideoPlayerController _oldVideoController;
  VideoPlayerController _currentVideoController;

  WorkingSignBloc({@required this.signsRepository});

  @override
  WorkingSignState get initialState => WorkingSignLoading();

  @override
  Stream<WorkingSignState> mapEventToState(WorkingSignEvent event) async* {
    if (event is LoadWorkingList) {
      yield* _mapLoadWorkingListToState();
    } else if (event is ShowAnswer) {
      yield* _mapShowAnswerToState();
    } else if (event is MarkGoodAnswer) {
      yield* _mapMarkGoodAnswerToState(event);
    } else if (event is MarkWrongAnswer) {
      yield* _mapMarkWrongAnswerToState(event);
    }
  }

  Stream<WorkingSignState> _mapLoadWorkingListToState() async * {
    try {
      _signs = await this.signsRepository.queryAllSigns();
      final sign = _signs.elementAt(0);
      _currentVideoController = await _prepareVideoController(sign);

      yield WorkingSignLoaded(sign, _currentVideoController);
    } catch (_) {
      yield WorkingSignNotLoaded();
    }
  }

  Future<VideoPlayerController> _prepareVideoController(final Sign sign) async {
    final videoFilename = sign.id.toString() + ".mp4";
    final videoDir = await getApplicationDocumentsDirectory();
    final videoFile = File(join(videoDir.path, videoFilename));
    final doesExist = await videoFile.exists();

    if (!doesExist) {
      final connectivityStatus = await Connectivity().checkConnectivity();

      if (connectivityStatus != ConnectivityResult.wifi) {
        throw("A WiFi connection is required!");
      } else {
        await FlutterDownloader.enqueue(
          fileName: videoFilename,
          url: sign.url,
          savedDir: videoDir.path,
          showNotification: false,
          openFileFromNotification: false,
        );
      }
    }

    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    controller.setLooping(true);

    return controller;
  }

  Stream<WorkingSignState> _mapShowAnswerToState() async* {
    final state = this.state;

    if (state is WorkingSignLoaded && !state.isAnswerVisible) {
      _currentVideoController.play();
      yield WorkingSignLoaded(state.sign, state.videoController, isAnswerVisible: true);
    }
  }

  Stream<WorkingSignState> _mapMarkGoodAnswerToState(MarkGoodAnswer event) async * {
    if (state is WorkingSignLoaded) {
      // TODO: update score!

      final newSign = _chooseNewSign();
      yield WorkingSignLoading();
      yield * _loadNewSign(newSign);
    }
  }

  Sign _chooseNewSign() {
    final rng = new Random();
    final chosenId = rng.nextInt(_signs.length);
    return _signs.elementAt(chosenId);
  }

  Stream<WorkingSignState> _loadNewSign(final Sign newSign) async * {
    try {
      _oldVideoController = _currentVideoController;
      _currentVideoController = await _prepareVideoController(newSign);

      yield WorkingSignLoaded(newSign, _currentVideoController);
      _oldVideoController.dispose();
    } catch(_) {
      yield WorkingSignNotLoaded();
    }
  }

  Stream<WorkingSignState> _mapMarkWrongAnswerToState(MarkWrongAnswer event) async * {
    if (state is WorkingSignLoaded) {
      // TODO: update score!

      final newSign = _chooseNewSign();
      yield WorkingSignLoading();
      yield * _loadNewSign(newSign);
    }
  }
}