import 'dart:io';

import 'package:flashsigns/src/models/video.dart';

class VideosRepository {
  VideosRepository._privateConstructor();
  static final VideosRepository instance = VideosRepository._privateConstructor();

  // TODO: when asking for a video, either find it on the filesystem or download it
  Future<File> fetchVideo(final Video video) async {
    return null;
  }
}