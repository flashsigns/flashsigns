import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/blocs/blocs.dart';
import 'package:flashsigns/src/resources/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home: BlocProvider(
          create: (context) {
            return WorkingSignBloc(signsRepository: DatabaseHelper.instance)
              ..add(LoadWorkingList());
          },
        child: PracticeSignScreen(isAnswerVisible: false),
      )
    );
  }
}

class PracticeSignScreen extends StatefulWidget {
  final bool isAnswerVisible;

  PracticeSignScreen({
    Key key,
    @required this.isAnswerVisible,
  }) : super(key: key);

  @override
  _PracticeSignScreenState createState() => _PracticeSignScreenState();
}

class _PracticeSignScreenState extends State<PracticeSignScreen> {
  VideoPlayerController _controller;

  bool get isAnswerVisible => widget.isAnswerVisible;

  @override
  void initState() {
    FlutterDownloader.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<WorkingSignBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('FlashSigns'),
        ),
        body: Container(
          child: BlocListener<WorkingSignBloc, WorkingSignState>(
              listener: (context, state) {
              },
              child: BlocBuilder<WorkingSignBloc, WorkingSignState>(
                  builder: (context, state) {
                    return Column(children: [
                      _videoWidget(state),
                      _scoreButtonsWidget(bloc, state),
                      _descriptionWidget(state),
                    ]);
                  }
              )
          ),
        )
    );
  }

  Widget _videoWidget(final WorkingSignState state) {
    if (state is WorkingSignLoaded) {
      return _createVideoFuture(state);
    } else {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
  }

  FutureBuilder _createVideoFuture(final WorkingSignLoaded state) {
    return FutureBuilder<VideoPlayerController>(
      future: _createVideoController(state),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            child: Icon(
              Icons.signal_wifi_off,
              size: 96,
              color: Colors.grey[300],
            ),
            height: MediaQuery.of(context).size.height * 0.45,
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          final videoController = snapshot.data;
          final video = videoController.value;

          return Expanded(child: Container(child: Center(child: AspectRatio(
            aspectRatio: video.aspectRatio,
            child: GestureDetector(
                onTap: () {
                  video.isPlaying ? videoController.pause() : videoController.play();
                },
                child: VideoPlayer(videoController)),
          ))));
        } else {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Future<VideoPlayerController> _createVideoController(final WorkingSignLoaded state) async {
    final sign = state.sign;

    final videoFilename = sign.id.toString() + ".mp4";
    final videoDir = await getApplicationDocumentsDirectory();
    final videoFile = File(join(videoDir.path, videoFilename));
    final doesExist = await videoFile.exists();

    var controller;

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

      controller = VideoPlayerController.network(sign.url);
    } else {
      controller = VideoPlayerController.file(videoFile);
    }

    await controller.initialize();
    controller.setLooping(true);

    // Dispose previous controller and save new one
    if (_controller != null) _controller.dispose();
    _controller = controller;

    return controller;
  }

  Widget _scoreButtonsWidget(final WorkingSignBloc bloc, final WorkingSignState state) {
    return Expanded(flex: 0, child: Row(children: [
        Expanded(child: IconButton(
          icon: Icon(Icons.highlight_off),
          iconSize: 96,
          color: Colors.red[700],
          tooltip: "Answer was wrong",
          onPressed: () {
            if (state is WorkingSignLoaded) {
              bloc.add(MarkWrongAnswer(state.sign));
            }
          },
        )),
        Expanded(child: IconButton(
          icon: Icon(Icons.check_circle_outline),
          iconSize: 96,
          color: Colors.green[700],
          tooltip: "Answer was correct",
          onPressed: () {
            if (state is WorkingSignLoaded) {
              bloc.add(MarkGoodAnswer(state.sign));
            }
          },
        )),
      ]),
    );
  }

  Widget _descriptionWidget(final WorkingSignState state) {
    if (state is WorkingSignLoaded) {
      return Expanded(child: Center(
          child: Text(state.sign.description,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
          )
      ));
    } else {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
  }
}
