import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/blocs/blocs.dart';
import 'package:flashsigns/src/resources/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
        home: _practiceSignRoute(),
    );
  }
}

Widget _practiceSignRoute() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<ConnectivityBloc>(
        create: (context) => ConnectivityBloc(),
      ),
      BlocProvider<WorkingSignBloc>(
        create: (context) {
          return WorkingSignBloc(signsRepository: DatabaseHelper.instance)
            ..add(LoadWorkingList());
        },
      ),
    ],
    child: PracticeSignScreen(),
  );
}

class PracticeSignScreen extends StatefulWidget {
  PracticeSignScreen({ Key key }) : super(key: key);

  @override
  _PracticeSignScreenState createState() => _PracticeSignScreenState();
}

class _PracticeSignScreenState extends State<PracticeSignScreen> {
  VideoPlayerController _controller;

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
    final _bloc = BlocProvider.of<WorkingSignBloc>(context);
    final _connectivity = BlocProvider.of<ConnectivityBloc>(context)
            ..add(SubscribeConnectivity());

    return Scaffold(
      appBar: AppBar(
        title: Text('FlashSigns'),
        actions: <Widget>[
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
              bloc: _connectivity,
              builder: (context, state) {
                if (state is ConnectivityWifi) {
                  return Container(width: 0, height: 0);
                } else {
                  return Center(child: Padding(
                      child: Text(
                          "Offline".toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      padding: EdgeInsets.only(right: 10.0)
                  ));
                }
              }
          ),
        ],
      ),
      body: Container(
          child: BlocBuilder<WorkingSignBloc, WorkingSignState>(
              builder: (context, state) {
                return Column(children: [
                  _videoWidget(_bloc, state),
                  _scoreButtonsWidget(_bloc, state),
                  _descriptionWidget(state),
                ]);
              }
          )
      ),
    );
  }

  Widget _videoWidget(final WorkingSignBloc bloc, final WorkingSignState state) {
    if (state is WorkingSignLoaded) {
      final videoController = state.videoController;

      return Expanded(child: Container(child: Center(child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            bloc.add(ShowAnswer());
            videoController.value.isPlaying ? videoController.pause() : videoController.play();
          },
          child: Padding(
            child: VideoPlayer(videoController),
            padding: EdgeInsets.only(top: 10.0),
          ),
        )
      ))));
    } else if (state is WorkingSignNotLoaded) {
      return Expanded(
        child: Icon(
          Icons.signal_wifi_off,
          size: 96,
          color: Colors.grey[300],
        )
      );
    } else {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
  }

  Widget _scoreButtonsWidget(final WorkingSignBloc bloc, final WorkingSignState state) {
    return Expanded(flex: 0, child: Row(children: [
        Expanded(child: IconButton(
          icon: Icon(Icons.highlight_off),
          iconSize: 96,
          color: (state is WorkingSignLoaded && state.isAnswerVisible) ? Colors.red[700] : Colors.grey[400],
          tooltip: "Answer was wrong",
          onPressed: () {
            if (state is WorkingSignLoaded && state.isAnswerVisible) {
              bloc.add(MarkWrongAnswer(state.sign));
            } else {
              bloc.add(ShowAnswer());
            }
          },
        )),
        Expanded(child: IconButton(
          icon: Icon(Icons.check_circle_outline),
          iconSize: 96,
          color: (state is WorkingSignLoaded && state.isAnswerVisible) ? Colors.green[700] : Colors.grey[400],
          tooltip: "Answer was correct",
          onPressed: () {
            if (state is WorkingSignLoaded && state.isAnswerVisible) {
              bloc.add(MarkGoodAnswer(state.sign));
            } else {
              bloc.add(ShowAnswer());
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
    } else if (state is WorkingSignNotLoaded) {
      return Expanded(
          child: Icon(
            Icons.signal_wifi_off,
            size: 96,
            color: Colors.grey[300],
          )
      );
    } else {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
  }
}
