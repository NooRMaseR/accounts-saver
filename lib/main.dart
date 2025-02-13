import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/pages/accounts_page.dart';
import 'package:accounts_saver/pages/auth_page.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:provider/provider.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
  final BioAuth _auth = BioAuth();
  bool canAuth = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    canAuth = await _auth.canAuthintecate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeState>(
        builder: (context, themeState, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              title: 'Account Saver',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeState.themeMode,
              home:
                  canAuth && Provider.of<AccountSecurity>(context).isBioActive ? AuthPage() : AccountsPage(),
            ));
  }
}
