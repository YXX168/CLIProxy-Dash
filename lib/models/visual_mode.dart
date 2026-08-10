enum VisualMode {
  console,
  energy;

  String get storageValue => name;

  static VisualMode fromStorage(String? value) {
    for (final mode in values) {
      if (mode.name == value) return mode;
    }
    return console;
  }
}
