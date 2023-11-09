import 'package:flutter/material.dart';
import 'package:limetables/src/data/events_service.dart';
import 'package:limetables/src/data/timetables_service.dart';
import 'package:limetables/src/extensions/int_extension.dart';
import 'package:limetables/src/widgets/main_widgets/event_widget.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'settings_view.dart';

/// Displays a list of SampleItems.
class LargeTableWidget extends StatelessWidget {
  final int timetableId;

  const LargeTableWidget(
    this.timetableId, {
    super.key,
  });

  static const routeName = '/table_widget';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimetableInfo>(
      future: Provider.of<TimetablesService>(context, listen: false)
          .getTimetableByID(timetableId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          TimetableInfo timetable = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Classes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to the settings page. If the user leaves and returns
                    // to the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),

            // To work with lists that may contain a large number of items, it’s best
            // to use the ListView.builder constructor.
            //
            // In contrast to the default ListView constructor, which requires
            // building all Widgets up front, the ListView.builder constructor lazily
            // builds Widgets as they’re scrolled into view.
            body: ListenableBuilder(
              listenable: timetable,
              builder: (context, child) => ListView.builder(
                // Providing a restorationId allows the ListView to restore the
                // scroll position when a user leaves and returns to the app after it
                // has been killed while running in the background.
                restorationId: 'sampleItemListView',
                itemExtent: 200,
                itemCount: timetable.events.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == timetable.events.length) {
                    return TextButton(
                        onPressed: () async {
                          EventInfo event = await Provider.of<EventsService>(
                                  context,
                                  listen: false)
                              .newEvent();
                          timetable.setEvent(event.id, 0);
                          timetable.sync();
                        },
                        child: const Text("New Event"));
                  } else {
                    int eventId = timetable.events.keys.elementAt(index);
                    int time = timetable.events[eventId]!;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Column(
                            children: [
                              Text(time.toDate()),
                              // Text("00:00"),
                              const Spacer(),
                              FutureBuilder<EventInfo>(
                                future: Provider.of<EventsService>(context,
                                        listen: false)
                                    .getEventByID(eventId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListenableBuilder(
                                      listenable: snapshot.data!,
                                      builder: (context, child) => Text(
                                          (time + snapshot.data!.length)
                                              .toDate()),
                                    );
                                  } else {
                                    return const Center();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: LargeEventWidget(eventId),
                          ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          );
        } else {
          return const Center();
        }
      },
    );
  }
}

class SmallTableWidget extends StatelessWidget {
  final int timetableId;

  const SmallTableWidget(
    this.timetableId, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimetableInfo>(
      future: Provider.of<TimetablesService>(context, listen: false)
          .getTimetableByID(timetableId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          TimetableInfo timetable = snapshot.data!;
          return ListenableBuilder(
            listenable: timetable,
            builder: (context, child) {
              Map<int, List<Tuple2<int, int>>> events =
                  timetable.getEventsSorted();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  // boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 10)],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.restorablePushNamed(
                        context, LargeTableWidget.routeName,
                        arguments: timetableId),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: events.keys
                                  .map(
                                    (e) => Column(
                                      children: events[e]!
                                          .map(
                                            (e) => SmallEventWidget(e.item1),
                                          )
                                          .toList(),
                                    ),
                                  )
                                  .toList(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center();
        }
      },
    );
  }
}
