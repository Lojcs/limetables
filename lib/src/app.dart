import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:limetables/src/extensions/context_extension.dart';
import 'package:limetables/src/settings/app_theme.dart';
import 'package:provider/provider.dart';

import 'widgets/main_widgets/table_widget.dart';
import 'widgets/main_widgets/tables_list.dart';
import 'settings/settings_controller.dart';
import 'widgets/main_widgets/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.

    return Selector<SettingsController, ThemeMode>(
      selector: (context, settingsController) => settingsController.themeMode,
      builder: (context, value, child) => MaterialApp(
        // Providing a restorationScopeId allows the Navigator built by the
        // MaterialApp to restore the navigation stack when a user leaves and
        // returns to the app after it has been killed while running in the
        // background.
        restorationScopeId: 'app',

        // Provide the generated AppLocalizations to the MaterialApp. This
        // allows descendant Widgets to display the correct translations
        // depending on the user's locale.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],

        // Use AppLocalizations to configure the correct application title
        // depending on the user's locale.
        //
        // The appTitle is defined in .arb files found in the localization
        // directory.
        onGenerateTitle: (BuildContext context) =>
            "${context.strings.appTitle} ${context.strings.appVersion}",

        // Define a light and dark color theme. Then, read the user's
        // preferred ThemeMode (light, dark, or system default) from the
        // SettingsController to display the correct theme.
        theme: LimetablesTheme.lightTheme,
        darkTheme: LimetablesTheme.darkTheme,
        themeMode: value,

        // Define a function to handle named routes in order to support
        // Flutter web url navigation and deep linking.
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case SettingsView.routeName:
                  return SettingsView(controller: settingsController);
                case LargeTableWidget.routeName:
                  return LargeTableWidget(routeSettings.arguments as int);
                default:
                  return const TimetablesList();
              }
            },
          );
        },
      ),
    );
  }
}
