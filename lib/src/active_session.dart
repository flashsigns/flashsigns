import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flashsigns/src/models/sign.dart';
import 'package:flashsigns/src/resources/database_helper.dart';
import 'package:meta/meta.dart';

class ActiveSession {
  final DatabaseHelper signsRepository;
  List<Sign> _signs;

  List<Sign> _activeUnknownSigns; // Window of "unknown" signs in _signs
  List<Sign> _activeKnownSigns; // Window of "known" signs in _signs
  final int _listSize = 12;

  ActiveSession({@required this.signsRepository});

  Future init() async {
    print("Initializing session...");

    _signs = await this.signsRepository.queryAllSigns();
    print("Number of signs loaded: ${_signs.length}");

    _activeUnknownSigns = _selectUnknownSigns(_listSize);
    _activeKnownSigns = _selectKnownSigns(_listSize);
    await _fillWithNewSigns(_activeUnknownSigns);

    print("---");
    print("All signs:");
    for (final sign in _signs) {
      print(sign.description.toString() + ", score: " + sign.score.toString());
    }

    print("---");
    print("Known signs:");
    for (final sign in _activeKnownSigns) {
      print(sign.description.toString() + ", score: " + sign.score.toString());
    }

    print("---");
    print("Unknown signs:");
    for (final sign in _activeUnknownSigns) {
      print(sign.description.toString() + ", score: " + sign.score.toString());
    }
  }

  List<Sign> _selectUnknownSigns(final int size) {
    return _takeWhere(size, (sign) => sign.score <= 2 && sign.score > 0);
  }

  List<Sign> _takeWhere(final int size, bool predicate(Sign element), {bool shuffle = true}) {
    var unusedSigns;

    // If _activeUnknownSigns and _activeKnownSigns exist, remove them from
    // _signs before selecting new ones. So that we don't get duplicates in the
    // active list.
    // TODO: find a better way to do that.
    if (_activeKnownSigns != null && _activeUnknownSigns != null) {
    unusedSigns = _signs.where((elem) => !_activeUnknownSigns.any((activeElem) => elem.id == activeElem.id))
                        .where((elem) => !_activeKnownSigns.any((activeElem) => elem.id == activeElem.id));
    } else {
      unusedSigns = _signs;
    }

    var filteredList = unusedSigns.where(predicate).toList();
    if (shuffle) { filteredList.shuffle(); }

    return filteredList.take(size)
                       .toList();
  }

  Future _fillWithNewSigns(List<Sign> targetList) async {
    // TODO: use connectivityBloc!
    final connectivityStatus = await Connectivity().checkConnectivity();

    if (connectivityStatus != ConnectivityResult.wifi) {
      print("No WiFi connection: not adding new sign");
      return;
    }

    final nActiveNewSigns = targetList.where((elem) => elem.score <= 0).length;
    final nRemainingNewSigns = 3 - nActiveNewSigns;
    final nSpotsForNewSigns = min(nRemainingNewSigns, _listSize - targetList.length);
    targetList.addAll(_selectNewSigns(nSpotsForNewSigns));
  }

  List<Sign> _selectNewSigns(final int size) {
    return _takeWhere(size, (sign) => sign.score <= 0, shuffle: false);
  }

  List<Sign> _selectKnownSigns(final int size) {
    return _takeWhere(size, (sign) => sign.score >= 3);
  }

  Sign nextSign() {
    final rng = new Random();
    var chosenList;

    do {
      chosenList = rng.nextDouble() < 0.4 ? _activeUnknownSigns : _activeKnownSigns;
    } while (chosenList.length == 0);

    return chosenList.elementAt(rng.nextInt(chosenList.length));
  }

  Future markCorrect(final Sign sign) async {
    if (sign.score >= 4) {
      _activeKnownSigns.removeWhere((elem) => elem.id == sign.id);
      _refillList(_activeKnownSigns, _selectKnownSign);

      _activeUnknownSigns.removeWhere((elem) => elem.id == sign.id);
      _refillList(_activeUnknownSigns, _selectUnknownSign);
      await _fillWithNewSigns(_activeUnknownSigns);
    } else {
      updateScore(sign, sign.score + 1);
    }
  }

  Sign _selectKnownSign() {
    return _selectKnownSigns(1).first;
  }

  Sign _selectUnknownSign() {
    return _selectUnknownSigns(1).first;
  }

  void _refillList(List<Sign> targetList, Sign fetchNewSign()) {
    while (targetList.length < _listSize) {
      try {
        targetList.add(fetchNewSign());
      } catch (_) {
        print("No more candidates!");
        break;
      }
    }
  }

  void updateScore(final Sign sign, final int newScore) {
    var signToUpdate = _signs.firstWhere((elem) => elem.id == sign.id);
    signToUpdate.score = (newScore).clamp(1, 4);
    signsRepository.updateScore(signToUpdate.id, signToUpdate.score);
  }

  void markWrong(final Sign sign) {
    updateScore(sign, sign.score - 1);
  }
}