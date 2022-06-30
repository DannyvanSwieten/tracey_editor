import 'package:flutter/material.dart';

class ProjectState extends InheritedWidget {
  final Map<Key, Function(int)> onSelectionChanged;

  ProjectState({Key? key, required super.child})
      : onSelectionChanged = <Key, Function(int)>{},
        super(key: key);

  void changeNodeSelection(int id) {
    for (var callback in onSelectionChanged.values) {
      callback(id);
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
