
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'database_service.dart';
import 'timetable_info.dart';

class TimetablesService with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Map<int, TimetableInfoData> _timetables = {};
  final List<int> _accessList = [];
  static const int _maxTimetableNum = 200;

  Future<TimetableInfo> newTimetable() async {
    TimetableInfoData timetable = await TimetableInfoData.blank();
    _timetables[timetable.id] = timetable;
    _accessList.add(timetable.id);
    _enforceLimit();
    notifyListeners();
    return TimetableInfo(timetable.id, this);
  }

  /// Returns an timetable by its id
  Future<TimetableInfo> getTimetableByID(int id) async {
    if (!_timetables.containsKey(id)) {
      TimetableInfoData timetable =
          (await _databaseService.getTimetable(id: id)).first;
      _timetables[id] = timetable;
    }
    _accessList.remove(id);
    _accessList.add(id);
    _enforceLimit();
    return TimetableInfo(id, this);
  }

  /// Direct timetable access (unsafe)
  TimetableInfo operator [](int id) => TimetableInfo(id, this);

  /// Get all timetable ids from database
  Future<List<int>> getTimetableIds() async =>
      _databaseService.getTimetableIds();

  /// Searches the database for timetable
  Future<List<TimetableInfo>> searchTimetables({String? name}) async {
    List<TimetableInfo> timetableInfos = [];
    List<TimetableInfoData> timetables =
        await _databaseService.getTimetable(name: name);
    for (TimetableInfoData timetable in timetables) {
      _timetables[timetable.id] = timetable;
      _accessList.remove(timetable.id);
      _accessList.add(timetable.id);
      timetableInfos.add(TimetableInfo(timetable.id, this));
    }
    _enforceLimit();
    return timetableInfos;
  }

  /// Refreshes the specified event, or all events in cache.
  Future<void> refreshData({int? timetableId}) async {
    if (timetableId != null) {
      if (_timetables.containsKey(timetableId)) {
        _timetables[timetableId]!.load();
      } else {
        throw "Id not found in cache.";
      }
    } else {
      for (int id in _timetables.keys) {
        _timetables[id]!.load();
      }
    }
  }

  void _enforceLimit() {
    while (_timetables.length > _maxTimetableNum) {
      _timetables.remove(_accessList.removeAt(0));
    }
  }
}

/// Provides information about an event.
class TimetableInfo implements TimetableInfoData {
  @override
  final int id;
  final TimetablesService _service;
  final List<Future> _tasks = [];

  TimetableInfo(this.id, this._service);

  Future<void> sync() async {
    Future.wait(_tasks);
  }

  @override
  set id(int? id) => throw "Don't change ids.";

  @override
  String get name => _service._timetables[id]!.name;
  @override
  set name(String name) {
    _service._timetables[id]!.name = name;
    _tasks.add(_service._timetables[id]!.save());
  }

  @override
  String get description => _service._timetables[id]!.description;
  @override
  set description(String description) {
    _service._timetables[id]!.description = description;
    _tasks.add(_service._timetables[id]!.save());
    notifyListeners();
  }

  @override
  int get firstDay => _service._timetables[id]!.firstDay;
  @override
  set firstDay(int firstDay) {
    _service._timetables[id]!.firstDay = firstDay;
    _tasks.add(_service._timetables[id]!.save());
    notifyListeners();
  }

  @override
  int get repeatPeriod => _service._timetables[id]!.repeatPeriod;
  @override
  set repeatPeriod(int repeatPeriod) {
    _service._timetables[id]!.repeatPeriod = repeatPeriod;
    _tasks.add(_service._timetables[id]!.save());
    notifyListeners();
  }

  @override
  Map<int, int> get events => _service._timetables[id]!.events;
  @override
  set events(Map<int, int> events) {
    _service._timetables[id]!.events = events;
    _tasks.add(_service._timetables[id]!.save());
    notifyListeners();
  }

  void setEvent(int eventId, int time) {
    _service._timetables[id]!.events[eventId] = time;
    _tasks.add(_service._timetables[id]!.save());
    notifyListeners();
  }

  /// Returns eventId, start time pairs sorted by time.
  Map<int, List<Tuple2<int, int>>> getEventsSorted() {
    Map<int, List<Tuple2<int, int>>> sortedEvents = {};
    for (MapEntry<int, int> event in events.entries) {
      if (sortedEvents.containsKey(event.value % 86400)) {
        sortedEvents[event.value ~/ 86400]!.add(Tuple2(event.key, event.value));
      } else {
        sortedEvents[event.value ~/ 86400] = [Tuple2(event.key, event.value)];
      }
    }
    for (int day in sortedEvents.keys) {
      sortedEvents[day]!.sort((a, b) {
        int compare = a.item2.compareTo(b.item2);
        if (compare == 0) {
          compare = a.item1.compareTo(b.item1);
        }
        return compare;
      });
    }
    return sortedEvents;
  }

  @override
  void addListener(VoidCallback listener) {
    _service._timetables[id]!.addListener(listener);
  }

  @override
  void dispose() {}

  @override
  bool get hasListeners => _service._timetables[id]!.hasListeners;

  @override
  void notifyListeners() {
    _service._timetables[id]!.notifyListeners();
  }

  @override
  void removeListener(VoidCallback listener) {
    _service._timetables[id]!.removeListener(listener);
  }
}
