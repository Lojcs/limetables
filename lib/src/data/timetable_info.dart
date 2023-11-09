import 'package:flutter/material.dart';

import 'database_service.dart';

class TimetableInfoData with ChangeNotifier {
  int id;
  String name;
  String description;
  int firstDay;
  int repeatPeriod;

  /// Id: time, where time is seconds since start of week.
  Map<int, int> events;

  TimetableInfoData(this.id, this.name, this.description, this.firstDay,
      this.repeatPeriod, this.events);

  /// Returns a blank TimeableInfoData
  static Future<TimetableInfoData> blank() async {
    return DatabaseService().newTimetable();
  }
}

extension EventDatabaseOps on TimetableInfoData {
  /// Saves the event data to the database
  Future<void> save() async {
    DatabaseService databaseService = DatabaseService();
    await databaseService.setTimetable(
        id, name, description, firstDay, repeatPeriod, events);
  }

  /// Refreshes the event data from the database
  Future<void> load() async {
    DatabaseService databaseService = DatabaseService();
    TimetableInfoData other =
        (await databaseService.getTimetable(id: id)).first;
    name = other.name;
    description = other.description;
    firstDay = other.firstDay;
    repeatPeriod = other.repeatPeriod;
    events = other.events;
  }
}
