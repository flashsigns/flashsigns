import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/active_session.dart';
import 'package:flashsigns/src/blocs/blocs.dart';
import 'package:flashsigns/src/blocs/preferences/preferences.dart';
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
  ActiveSession _activeSession;
  final ConnectivityBloc connectivityBloc;
  final PreferencesBloc preferencesBloc;

  VideoPlayerController _oldVideoController;
  VideoPlayerController _currentVideoController;

  WorkingSignBloc({
    @required DatabaseHelper signsRepository,
    @required this.connectivityBloc,
    @required this.preferencesBloc,
  }) {
    _activeSession = ActiveSession(signsRepository: signsRepository);

    if (preferencesBloc.state is PreferencesUnknown) {
      preferencesBloc.add(LoadPreferences());
    }
  }

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
      await _activeSession.init();

      Sign sign;
      do {
        sign = _activeSession.nextSign();
      } while (!await _prepareSign(sign));

      final videoFile = await _fetchVideoFile(sign);
      _currentVideoController = await _prepareVideoController(videoFile);

      yield WorkingSignLoaded(sign, _currentVideoController);
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

  // TODO should return when the download is finished!
  // TODO: create an _enqueueVideoDownload(sign)?
  Future<void> _downloadVideo(final Sign sign) async {
    return FlutterDownloader.enqueue(
      fileName: _fetchVideoFilename(sign),
      url: sign.url,
      savedDir: (await _fetchVideoDir()).path,
      showNotification: false,
      openFileFromNotification: false,
    );
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

  Stream<WorkingSignState> _mapMarkGoodAnswerToState(MarkGoodAnswer event) async * {
    final state = this.state;

    if (state is WorkingSignLoaded) {
      final currentSign = state.sign;
      await _activeSession.markCorrect(currentSign);

      yield WorkingSignLoading();
      yield * _loadNewSign(_findNewSign(state.sign));
    }
  }

  // TODO: may need to download it!
  Stream<WorkingSignState> _loadNewSign(final Sign newSign) async * {
    try {
      _oldVideoController = _currentVideoController;
      final videoFile = await _fetchVideoFile(newSign);
      _currentVideoController = await _prepareVideoController(videoFile);

      yield WorkingSignLoaded(newSign, _currentVideoController);
      _oldVideoController.dispose();
    } catch(error) {
      print("Loading failed with error: " + error);
      yield WorkingSignNotLoaded();
    }
  }

  Sign _findNewSign(final Sign currentSign) {
    Sign newSign;

    do {
      newSign = _activeSession.nextSign();
    } while (newSign.id == currentSign.id);

    return newSign;
  }

  Stream<WorkingSignState> _mapMarkWrongAnswerToState(MarkWrongAnswer event) async * {
    final state = this.state;

    if (state is WorkingSignLoaded) {
      final currentSign = state.sign;
      _activeSession.markWrong(currentSign);

      yield WorkingSignLoading();
      yield * _loadNewSign(_activeSession.nextSign());
    }
  }
}