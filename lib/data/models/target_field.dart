class TargetField {
  List<List<int>> grid;

  TargetField({this.grid});

  TargetField.copy(TargetField targetField) {
    this.grid = targetField.grid;
  }
}