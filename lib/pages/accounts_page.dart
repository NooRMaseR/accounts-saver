import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:accounts_saver/components/custom_appbar.dart';
import 'package:accounts_saver/components/account_card.dart';
import 'package:accounts_saver/pages/add_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:accounts_saver/pages/settings_page.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final Sql db = Sql();
  final ValueNotifier<List<Account>> _filterdAccounts =
      ValueNotifier<List<Account>>([]);
  late Future<List<Account>> _futuredAccounts;
  final FocusNode _searchBarFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> isDetailsHidden = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _futuredAccounts = getData();
    _searchController.addListener(() => setState(() {}));
  }

  Future<List<Account>> getData() async {
    Provider.of<AccountsState>(context, listen: false).accounts.clear();
    Provider.of<CurrentExpandedAccount>(context, listen: false).setCurrentAccountID(-1);
    _filterdAccounts.value.clear();
    List<Map<String, Object?>> accountsFound =
        await db.getAccount('SELECT * FROM "accounts"');

    if (mounted) {
      Provider.of<AccountsState>(context, listen: false).addManyAccount(
          accountsFound.map((account) => Account.fromObject(account)).toList());
      _filterdAccounts.value =
          Provider.of<AccountsState>(context, listen: false).accounts;
    }

    return _filterdAccounts.value;
  }

  void _setAccounts(String query, String searchBy) {
    List<Account> accountsFound = _searchData(query, searchBy);
    _filterdAccounts.value = accountsFound.isEmpty
        ? Provider.of<AccountsState>(context).accounts
        : accountsFound;
  }

  List<Account> _searchData(String query, String searchBy) {
    query = query.toLowerCase();
    return Provider.of<AccountsState>(context, listen: false)
        .accounts
        .where((Account account) {
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
                          onPressed: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) => SettingsPage())),
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
                    child: Consumer<SearchByState>(
                      builder: (context, state, child) => SearchBar(
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
                        onChanged: (value) =>
                            _setAccounts(value, state.searchBy),
                        onTapOutside: (event) =>
                            _searchBarFocus.previousFocus(),
                      ),
                    ),
                  )
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
                          Center(
                              child: Row(
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
                          Center(
                              child: Text("${"error".tr()} ${snapshot.error}")),
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
                        child: Consumer<AccountsState>(
                            builder: (BuildContext context, AccountsState state,
                                    Widget? child) =>
                                ListView.builder(
                                    itemCount: _filterdAccounts.value.length,
                                    itemBuilder: (BuildContext context,
                                            int index) =>
                                        Consumer<AccountSecurity>(
                                            builder: (context, stateSC, child) =>
                                                AccountCard(
                                                    accountSecurityEnabled:
                                                        stateSC.isDetailsHidden,
                                                    account: _filterdAccounts
                                                        .value[index])))));
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context)
              .push(CupertinoPageRoute(builder: (context) => AddAccountPage())),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }
}
