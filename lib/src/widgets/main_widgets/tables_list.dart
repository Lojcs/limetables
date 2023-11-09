import 'package:flutter/material.dart';
import 'package:limetables/src/data/timetables_service.dart';
import 'package:limetables/src/widgets/main_widgets/table_widget.dart';
import 'package:provider/provider.dart';

import 'settings_view.dart';

/// Displays a list of SampleItems.
class TimetablesList extends StatelessWidget {
  const TimetablesList({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
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
      body: Consumer<TimetablesService>(
        builder: (context, timetablesService, child) =>
            FutureBuilder<List<int>>(
          future: timetablesService.getTimetableIds(),
          builder: (context, snapshot) {
            int timetableCount =
                snapshot.hasData ? snapshot.data!.length + 1 : 1;
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              // itemCount: items.length,
              itemExtent: 200,
              itemCount: timetableCount,
              itemBuilder: (BuildContext context, int index) {
                if (index == timetableCount - 1) {
                  return TextButton(
                      onPressed:
                          Provider.of<TimetablesService>(context, listen: false)
                              .newTimetable,
                      child: const Text("Create Timetable?"));
                } else {
                  if (snapshot.hasData) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: SmallTableWidget(snapshot.data![index]),
                    );
                  } else {
                    return const Center();
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}
