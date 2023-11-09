import 'package:flutter/material.dart';

import 'database_service.dart';

/// Stores information about an event
class EventInfoData with ChangeNotifier {
  int id;
  String name;
  String section;
  String fullName;
  String description;
  String instructor;
  String room;
  int length;

  EventInfoData(this.id, this.name, this.section, this.fullName,
      this.description, this.instructor, this.room, this.length);

  /// Returns a blank EventInfoData
  static Future<EventInfoData> blank() async {
    return DatabaseService().newEvent();
  }
}

extension EventDatabaseOps on EventInfoData {
  /// Saves the event data to the database
  Future<void> save() async {
    DatabaseService databaseService = DatabaseService();
    await databaseService.setEvent(
        id, name, section, fullName, description, instructor, room, length);
  }

  /// Refreshes the event data from the database
  Future<void> load() async {
    DatabaseService databaseService = DatabaseService();
    EventInfoData other = (await databaseService.getEvent(id: id)).first;
    name = other.name;
    section = other.section;
    fullName = other.fullName;
    description = other.description;
    instructor = other.instructor;
    room = other.room;
    length = other.length;
  }
}
