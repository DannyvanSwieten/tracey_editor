const String createShapeMutation = """
mutation CreateShape(\$shape: String! \$parent: Int!) {
  createBasicShape(shape: \$shape, parent: \$parent) 
  build
  render(batches: 4)
} 
""";

const String sceneChangedSubcription = """
  subscription nodeAdded {
    nodeAdded{
      name
      id
      children
    }
  }
""";

const String getSceneQuery = """
query GetScene {
  scene {
    name
    nodes{
      id
      name
      children
    }
  }
} 
""";
