import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/pages/accounts_page.dart';
import 'package:accounts_saver/pages/auth_page.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Themes
final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.white,
    tertiary: Colors.black,
  ),
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeState()),
        ChangeNotifierProvider(create: (context) => AccountSecurity()),
        ChangeNotifierProvider(create: (context) => AccountsState()),
        ChangeNotifierProvider(create: (context) => SearchByState()),
        ChangeNotifierProvider(create: (context) => CurrentExpandedAccount()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BioAuth _auth = BioAuth();
  bool canAuth = false;
  bool isBioActive = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    List<Object> values = await Future.wait([
      SharedPreferences.getInstance(),
      _auth.canAuthintecate(),
    ]);

    final SharedPreferences data = values[0] as SharedPreferences;
    if (mounted) {
      setState(() {
        canAuth = values[1] as bool;
        isBioActive = data.getBool(SharedPrefsKeys.biometric.value) ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeState, ThemeMode>(
      selector: (_, currentTheme) => currentTheme.themeMode,
      builder: (_, themeState, _) => Selector<AccountSecurity, Locale>(
        selector: (_, state) => state.currentLocale,
        builder: (_, currentLocale, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: currentLocale,
            title: 'Account Saver',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState,
            home: canAuth && isBioActive ? AuthPage() : const AccountsPage(),
          );
        },
      ),
    );
  }
}
