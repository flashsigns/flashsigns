import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/active_session.dart';
import 'package:flashsigns/src/blocs/blocs.dart';
import 'package:flashsigns/src/blocs/preferences/preferences.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_event.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_state.dart';
import 'package:flashsigns/src/downloader.dart';
import 'package:flashsigns/src/models/sign.dart';
import 'package:flashsigns/src/resources/signs_repository.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class WorkingSignBloc extends Bloc<WorkingSignEvent, WorkingSignState> {
  ActiveSession _activeSession;
  final ConnectivityBloc connectivityBloc;
  final PreferencesBloc preferencesBloc;

  VideoPlayerController _oldVideoController;
  VideoPlayerController _currentVideoController;

  WorkingSignBloc({
    @required SignsRepository signsRepository,
    @required this.connectivityBloc,
    @required this.preferencesBloc,
  }) : super(WorkingSignLoading()) {
    _activeSession = ActiveSession(signsRepository: signsRepository);

    if (preferencesBloc.state is PreferencesUnknown) {
      preferencesBloc.add(LoadPreferences());
    }
  }

  @override
  Stream<WorkingSignState> mapEventToState(WorkingSignEvent event) async* {
    if (event is LoadWorkingList) {
      yield* _mapLoadWorkingListToState();
    } else if (event is ShowAnswer) {
      yield* _mapShowAnswerToState();
    } else if (event is MarkGoodAnswer) {
      yield* _mapMarkAnswerToState(event);
    } else if (event is MarkWrongAnswer) {
      yield* _mapMarkAnswerToState(event);
    }
  }

  Stream<WorkingSignState> _mapLoadWorkingListToState() async * {
    await _activeSession.init();
    yield* _loadNextSign();
  }

  Stream<WorkingSignState> _loadNextSign() async * {
    final state = this.state;

    try {
      Sign sign;
      // TODO: this can infinite-loop
      do {
        do {
          sign = _activeSession.nextSign();
        } while (state is WorkingSignLoaded && state.sign.id == sign.id);
      } while (!await _prepareSign(sign));

      _oldVideoController = _currentVideoController;
      final videoFile = await _fetchVideoFile(sign);
      _currentVideoController = await _prepareVideoController(videoFile);

      yield WorkingSignLoaded(sign, _currentVideoController);
      _oldVideoController?.dispose();
    } catch (error) {
      print("Loading failed with error: " + error.toString());
      yield WorkingSignNotLoaded();
    }
  }

  Future<bool> _prepareSign(final Sign sign) async {
    final videoFile = await _fetchVideoFile(sign);

    if (await _isAvailableLocally(videoFile)) {
      return true;
    }

    final preferenceState = preferencesBloc.state;
    final useMobileData = preferenceState is PreferencesChanged && preferenceState.useMobileData;
    final canDownloadVideo = useMobileData || connectivityBloc.state is ConnectivityWifi;
    if (!canDownloadVideo) {
      return false;
    }

    await _downloadVideo(sign);
    return true;
  }

  Future<File> _fetchVideoFile(final Sign sign) async {
    final videoFilename = _fetchVideoFilename(sign);
    final videoDir = await _fetchVideoDir();

    return File(join(videoDir.path, videoFilename));
  }

  String _fetchVideoFilename(final Sign sign) {
    return sign.id.toString() + ".mp4";
  }

  Future<Directory> _fetchVideoDir() async {
    return getApplicationDocumentsDirectory();
  }

  Future<bool> _isAvailableLocally(final File videoFile) async {
    return await videoFile.exists();
  }

  Future<void> _downloadVideo(final Sign sign) async {
    final downloader = await Downloader.getInstance();
    downloader.download(_fetchVideoFilename(sign), sign.url, (await _fetchVideoDir()).path);
  }

  Future<VideoPlayerController> _prepareVideoController(final File videoFile) async {
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

  Stream<WorkingSignState> _mapMarkAnswerToState(WorkingSignEvent event) async * {
    if (event is MarkGoodAnswer) {
      await _activeSession.markCorrect(event.sign);
    } else if (event is MarkWrongAnswer) {
      _activeSession.markWrong(event.sign);
    }

    if (state is WorkingSignLoaded) {
      yield WorkingSignLoading();
      yield* _loadNextSign();
    }
  }
}