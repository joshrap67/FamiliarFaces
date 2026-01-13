import 'package:familiar_faces/providers/home_provider.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'imports/theme.dart';
import 'imports/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ListenableProvider<SavedMediaProvider>(create: (_) => SavedMediaProvider()),
        ListenableProvider<HomeProvider>(create: (_) => HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(allowEnterRouteSnapshotting: false),
              },
            ),
          ),
          home: GestureDetector(onTap: () => hideKeyboard(), child: Home()),
        ),
      ),
    );
  }
}
