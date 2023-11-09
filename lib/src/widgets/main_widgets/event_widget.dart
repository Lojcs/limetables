import 'package:flutter/material.dart';
import 'package:limetables/src/data/events_service.dart';
import 'package:provider/provider.dart';

import '../misc_widgets.dart';

class LargeEventWidget extends StatefulWidget {
  final int eventId;
  const LargeEventWidget(this.eventId, {super.key});

  @override
  State<StatefulWidget> createState() => _LargeEventWidget();
}

class _LargeEventWidget extends State<LargeEventWidget> {
  // @override
  // void initState() {}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventInfo>(
      future: Provider.of<EventsService>(context, listen: false)
          .getEventByID(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          EventInfo event = snapshot.data!;
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
                // onTap: () => Navigator.restorablePushNamed(
                //   context,
                //   SampleItemDetailsView.routeName,
                // ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      CustomTextField(
                        size: TextFieldSize.large,
                        hintText: "Class Name",
                        initialValue: event.name,
                        onChanged: (value) async {
                          event.name = value;
                          event.sync();
                        },
                      ),
                      CustomTextField(
                        hintText: "Section",
                        initialValue: event.section,
                        onChanged: (value) async {
                          event.section = value;
                          event.sync();
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: "Room",
                              initialValue: event.room,
                              onChanged: (value) async {
                                event.room = value;
                                event.sync();
                              },
                            ),
                          ),
                          Expanded(
                            child: CustomTextField(
                              hintText: "Instructor",
                              initialValue: event.instructor,
                              onChanged: (value) async {
                                event.instructor = value;
                                event.sync();
                              },
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomTextField(
                          size: TextFieldSize.small,
                          numberKeyboard: true,
                          hintText: "Length (mins)",
                          initialValue: (event.length ~/ 60).toString(),
                          onChanged: (value) async {
                            event.length = (int.tryParse(value) ?? 0) * 60;
                            event.sync();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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

class SmallEventWidget extends StatelessWidget {
  final int eventId;

  const SmallEventWidget(
    this.eventId, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventInfo>(
      future: Provider.of<EventsService>(context, listen: false)
          .getEventByID(eventId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          EventInfo event = snapshot.data!;
          return Container(
            height: 10,
            width: 10,
            color: Colors.blue,
          );
        } else {
          return const Center();
        }
      },
    );
  }
}
