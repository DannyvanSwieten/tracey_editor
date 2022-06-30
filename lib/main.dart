import 'package:editor/asset_menu.dart';
import 'package:editor/gql.dart';
import 'package:editor/project_controller.dart';
import 'package:editor/viewport.dart';
import 'package:editor/scene_inspector.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  await initHiveForFlutter();
  final httpLink = HttpLink(
    'http://localhost:7000',
  );

  final websocketLink = WebSocketLink("ws://localhost:7000/ws");
  final link =
      Link.split((request) => request.isSubscription, websocketLink, httpLink);
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  const MyApp({required this.client, Key? key}) : super(key: key);

  Widget buildMainContainer(QueryResult result) {
    return ProjectState(
      child: Container(
          color: Colors.grey[700],
          child: Column(
            children: [
              Expanded(
                  child: Container(
                color: Colors.grey[900],
                margin: const EdgeInsets.all(1.0),
              )),
              Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.all(1.0),
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: const [AssetMenu()],
                        )),
                        Expanded(flex: 6, child: ViewPort()),
                        Expanded(
                            child: SceneState(child: SceneInspector(result))),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.all(1.0),
                  ))
            ],
          )),
    );
  }

  Widget buildQuery() {
    return Query(
        options: QueryOptions(
            document: gql(getSceneQuery), fetchPolicy: FetchPolicy.networkOnly),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(
              child: SizedBox(
                  width: 100, height: 100, child: CircularProgressIndicator()),
            );
          } else if (result.hasException) {
            return const Material(
              child: Text(
                "Server unavailable",
                textAlign: TextAlign.center,
              ),
            );
          }
          return Material(child: buildMainContainer(result));
        });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Roboto Mono',
              backgroundColor: Colors.grey[600],
            ),
            home: buildQuery()));
  }
}
