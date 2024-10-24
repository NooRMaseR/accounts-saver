import 'package:shared_preferences/shared_preferences.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/pages/accounts_page.dart';
import 'package:accounts_saver/pages/auth_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Themes
final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
      primary: Colors.blue, secondary: Colors.white, tertiary: Colors.black),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: Colors.blue,
    secondary: Color.fromARGB(255, 75, 90, 102),
    tertiary: Colors.white,
  ),
  useMaterial3: true,
);

void main() async {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  databaseFactory = databaseFactoryFfi;
  runApp(EasyLocalization(
      supportedLocales: const <Locale>[
        Locale("en", "US"),
        Locale("ar", "EG"),
      ],
      path: "assets/translations",
      fallbackLocale: const Locale("en", "US"),
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode thememode = ThemeMode.system;
  final BioAuth _auth = BioAuth();
  bool? bio = false;
  bool canAuth = false;
  late SharedPreferences data;

  void _changeTheme(ThemeMode theme) {
    setState(() {
      thememode = theme;
      _changeSystemBars();
    });
  }

  void _changeSystemBars() {
    switch (thememode) {
      case ThemeMode.dark:
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black.withOpacity(.91)));

      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent));

      case ThemeMode.system:
        Brightness brightness = MediaQuery.of(context).platformBrightness;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: brightness == Brightness.light
              ? Colors.transparent
              : Colors.black.withOpacity(.91),
        ));
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    data = await SharedPreferences.getInstance();
    canAuth = await _auth.canAuthintecate();
    final String? theme = data.getString(SharedPrefsKeys.theme.value);
    bio = data.getBool(SharedPrefsKeys.biometric.value);
    setState(() {
      if (theme == "light") {
        thememode = ThemeMode.light;
      } else if (theme == "dark") {
        thememode = ThemeMode.dark;
      } else {
        thememode = ThemeMode.system;
      }
    });

    _changeSystemBars();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Account Saver',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: thememode,
      home: canAuth && bio == true
          ? AuthPage(onThemModeChange: _changeTheme)
          : AccountsPage(onThemModeChange: _changeTheme),
    );
  }
}
