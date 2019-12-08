import 'package:bloc/bloc.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_event.dart';
import 'package:flashsigns/src/blocs/working_sign/working_sign_state.dart';
import 'package:flashsigns/src/models/sign.dart';
import 'package:flashsigns/src/resources/database_helper.dart';
import 'package:meta/meta.dart';

class WorkingSignBloc extends Bloc<WorkingSignEvent, WorkingSignState> {
  final DatabaseHelper signsRepository;

  List<Sign> _signs;
  int _currentSignId = 0;

  WorkingSignBloc({@required this.signsRepository});

  @override
  WorkingSignState get initialState => WorkingSignLoading();

  @override
  Stream<WorkingSignState> mapEventToState(WorkingSignEvent event) async* {
    if (event is LoadWorkingList) {
      yield* _mapLoadWorkingListToState();
    } else if (event is MarkGoodAnswer) {
      yield* _mapMarkGoodAnswerToState(event);
    } else if (event is MarkWrongAnswer) {
      yield* _mapMarkWrongAnswerToState(event);
    }
  }

  Stream<WorkingSignState> _mapLoadWorkingListToState() async * {
    try {
      _signs = await this.signsRepository.queryAllSigns();
      final sign = _signs.elementAt(_currentSignId);
      yield WorkingSignLoaded(sign);
    } catch (_) {
      yield WorkingSignNotLoaded();
    }
  }

  Stream<WorkingSignState> _mapMarkGoodAnswerToState(MarkGoodAnswer event) async * {
    if (state is WorkingSignLoaded) {
      _currentSignId = (_currentSignId + 1) % _signs.length;
      yield WorkingSignLoaded(_signs.elementAt(_currentSignId));
    }
  }

  Stream<WorkingSignState> _mapMarkWrongAnswerToState(MarkWrongAnswer event) async * {
    if (state is WorkingSignLoaded) {
      _currentSignId = (_currentSignId - 1) % _signs.length;
      yield WorkingSignLoaded(_signs.elementAt(_currentSignId));
    }
  }
}