import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/blocs/preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();

  @override
  PreferencesState get initialState => PreferencesUnknown();

  @override
  Stream<PreferencesState> mapEventToState(PreferencesEvent event) async* {
    final _preferences = await this._preferences;

    if (event is SetUseMobileData) {
      await _preferences.setBool("useMobileData", event.useMobileData);
    }

    yield PreferencesChanged(_preferences.getBool("useMobileData") ?? false);
  }
}

