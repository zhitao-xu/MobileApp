import 'package:flutter/material.dart';

abstract class BlocBase{   
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  const BlocProvider({
    super.key,
    required this.child,
    required this.bloc,
  });

  final T bloc;
  final Widget child;

  @override
  _BlockProviderState<T> createState() => _BlockProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context){
    BlocProvider<T> provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>()!;
    return provider.bloc;
  }
}

class _BlockProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}