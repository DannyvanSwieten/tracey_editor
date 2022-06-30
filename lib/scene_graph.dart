import 'package:editor/gql.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Node {
  String name = "";
  int id;
  List<int> children = [];
  Node(dynamic nodeObject)
      : name = nodeObject["name"],
        id = nodeObject["id"] {
    List<Object?> c = nodeObject["children"];
    for (int i = 0; i < c.length; ++i) {
      children.add(c[i] as int);
    }
  }
}

class Scene {
  int root = 0;
  String name;
  List<Node> nodes = [];

  Scene(dynamic sceneObject) : name = sceneObject["name"] {
    List<dynamic> entities = sceneObject["nodes"];
    for (int i = 0; i < entities.length; ++i) {
      nodes.add(Node(entities[i]));
    }
  }

  void addNode(Node node) {
    nodes[0].children.add(node.id);
    nodes.add(node);
  }
}

class SceneGraphWidget extends StatefulWidget {
  final Scene scene;
  final Function(int) onSelectionChanged;
  const SceneGraphWidget(
      {required this.scene, required this.onSelectionChanged, Key? key})
      : super(key: key);

  @override
  State<SceneGraphWidget> createState() {
    return SceneGraphState();
  }
}

class SceneGraphState extends State<SceneGraphWidget> {
  DateTime lastUpdate = DateTime.now();

  Widget buildWidgetForNode(List<Node> nodes, Node node) {
    String name = node.name;
    List<int> children = node.children;
    if (children.isEmpty) {
      return ListTile(
        enabled: true,
        dense: true,
        title: const Text("Node", style: TextStyle(fontSize: 13)),
        subtitle: Text(name.isEmpty ? "Untitled" : name),
        hoverColor: Colors.grey,
        selectedTileColor: Colors.red,
        onTap: () {
          widget.onSelectionChanged(node.id);
        },
      );
    } else {
      List<Widget> childWidgets = [];
      for (int i = 0; i < children.length; ++i) {
        childWidgets.add(buildWidgetForNode(nodes, nodes[children[i]]));
      }
      return ExpansionTile(
          leading: Icon(size: 20, Icons.add),
          textColor: Colors.white,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            "Node",
            style: TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            name.isEmpty ? "Untitled" : name,
            style: const TextStyle(fontSize: 11),
          ),
          children: childWidgets);
    }
  }

  Widget buildSceneView(Scene scene) {
    return buildWidgetForNode(scene.nodes, scene.nodes[scene.root]);
  }

  @override
  Widget build(BuildContext context) {
    return Subscription(
        options: SubscriptionOptions(document: gql(sceneChangedSubcription)),
        builder: (result) {
          if (result.data != null && result.timestamp.isAfter(lastUpdate)) {
            widget.scene.addNode(Node(result.data?["nodeAdded"]));
          }

          lastUpdate = result.timestamp;

          return Material(
            child: ListView(primary: false, children: [
              Text(textAlign: TextAlign.center, "Scene: ${widget.scene.name}"),
              buildSceneView(widget.scene)
            ]),
          );
        });
  }
}
