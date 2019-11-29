import 'dart:io';
import 'dart:math';

import 'package:flashsigns/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final _dbHelper = DatabaseHelper.instance;
  Sign _activeSign;

  Future<VideoPlayerController> _initVideoFuture;
  VideoPlayerController _controller;
  Future<List<Sign>> _signsFuture;

  @override
  void initState() {
    _signsFuture = _dbHelper.queryAllSigns();
    _initVideoFuture = _initVideo();

    FlutterDownloader.initialize();

    super.initState();
  }

  Future<VideoPlayerController> _initVideo() async {
    _activeSign = await chooseNextSign();

    final videoFilename = _activeSign.id.toString() + ".mp4";
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
          url: _activeSign.url,
          savedDir: videoDir.path,
          showNotification: false,
          openFileFromNotification: false,
          );
      }

      controller = VideoPlayerController.network(_activeSign.url);
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

  Future<Sign> chooseNextSign() async {
    final signs = await _signsFuture;
    for (final sign in signs) {
      print(sign.description.toString() + ", " + sign.id.toString() + ", correct: " + sign.nCorrect.toString() + ", incorrect: " + sign.nIncorrect.toString());
    }

    var workableSigns = [];
    var nUnknowns = 0;
    final maxUnknowns = 5;
    for (final sign in signs) {
      if (nUnknowns >= maxUnknowns) {
        break;
      }

      workableSigns.add(sign);

      final total = sign.nCorrect + sign.nIncorrect;
      if (total == 0) {
        nUnknowns ++;
        continue;
      }
    }

    var coeffs = [];
    for (Sign sign in workableSigns) {
      final total = sign.nCorrect + sign.nIncorrect;
      var coeff = total != 0 ? sign.nIncorrect / total : 1;
      if (coeff == 1) {
        coeff = 0.95;
      } else if (coeff == 0) {
        coeff = 0.05;
      }
      coeffs.add(coeff);
    }

    // TODO: moving average!
    // Or just do moving average on the current session (not database)
    // Average on the last X times, starting with the database value populating
    // all of them
    // => so keep a "weight" instead of "nIncorrect" and "nCorrect"

    final sumCoeffs = coeffs.fold(0, (a, b) => a + b);
    final probs = coeffs.map((coeff) { return coeff / sumCoeffs; });
    print(sumCoeffs);
    print(coeffs);
    print(probs);
    //signs.map((sign) { return sign; });

    var rng = new Random();
    final chosenRand = rng.nextDouble();
    var currentCount = 0.0;
    for (int i = 0; i < probs.length; i++) {
      currentCount += probs.elementAt(i);
      if (currentCount > chosenRand) {
        return workableSigns.elementAt(i);
      }
    }

    //return workableSigns.elementAt(rng.nextInt(workableSigns.length));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  FutureBuilder _createVideoFuture() {
    return FutureBuilder<VideoPlayerController>(
      future: _initVideoFuture,
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
            return Expanded(child: Container(child: Center(child: AspectRatio(
              aspectRatio: snapshot.data.value.aspectRatio,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (snapshot.data.value.isPlaying) {
                        snapshot.data.pause();
                      } else {
                        snapshot.data.play();
                      }
                    });
                  },
                  child: VideoPlayer(snapshot.data)),
            ))));
        } else {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlashSigns'),
      ),
      body: Container(
        child: Column(children: [
          _createVideoFuture(),
          Expanded(child: Column(children: [
            Row(
              children: [
                Expanded(child: IconButton(
                  icon: Icon(Icons.highlight_off),
                  iconSize: 96,
                  color: Colors.red[700],
                  tooltip: "Answer was wrong",
                  onPressed: () {
                    setState(() {
                      _dbHelper.updateIncorrect(_activeSign.id);
                      _activeSign.nIncorrect++;
                      _initVideoFuture = _initVideo();
                    });
                  },
                )),
                Expanded(child: IconButton(
                  icon: Icon(Icons.check_circle_outline),
                  iconSize: 96,
                  color: Colors.green[700],
                  tooltip: "Answer was correct",
                  onPressed: () {
                    setState(() {
                      _dbHelper.updateCorrect(_activeSign.id);
                      _activeSign.nCorrect++;
                      _initVideoFuture = _initVideo();
                    });
                  },
                )),
              ],
            ),
            FutureBuilder(
                future: _signsFuture,
                builder: (context, AsyncSnapshot<List<Sign>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return
                      Expanded(child: Center(child: Text(
                        snapshot.data
                            .elementAt(_activeSign.id)
                            .description,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      )));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
            ),
          ]))
        ]),
      ),
    );
  }
}
