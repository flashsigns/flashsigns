import 'dart:async';

import 'package:flashsigns/src/models/download_task_info.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tuple/tuple.dart';

class Downloader {
  static final Downloader _instance = Downloader._privateConstructor();
  static bool _isDownloaderInitialized = false;

  static Map<String, Tuple2<DownloadTaskInfo, Completer<DownloadTaskInfo>>> _queuedTasks = {};

  Downloader._privateConstructor();

  static Future<Downloader> getInstance() async {
    if (!_isDownloaderInitialized) {
      _isDownloaderInitialized = true;
      await FlutterDownloader.initialize();
      await FlutterDownloader.registerCallback(_downloadCallback);
    }

    return _instance;
  }

  static void _downloadCallback(
      final String id,
      final DownloadTaskStatus status,
      final int progress) {
    final downloadTaskInfo = _queuedTasks[id].item1;
    final completer = _queuedTasks[id].item2;

    // TODO What about the isolate? The callback is called from the background, not sure what this implies on the Completer

    if (status == DownloadTaskStatus.complete) {
      completer.complete(downloadTaskInfo);
    } else {
      // TODO
    }
  }

  Future<DownloadTaskInfo> download(final String fileName, final String url, final String savedDir) async {
    Completer<DownloadTaskInfo> completer = Completer<DownloadTaskInfo>();

    return FlutterDownloader
        .enqueue(
        fileName: fileName,
        url: url,
        savedDir: savedDir,
    showNotification: false,
    openFileFromNotification: false,
    ).then((String taskId) {
      final downloadTaskInfo = DownloadTaskInfo(id: taskId);
      _queuedTasks[taskId] = Tuple2(downloadTaskInfo, completer);
      return completer.future;
    });
  }
}