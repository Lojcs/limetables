
import 'package:flutter/material.dart';
import 'package:limetables/src/data/database_service.dart';
import 'package:limetables/src/data/event_info.dart';

/// Manages EventInfo across the app so that latest information is propogated
class EventsService with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Map<int, EventInfoData> _events = {};
  final List<int> _accessList = [];
  static const int _maxEventNum = 200;

  Future<EventInfo> newEvent() async {
    EventInfoData event = await EventInfoData.blank();
    _events[event.id] = event;
    _accessList.add(event.id);
    _enforceLimit();
    return EventInfo(event.id, this);
  }

  /// Returns an event by its id
  Future<EventInfo> getEventByID(int id) async {
    if (!_events.containsKey(id)) {
      EventInfoData event = (await _databaseService.getEvent(id: id)).first;
      _events[id] = event;
    }
    _accessList.remove(id);
    _accessList.add(id);
    _enforceLimit();
    return EventInfo(id, this);
  }

  /// Searches the database for events
  Future<List<EventInfo>> searchEvents(
      {String? name,
      String? section,
      String? instructor,
      String? room,
      int? length}) async {
    List<EventInfo> eventInfos = [];
    List<EventInfoData> events = await _databaseService.getEvent(
        name: name,
        section: section,
        instructor: instructor,
        room: room,
        length: length);
    for (EventInfoData event in events) {
      _events[event.id] = event;
      _accessList.remove(event.id);
      _accessList.add(event.id);
      eventInfos.add(EventInfo(event.id, this));
    }
    _enforceLimit();
    return eventInfos;
  }

  /// Refreshes the specified event, or all events in cache.
  Future<void> refreshData({int? eventId}) async {
    if (eventId != null) {
      if (_events.containsKey(eventId)) {
        _events[eventId]!.load();
      } else {
        throw "Id not found in cache.";
      }
    } else {
      for (int id in _events.keys) {
        _events[id]!.load();
      }
    }
  }

  void _enforceLimit() {
    while (_events.length > _maxEventNum) {
      _events.remove(_accessList.removeAt(0));
    }
  }
}

/// Provides information about an event.
class EventInfo implements EventInfoData {
  @override
  final int id;
  final EventsService _service;
  final List<Future> _tasks = [];

  EventInfo(this.id, this._service);

  Future<void> sync() async {
    Future.wait(_tasks);
  }

  @override
  set id(int? id) => throw "Don't change ids.";

  @override
  String get name => _service._events[id]!.name;
  @override
  set name(String name) {
    _service._events[id]!.name = name;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  String get section => _service._events[id]!.section;
  @override
  set section(String section) {
    _service._events[id]!.section = section;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  String get fullName => _service._events[id]!.fullName;
  @override
  set fullName(String fullName) {
    _service._events[id]!.fullName = fullName;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  String get description => _service._events[id]!.description;
  @override
  set description(String description) {
    _service._events[id]!.description = description;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  String get instructor => _service._events[id]!.instructor;
  @override
  set instructor(String instructor) {
    _service._events[id]!.instructor = instructor;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  String get room => _service._events[id]!.room;
  @override
  set room(String room) {
    _service._events[id]!.room = room;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  int get length => _service._events[id]!.length;
  @override
  set length(int length) {
    _service._events[id]!.length = length;
    _tasks.add(_service._events[id]!.save());
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _service._events[id]!.addListener(listener);
  }

  @override
  void dispose() {}

  @override
  bool get hasListeners => _service._events[id]!.hasListeners;

  @override
  void notifyListeners() {
    _service._events[id]!.notifyListeners();
  }

  @override
  void removeListener(VoidCallback listener) {
    _service._events[id]!.removeListener(listener);
  }
}
