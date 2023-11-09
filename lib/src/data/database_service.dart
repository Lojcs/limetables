import 'package:limetables/src/data/event_info.dart';
import 'package:limetables/src/data/timetable_info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  late Future<Database> database = initDb();
  Future<Database> initDb() async {
    var documentsDirectory = await getDatabasesPath();
    var path = join(documentsDirectory, "events.db");
    var theDb = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database database, int version) async {
    await database.execute(
        """CREATE TABLE events (id INTEGER PRIMARY KEY, name TEXT DEFAULT '',
        section TEXT DEFAULT '', full_name TEXT DEFAULT '', description TEXT DEFAULT '',
        instructor TEXT DEFAULT '', room TEXT DEFAULT '', length INTEGER DEFAULT 0)""");
    await database.execute(
        """CREATE INDEX event_name_index ON events (name COLLATE NOCASE, section COLLATE NOCASE)
    """);
    await database.execute(
        """CREATE TABLE timetables (id INTEGER PRIMARY KEY, name TEXT DEFAULT '',
        description TEXT DEFAULT '', first_day INTEGER DEFAULT 0, repeat_period INTEGER DEFAULT 0,
        events TEXT DEFAULT '')""");
  }

  void _onUpgrade(Database database, int oldVersion, int newVersion) async {}

  Future<List<EventInfoData>> getEvent(
      {int? id,
      String? name,
      String? section,
      String? instructor,
      String? room,
      int? length}) async {
    Database db = await database;
    List<String> query = [
      "SELECT id, name, section, full_name, description, instructor, room, length FROM events WHERE"
    ];

    List<String> filters = [];
    List<dynamic> arguements = [];
    if (id != null) {
      filters.add("id = ?");
      arguements.add(id);
    }
    if (name != null) {
      filters.add("name LIKE ?");
      arguements.add(name);
    }
    if (section != null) {
      filters.add("section LIKE ?");
      arguements.add(section);
    }
    if (instructor != null) {
      filters.add("instructor LIKE ?");
      arguements.add(instructor);
    }
    if (room != null) {
      filters.add("room LIKE ?");
      arguements.add(room);
    }
    if (length != null) {
      filters.add("length = ?");
      arguements.add(length);
    }
    query.add(filters.join(", "));

    List<Map<String, dynamic>> result =
        await db.rawQuery(query.join(" "), arguements);
    List<EventInfoData> events = [];
    for (Map<String, dynamic> event in result) {
      events.add(EventInfoData(
          event["id"],
          event["name"],
          event["section"],
          event["full_name"],
          event["description"],
          event["instructor"],
          event["room"],
          event["length"]));
    }
    return events;
  }

  Future<int> setEvent(int id, String name, String section, String fullName,
      String description, String instructor, String room, int length) async {
    Database db = await database;
    return db.rawInsert(
        "INSERT OR REPLACE INTO events (id, name, section, full_name, description, instructor, room, length) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        [id, name, section, fullName, description, instructor, room, length]);
  }

  Future<EventInfoData> newEvent() async {
    Database db = await database;
    int id = await db.rawInsert("INSERT INTO events DEFAULT VALUES");
    return EventInfoData(id, "", "", "", "", "", "", 0);
  }

  Future<List<TimetableInfoData>> getTimetable({int? id, String? name}) async {
    Database db = await database;
    List<String> query = [
      "SELECT id, name, description, first_day, repeat_period, events FROM timetables"
    ];

    List<String> filters = [];
    List<dynamic> arguements = [];
    if (id != null || name != null) {
      query.add("WHERE");
    }
    if (id != null) {
      filters.add("id = ?");
      arguements.add(id);
    }
    if (name != null) {
      filters.add("name LIKE ?");
      arguements.add(name);
    }
    query.add(filters.join(", "));

    List<Map<String, dynamic>> result =
        await db.rawQuery(query.join(" "), arguements);
    List<TimetableInfoData> timetables = [];
    for (Map<String, dynamic> timetable in result) {
      Map<int, int> events = {};
      String eventsString = timetable["events"];
      if (eventsString != "") {
        List<String> eventsList = eventsString.split(",");
        for (String event in eventsList) {
          List<String> eventData = event.split(":");
          events[int.parse(eventData[0])] = int.parse(eventData[1]);
        }
      }
      timetables.add(TimetableInfoData(
          timetable["id"],
          timetable["name"],
          timetable["description"],
          timetable["first_day"],
          timetable["repeat_period"],
          events));
    }
    return timetables;
  }

  Future<List<int>> getTimetableIds() async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT id FROM timetables");
    return result.map((e) => e['id'] as int).toList();
  }

  Future<int> setTimetable(int id, String name, String description,
      int firstDay, int repeatPeriod, Map<int, int> events) async {
    Database db = await database;
    List<String> eventsList = [];
    events.forEach((key, value) {
      eventsList.add([key, value].join(":"));
    });
    String eventsString = eventsList.join(",");
    return db.rawInsert(
        "INSERT OR REPLACE INTO timetables (id, name, description, first_day, repeat_period, events) VALUES (?, ?, ?, ?, ?, ?)",
        [id, name, description, firstDay, repeatPeriod, eventsString]);
  }

  Future<TimetableInfoData> newTimetable() async {
    Database db = await database;
    int id = await db.rawInsert("INSERT INTO timetables DEFAULT VALUES");
    return TimetableInfoData(id, "", "", 0, 0, {});
  }
}
