import 'dart:math';

import 'package:flashsigns/src/models/sign.dart';

class ActiveSession {
  final List<Sign> signs;

  List<Sign> _activeUnknownSigns; // List of "unknown" signs in the active session
  List<Sign> _activeKnownSigns; // List of "known" signs in the active session

  ActiveSession(final this.signs) {
    _activeUnknownSigns = _selectUnknownSigns(12);
    _activeKnownSigns = _selectKnownSigns(12);
  }

  List<Sign> _selectUnknownSigns(final int size) {
    return [];
  }

  List<Sign> _selectKnownSigns(final int size) {
    return [];
  }

  Sign nextSign() {
    final rng = new Random();
    final chosenId = rng.nextInt(signs.length);
    return signs.elementAt(chosenId);
  }
}