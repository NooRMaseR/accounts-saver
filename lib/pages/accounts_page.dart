import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:accounts_saver/components/custom_appbar.dart';
import 'package:accounts_saver/components/account_card.dart';
import 'package:accounts_saver/pages/add_account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:accounts_saver/pages/settings_page.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  final void Function(ThemeMode) onThemModeChange;
  const AccountsPage({super.key, required this.onThemModeChange});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final Sql db = Sql();
  List<Account> accounts = [];
  List<Account> _filterdAccounts = [];
  late Future<List<Account>> _futuredAccounts;
  String searchBy = SharedPrefsKeys.all.value;
  final FocusNode _searchBarFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late final SharedPreferences _data;
  bool isDetailsHidden = false;

  @override
  void initState() {
    initData();
    _futuredAccounts = getData();
    super.initState();
  }

  Future<List<Account>> getData() async {
    accounts.clear();
    _filterdAccounts.clear();
    List<Map<String, Object?>> accountsFound =
        await db.getAccount('SELECT * FROM "accounts"');
    for (Map<String, Object?> account in accountsFound) {
      accounts.add(Account.fromObject(account));
    }

    try {
      setState(() {
        _filterdAccounts = accounts;
      });
    } catch (e) {
      _filterdAccounts = accounts;
    }

    return _filterdAccounts;
  }

  Future<void> initData() async {
    _data = await SharedPreferences.getInstance();
    bool? hide = _data.getBool(SharedPrefsKeys.hideAccountDetails.value);

    if (hide == true) {
      setState(() {
        isDetailsHidden = true;
      });
    }
  }

  void onRestoreBackup(List<Account> backupAccounts) {
    setState(() {
      accounts.addAll(backupAccounts);
    });
  }

  Future<void> onEdit(Account oldAccount, TextEditingController title,
      TextEditingController email, TextEditingController password) async {
    await db.updateAccount('''
          UPDATE accounts SET "Email"="${email.text}", "Title"="${title.text}", Password="${password.text}"
          WHERE "Email"="${oldAccount.email}" AND "Password"="${oldAccount.password}" AND "Title"="${oldAccount.title}"
          ''');
    Navigator.of(context).pop();
    int index = accounts.indexWhere((Account acc) => acc.id == oldAccount.id);
    setState(() {
      accounts[index].title = title.text;
      accounts[index].email = email.text;
      accounts[index].password = password.text;
    });
  }

  Future<void> setHideDetails(bool active) async {
    await _data.setBool(SharedPrefsKeys.hideAccountDetails.value, active);
    setState(() {
      isDetailsHidden = active;
    });
  }

  Future<void> addAccount(TextEditingController title,
      TextEditingController email, TextEditingController password) async {
    if (title.text.isNotEmpty &&
        email.text.isNotEmpty &&
        password.text.isNotEmpty) {
      int id = await db.addAccount('''
        INSERT INTO "accounts" (`Title`, `Email`, `Password`) VALUES ("${title.text}", "${email.text}", "${password.text}")
        ''');

      setState(() {
        accounts.add(Account(
            id: id,
            title: title.text,
            email: email.text,
            password: password.text));
      });

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger
      .of(context)
      .showSnackBar(
        SnackBar(
          content: Text("fill_missing_fileds".tr()),
          showCloseIcon: true,
        )
      );
    }
  }

  Future<void> deleteAccount(Account account) async {
    await db.deleteAccount('''
      DELETE FROM "accounts" WHERE (id=${account.id})
      ''');
    setState(() {
      accounts.removeWhere((Account acc) => acc.id == account.id);
    });
  }

  Future<void> _setAccounts(String query) async {
    List<Account> accountsFound = await _searchData(query);
    if (accountsFound.isEmpty) {
      setState(() {
        _filterdAccounts = accounts;
      });
    } else {
      setState(() {
        _filterdAccounts = accountsFound;
      });
    }
  }

  Future<List<Account>> _searchData(String query) async {
    query = query.toLowerCase();
    return accounts.where((Account account) {
      if (searchBy == SharedPrefsKeys.emailType.value) {
        return account.title.toLowerCase().contains(query);
      } else if (searchBy == SharedPrefsKeys.email.value) {
        return account.email.toLowerCase().contains(query);
      } else if (searchBy == SharedPrefsKeys.password.value) {
        return account.password.toLowerCase().contains(query);
      } else {
        return account.title.toLowerCase().contains(query) ||
            account.email.toLowerCase().contains(query) ||
            account.title.toLowerCase().contains(query);
      }
    }).toList();
  }

  void setSearchByOption(String? value) async {
    if (value != null) {
      await _data.setString(SharedPrefsKeys.searchBy.value, value);
      setState(() {
        searchBy = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidPullToRefresh(
        height: 160,
        springAnimationDurationInMilliseconds: 700,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 62, 66, 64)
            : Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        onRefresh: getData,
        child: Column(
          children: [
            CustomAppbar(
              child: Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 40,
                      ),
                      Text(
                        "appbar_title".tr(),
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () =>
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => SettingsPage(
                                        onSearchByOptionChange:
                                            setSearchByOption,
                                        onHideDetails: setHideDetails,
                                        accounts: accounts,
                                        onRestoreBackup:
                                            (List<Account> backupAccounts) =>
                                                onRestoreBackup(backupAccounts),
                                        onThemModeChange:
                                            widget.onThemModeChange,
                                      ))),
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SearchBar(
                      controller: _searchController,
                      focusNode: _searchBarFocus,
                      leading: const Icon(Icons.search),
                      trailing: _searchController.text.isEmpty
                          ? null
                          : [
                              IconButton(
                                  onPressed: () => setState(() {
                                        _searchController.clear();
                                        _searchBarFocus.previousFocus();
                                      }),
                                  icon: const Icon(Icons.close_rounded))
                            ],
                      hintText: "search".tr(),
                      onChanged: _setAccounts,
                      onTapOutside: (event) => _searchBarFocus.previousFocus(),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
                future: _futuredAccounts,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Account>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("loading".tr()),
                              const SizedBox(width: 20),
                              const CircularProgressIndicator(),
                            ],
                          )),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text("${"error".tr()} ${snapshot.error}")),
                        ],
                      ),
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text("when_no_accounts".tr())),
                        ],
                      ),
                    );
                  } else {
                    return Expanded(
                        child: ListView.builder(
                            itemCount: _filterdAccounts.length,
                            itemBuilder: (BuildContext context, int index) =>
                                AccountCard(
                                    accountSecurityEnabled: isDetailsHidden,
                                    account: _filterdAccounts[index],
                                    onEdit: onEdit,
                                    onDelete: deleteAccount)));
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => AddAccountPage(onAdd: addAccount))),
          child: const Icon(Icons.add, color: Colors.white,)),
    );
  }
}
