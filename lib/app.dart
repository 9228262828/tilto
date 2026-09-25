import 'package:flutter/material.dart';
import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class TiltoApp extends StatefulWidget {
  const TiltoApp({super.key});

  @override
  State<TiltoApp> createState() => _TiltoAppState();
}

class _TiltoAppState extends State<TiltoApp> {
  final store = TiltoStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TILTO',
          theme: tiltoTheme(Brightness.light),
          darkTheme: tiltoTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(store: store),
        );
      },
    );
  }
}
