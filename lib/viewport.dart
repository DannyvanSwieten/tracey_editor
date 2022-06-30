import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:editor/gql.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<Socket> connectToSocket() async {
  return await Socket.connect('localhost', 8000);
}

class ViewPort extends StatefulWidget {
  final Future<Socket> socket;
  ViewPort({Key? key})
      : socket = connectToSocket(),
        super(key: key);

  @override
  State<ViewPort> createState() => ViewPortState();
}

class ViewPortState extends State<ViewPort> {
  RawImage? rawImage;
  List<int> pixels;

  ViewPortState({Key? key}) : pixels = [];

  @override
  Widget build(BuildContext context) {
    widget.socket.then((value) {
      value.listen((event) {
        pixels.addAll(event);
        if (pixels.length == 1280 * 720 * 4) {
          setState(() {
            decodeImageFromPixels(
                Uint8List.fromList(pixels), 1280, 720, PixelFormat.rgba8888,
                ((result) {
              rawImage = RawImage(
                image: result,
              );
            }));
          });

          pixels.clear();
        }
      });
    }).catchError((onError) {});

    return Mutation(
        options: MutationOptions(document: gql(createShapeMutation)),
        builder: (run, result) {
          return DragTarget<String>(
            builder: (context, candidateItems, rejectedItems) {
              if (rawImage != null) {
                return rawImage!;
              } else {
                return const Text(
                  "No image available yet",
                  textAlign: TextAlign.center,
                );
              }
            },
            onAccept: (item) {
              run({'shape': item, 'parent': 0});
            },
          );
        });
  }
}
