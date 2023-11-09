extension IntExtension on int {
  /// Converts seconds since beginning of week to day HH:mm
  String toDate() {
    int daySecs = this % 86400;
    return "${daySecs ~/ 3600}:${(daySecs % 3600) ~/ 60}";
  }
}
