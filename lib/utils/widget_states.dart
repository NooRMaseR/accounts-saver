import 'package:shared_preferences/shared_preferences.dart';
import 'package:accounts_saver/models/common_values.dart';
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
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black.withValues(alpha: .91)));

      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent));

      default:
        Brightness brightness = MediaQuery.of(context).platformBrightness;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: brightness == Brightness.light
              ? Colors.transparent
              : Colors.black.withValues(alpha: .91),
        ));
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
  bool _bioActive = false;
  bool _hideDetails = false;
  late SharedPreferences _data;

  bool get isBioActive => _bioActive;
  bool get isDetailsHidden => _hideDetails;

  AccountSecurity() {
    _getData();
  }

  void _getData() async {
    _data = await SharedPreferences.getInstance();
    _bioActive = _data.getBool(SharedPrefsKeys.biometric.value) ?? false;
    _hideDetails =
        _data.getBool(SharedPrefsKeys.hideAccountDetails.value) ?? false;
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
  List<Account> get accounts => _accounts;
  Sql db = Sql();


  void dbAddAccount(String title, String email, String password) async {
    int id = await db.addAccount('''
        INSERT INTO "accounts" (`Title`, `Email`, `Password`) VALUES ("$title", "$email", "$password")
        ''');
    addAccount(Account(id: id, title: title, email: email, password: password));
  }

  void addAccount(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  void addManyAccount(List<Account> accounts) {
    _accounts.addAll(accounts);
    notifyListeners();
  }

  void dbRemoveAccount(Account account) async {
    await db.deleteAccount('''
      DELETE FROM "accounts" WHERE (id=${account.id})
      ''');
    removeAccount(account.id);
  }

  void removeAccount(int id) {
    _accounts.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void dbUpdateAccount(
      String title, String email, String password, Account oldAccount) async {
    await db.updateAccount('''
        UPDATE accounts SET "Email"="$email", "Title"="$title", Password="$password"
        WHERE "Email"="${oldAccount.email}" AND "Password"="${oldAccount.password}" AND "Title"="${oldAccount.title}"
        ''');
    updateAccount(oldAccount.id, title, email, password);
  }

  void updateAccount(int id, String title, String email, String password) {
    int index = accounts.indexWhere((Account acc) => acc.id == id);
    accounts[index].title = title;
    accounts[index].email = email;
    accounts[index].password = password;
    notifyListeners();
  }
}

class CurrentExpandedAccount extends ChangeNotifier {
  int _currentAccountId = -1;
  int _previosAccountId = -1;

  int get currentAccountId => _currentAccountId;
  int get previosAccountId => _previosAccountId;

  void setCurrentAccountID(int id) {
    final i = _currentAccountId;
    _currentAccountId = id;
    if (_previosAccountId != i) {
      _previosAccountId = i;
    } 
    if (_previosAccountId == _currentAccountId) {
      _previosAccountId = -1;
    }
    notifyListeners();
  }
}
