import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    l.v6('Bloc | ${bloc.runtimeType} | Created');
    super.onCreate(bloc);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    l.v5('Bloc | ${bloc.runtimeType} | Closed');
    super.onClose(bloc);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    l.d('Bloc | ${bloc.runtimeType} | ${change.currentState} -> ${change.nextState}');
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    l.w('Bloc | ${bloc.runtimeType} | $error', stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
