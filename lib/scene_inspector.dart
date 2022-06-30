import 'package:editor/scene_graph.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SceneState extends InheritedWidget {
  int? selectedNode;

  SceneState({Key? key, required super.child}) : super(key: key);

  @override
  bool updateShouldNotify(covariant SceneState oldWidget) {
    return true;
  }

  void selectNode(int id) {
    selectedNode = id;
  }
}

class SceneInspector extends StatefulWidget {
  final Scene scene;
  SceneInspector(QueryResult<Object?> sceneResult, {Key? key})
      : scene = Scene(sceneResult.data?["scene"]),
        super(key: key);

  @override
  State<SceneInspector> createState() {
    return SceneInspectorState();
  }
}

class SceneInspectorState extends State<SceneInspector> {
  @override
  Widget build(BuildContext context) {
    final SceneState? inspector =
        context.dependOnInheritedWidgetOfExactType<SceneState>();

    int? selected = inspector?.selectedNode;
    return Expanded(
        child: Column(children: [
      Expanded(
          flex: 3,
          child: SceneGraphWidget(
            scene: widget.scene,
            onSelectionChanged: (int id) {
              inspector?.selectNode(id);
              setState(() {});
            },
          )),
      Expanded(
        child: Text(selected == null ? "Node Inspector" : selected.toString()),
      )
    ]));
  }
}
