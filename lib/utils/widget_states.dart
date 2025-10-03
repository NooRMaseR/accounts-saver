import 'package:shared_preferences/shared_preferences.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  late SharedPreferences _data;

  ThemeState() {
    _getData();
  }

  void _getData() async {
    _data = await SharedPreferences.getInstance();
    final theme = _data.getString(SharedPrefsKeys.theme.value);
    switch (theme) {
      case "light":
        _themeMode = ThemeMode.light;

      case "dark":
        _themeMode = ThemeMode.dark;

      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void updateTheme(BuildContext context, ThemeMode newTheme) async {
    await _data.setString(SharedPrefsKeys.theme.value, newTheme.name);
    _themeMode = newTheme;
    switch (_themeMode) {
      case ThemeMode.dark:
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black.withValues(alpha: .91),
          ),
        );

      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
        );

      default:
        Brightness brightness = MediaQuery.of(context).platformBrightness;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: brightness == Brightness.light
                ? Colors.transparent
                : Colors.black.withValues(alpha: .91),
          ),
        );
    }
    notifyListeners();
  }
}

class SearchByState extends ChangeNotifier {
  String _searchBy = 'all';
  String get searchBy => _searchBy;

  late SharedPreferences _data;

  SearchByState() {
    _getData();
  }

  void _getData() async {
    _data = await SharedPreferences.getInstance();
    _searchBy = _data.getString(SharedPrefsKeys.searchBy.value) ?? 'all';
    notifyListeners();
  }

  void updateSearchBy(String value) async {
    await _data.setString(SharedPrefsKeys.searchBy.value, value);
    _searchBy = value;
    notifyListeners();
  }
}

class AccountSecurity extends ChangeNotifier {
  late bool _bioActive;
  late bool _hideDetails;
  late SharedPreferences _data;

  bool get isBioActive => _bioActive;
  bool get isDetailsHidden => _hideDetails;

  Locale? _currentLocale = Locale("en");
  Locale get currentLocale => _currentLocale!;
  set currentLocale(Locale? newLocale) {
    if (newLocale != null) {
      _currentLocale = newLocale;
      S.load(newLocale);
      _data.setString(SharedPrefsKeys.locale.value, newLocale.languageCode);
      notifyListeners();
    }
  }

  AccountSecurity() {
    _getData();
  }

  void _getData() async {
    _data = await SharedPreferences.getInstance();
    _bioActive = _data.getBool(SharedPrefsKeys.biometric.value) ?? false;
    _hideDetails =
        _data.getBool(SharedPrefsKeys.hideAccountDetails.value) ?? false;
    _currentLocale = Locale(
      _data.getString(SharedPrefsKeys.locale.value) ?? "en",
    );
    notifyListeners();
  }

  void updateBioActive(bool value) async {
    await _data.setBool(SharedPrefsKeys.biometric.value, value);
    _bioActive = value;
    notifyListeners();
  }

  void updateHideDetails(bool value) async {
    await _data.setBool(SharedPrefsKeys.hideAccountDetails.value, value);
    _hideDetails = value;
    notifyListeners();
  }
}

class AccountsState extends ChangeNotifier {
  final List<Account> _accounts = [];
  final List<Account> _filterdAccounts = [];
  bool _doRefresh = false;

  List<Account> get accounts => _accounts;
  List<Account> get filterdAccounts => _filterdAccounts;
  bool get doRefresh => _doRefresh;
  Sql db = Sql();

  set doRefresh(bool value) {
    _doRefresh = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  set filterdAccounts(List<Account> value) {
    if (_filterdAccounts == value) return;
    _filterdAccounts
      ..clear()
      ..addAll(value);
    notifyListeners();
  }

  Future<void> getData(BuildContext context) async {
    _accounts.clear();
    List<Map<String, Object?>> accountsFound = await db.getAccount(
      'SELECT * FROM "accounts"',
    );

    addManyAccount(
      accountsFound.map((account) => Account.fromObject(account)).toList(),
    );
  }

  void dbAddAccount(String title, String email, String password) async {
    int id = await db.addAccount(
      '''
        INSERT INTO "accounts" (`Title`, `Email`, `Password`) VALUES (?, ?, ?)
        ''',
      args: [title, email, password],
    );
    addAccount(Account(id: id, title: title, email: email, password: password));
  }

  void addAccount(Account account) {
    _accounts.add(account);
    filterdAccounts = _accounts;
  }

  void addManyAccount(List<Account> accounts) {
    _accounts.addAll(accounts);
    filterdAccounts = _accounts;
  }

  void dbRemoveAccount(Account account) async {
    await db.deleteAccount(
      '''
      DELETE FROM accounts WHERE id = ?
      ''',
      args: [account.id],
    );
    removeAccount(account.id);
  }

  void removeAccount(int id) {
    _accounts.removeWhere((element) => element.id == id);
    filterdAccounts = _accounts;
  }

  void dbUpdateAccount(
    String title,
    String email,
    String password,
    Account oldAccount,
  ) async {
    await db.updateAccount(
      '''
        UPDATE accounts SET Email = ?, Title = ?, Password = ?
        WHERE Email = ? AND Password = ? AND Title = ?
        ''',
      args: [
        email,
        title,
        password,
        oldAccount.email,
        oldAccount.password,
        oldAccount.title,
      ],
    );
    updateAccount(oldAccount.id, title, email, password);
  }

  void updateAccount(int id, String title, String email, String password) {
    int index = accounts.indexWhere((Account acc) => acc.id == id);
    accounts[index].title = title;
    accounts[index].email = email;
    accounts[index].password = password;
    filterdAccounts = _accounts;
  }
}

class CurrentExpandedAccount extends ChangeNotifier {
  int? _currentAccountId;
  int? get currentAccountId => _currentAccountId;

  set currentAccountId(int? id) {
    _currentAccountId = id;
    Future.microtask(() {
      notifyListeners();
    });
  }
}
