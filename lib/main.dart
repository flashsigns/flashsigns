import 'dart:io';

import 'package:flashsigns/src/blocs/blocs.dart';
import 'package:flashsigns/src/blocs/preferences/preferences.dart';
import 'package:flashsigns/src/resources/signs_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityBloc>(
            create: (context) => ConnectivityBloc(),
          ),
          BlocProvider<PreferencesBloc>(
            create: (context) => PreferencesBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'FlashSigns',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: _practiceSignRoute(),
        )
    );
  }
}

Widget _practiceSignRoute() {
  return BlocProvider<WorkingSignBloc>(
    create: (context) {
      return WorkingSignBloc(
        signsRepository: SignsRepository.instance,
        connectivityBloc: BlocProvider.of<ConnectivityBloc>(context),
        preferencesBloc: BlocProvider.of<PreferencesBloc>(context),
      )
        ..add(LoadWorkingList());
    },
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
    final _workingSignBloc = BlocProvider.of<WorkingSignBloc>(context);
    final _connectivityBloc = BlocProvider.of<ConnectivityBloc>(context)
            ..add(SubscribeConnectivity());

    return Scaffold(
      appBar: AppBar(
        title: Text('FlashSigns'),
        actions: <Widget>[
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
              cubit: _connectivityBloc,
              builder: (context, state) {
                final preferencesState = BlocProvider.of<PreferencesBloc>(context).state;
                final useMobileData = preferencesState is PreferencesChanged && preferencesState.useMobileData;

                if (useMobileData || state is ConnectivityWifi) {
                  return Container(width: 0, height: 0);
                } else {
                  return Center(child: Text(
                      "Offline".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                  ));
                }
              }
          ),
          Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _settingsRoute())
                  );
                },
              )
          )
        ],
      ),
      body: Container(
          child: BlocBuilder<WorkingSignBloc, WorkingSignState>(
              builder: (context, state) {
                return Column(children: [
                  _videoWidget(_workingSignBloc, state),
                  _scoreButtonsWidget(_workingSignBloc, state),
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

Widget _settingsRoute() {
  return SettingsScreen();
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _preferencesBloc = BlocProvider.of<PreferencesBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("FlashSigns"),
        ),
        body: BlocBuilder<PreferencesBloc, PreferencesState>(
          cubit: _preferencesBloc,
          builder: (context, state) {
            if (state is PreferencesChanged) {
              return ListView(
                  children: <Widget>[
                    CheckboxListTile(
                      value: !state.useMobileData,
                      title: Text("Only download over WiFi"),
                      onChanged: (useWifiOnly) async {
                        _preferencesBloc.add(SetUseMobileData(!useWifiOnly));
                      },
                    ),
                    ..._debugTiles(),
                  ]);
            } else {
              _preferencesBloc.add(LoadPreferences());
              return Container(child: Center(child: CircularProgressIndicator()));
            }
          },
        )
    );
  }

  List<StatelessWidget> _debugTiles() {
    if (kReleaseMode) {
      return [];
    }

    return [
      Divider(),
      Builder(builder: (context) => ListTile(
        leading: Icon(Icons.save),
        title: Text("Export database"),
        subtitle: Text("Save database on SD card"),
        onTap: () {
          if (Platform.isAndroid) {
            Permission.storage.request().then((storagePermission) {
              if (storagePermission == PermissionStatus.granted) {
                final downloadsPath = "/storage/emulated/0/Download/";
                SignsRepository.instance.closeDatabase();
                SignsRepository.instance.databaseFile.then((file) => file.copySync(join(downloadsPath, "flashsigns_exported_database.db")));

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Database exported"),
                ));
              }
            });
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Not implemented on this platform!"),
            ));
          }
        }
    )),
    Builder(builder: (context) => ListTile(
        leading: Icon(Icons.import_export),
        title: Text("Import database"),
        subtitle: Text("Replace database with the one from SD card, if existing"),
        onTap: () {
          if (Platform.isAndroid) {
            Permission.storage.request().then((storagePermission) {

              if (storagePermission == PermissionStatus.granted) {
                final downloadsPath = "/storage/emulated/0/Download/";
                final databaseToImport = File(join(downloadsPath, "flashsigns_exported_database.db"));
                if (!databaseToImport.existsSync()) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Import failed: nothing to import!"),
                  ));
                  return;
                }

                SignsRepository.instance.closeDatabase();
                SignsRepository.instance.databaseFile.then((file) => databaseToImport.copySync(file.path));

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Database imported"),
                ));
              }
            });
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Not implemented on this platform!"),
            ));
          }
        },
      )),
      ListTile(
        leading: Icon(Icons.share),
        title: Text("Share..."),
        onTap: () {
          SignsRepository.instance.closeDatabase();
          SignsRepository.instance.databaseFile.then((file) => Share.shareFile(file));
        },
    )
    ];
    }
}
