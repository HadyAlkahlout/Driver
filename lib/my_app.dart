import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:fuodz/constants/app_theme.dart';
import 'package:fuodz/services/app.service.dart';

import 'package:fuodz/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_strings.dart';
import 'package:fuodz/services/router.service.dart' as router;

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MyApp({Key? key, this.navigatorKey}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Global key for navigator context
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use the navigator key passed from main.dart, or fallback to local one
    final navigatorKey = widget.navigatorKey ?? _navigatorKey;

    // Set the navigator key in AppService
    AppService().setNavigatorKey(navigatorKey);

    // Ensure we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppContext();
    });
  }

  void _updateAppContext() {
    final navigatorKey = widget.navigatorKey ?? _navigatorKey;
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      debugPrint('MyApp: Updated app context');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          /// 1.1.3: register the navigator key to MaterialApp
          navigatorKey: widget.navigatorKey ?? _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          onGenerateRoute: router.generateRoute,
          onUnknownRoute: (RouteSettings settings) {
            // open your app when is executed from outside when is terminated.
            return router.generateRoute(settings);
          },
          // initialRoute: _startRoute,
          localizationsDelegates: translator.delegates,
          locale: translator.activeLocale,
          supportedLocales: translator.locals(),
          home: SplashPage(),
          builder: (context, child) {
            // Update app context whenever builder is called
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                // Context is available for use
              }
            });

            return Stack(children: [child!, DropdownAlert()]);
          },
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}
