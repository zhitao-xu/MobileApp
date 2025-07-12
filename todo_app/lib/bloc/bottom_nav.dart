import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNav extends Cubit<int> {
  BottomNav() : super(0);

  changeSelectedIndex(newIndex) => emit(newIndex);
}