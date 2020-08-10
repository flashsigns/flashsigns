import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flashsigns/src/blocs/blocs.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  StreamSubscription _connectivityStream;

  ConnectivityBloc() : super(ConnectivityUnknown());

  @override
  Stream<ConnectivityState> mapEventToState(event) async* {
    if (event is SubscribeConnectivity) {
      _connectivityStream ??= Connectivity().onConnectivityChanged.listen((result) => add(ConnectivityChanged(result)));

      if (state is ConnectivityUnknown) {
        add(ConnectivityChanged(await Connectivity().checkConnectivity()));
      }
    } else if (event is ConnectivityChanged) {
      yield* _mapConnectivityChangedToState(event);
    } else if (event is UnsubscribeConnectivity) {
      _connectivityStream?.cancel();
    }
  }

  Stream<ConnectivityState> _mapConnectivityChangedToState(ConnectivityChanged event) async * {
    switch (event.connectivityResult) {
      case ConnectivityResult.none:
        yield ConnectivityNone();
        break;
      case ConnectivityResult.mobile:
        yield ConnectivityMobile();
        break;
      case ConnectivityResult.wifi:
        yield ConnectivityWifi();
        break;
    }
  }
}