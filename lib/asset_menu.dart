import 'package:flutter/material.dart';

class AssetMenu extends StatelessWidget {
  const AssetMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> assetTypes = <String>[
      'Primitives',
      'Lights',
      'Materials'
    ];

    final List<List<String>> assetItems = <List<String>>[
      ["Triangle", "Plane", "Cube", "Sphere", "Torus"],
      ["Directional", "Light", "Point Light", "Directional Light"],
      ["Glass", "Mirror", "PBR"],
    ];

    Widget getItemsForIndex(int index) {
      List<Widget> items = [];
      for (var element in assetItems[index]) {
        items.add(Draggable<String>(
          data: element,
          feedback: Container(
            color: Colors.grey[800],
            width: 100,
            height: 50,
          ),
          child: ListTile(title: Text(element)),
        ));
      }
      return ExpansionTile(title: Text(assetTypes[index]), children: items);
    }

    return Expanded(
        flex: 1,
        child: Material(
          child: ListView.builder(
              itemCount: assetTypes.length,
              itemBuilder: (BuildContext context, int index) {
                return getItemsForIndex(index);
              }),
        ));
  }
}
