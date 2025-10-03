import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:accounts_saver/components/custom_appbar.dart';
import 'package:accounts_saver/components/account_card.dart';
import 'package:accounts_saver/pages/add_account_page.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:accounts_saver/pages/settings_page.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/generated/l10n.dart';
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
  final FocusNode _searchBarFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    context.read<CurrentExpandedAccount>().currentAccountId = null;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchBarFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void init() async {
    final state = context.read<AccountsState>();
    await state.getData(context);
    state.doRefresh = true;
  }

  void _setAccounts(String query, String searchBy) {
    List<Account> accountsFound = _searchData(query, searchBy);
    AccountsState accountsState = context.read<AccountsState>();
    accountsState.filterdAccounts = accountsFound.isEmpty
        ? accountsState.accounts
        : accountsFound;
  }

  List<Account> _searchData(String query, String searchBy) {
    query = query.toLowerCase();
    return context.read<AccountsState>().accounts.where((Account account) {
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
        onRefresh: () async {
          await context.read<AccountsState>().getData(context);
          if (context.mounted) {
            context.read<CurrentExpandedAccount>().currentAccountId = null;
          }
        },
        child: Column(
          children: <Widget>[
            CustomAppbar(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 40),
                      Text(
                        S.of(context).appbar_title,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Selector<SearchByState, String>(
                      selector: (context, state) => state.searchBy,
                      builder: (context, searchBy, child) =>
                          ValueListenableBuilder(
                            valueListenable: _searchController,
                            builder: (context, controller, child) {
                              return SearchBar(
                                controller: _searchController,
                                focusNode: _searchBarFocus,
                                leading: const Icon(Icons.search),
                                trailing: controller.text.isEmpty
                                    ? null
                                    : <Widget>[
                                        IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _searchBarFocus.previousFocus();
                                            AccountsState accountsState =
                                                Provider.of<AccountsState>(
                                                  context,
                                                  listen: false,
                                                );
                                            accountsState.filterdAccounts =
                                                accountsState.accounts;
                                          },
                                          icon: const Icon(Icons.close_rounded),
                                        ),
                                      ],
                                hintText: S.of(context).search,
                                onChanged: (value) =>
                                    _setAccounts(value, searchBy),
                                onTapOutside: (event) =>
                                    _searchBarFocus.previousFocus(),
                              );
                            },
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Selector<AccountsState, bool>(
              selector: (context, state) => state.doRefresh,
              builder: (context, shouldRefresh, child) {
                if (shouldRefresh) {
                  context.read<AccountsState>().doRefresh = false;
                }
                return FutureBuilder(
                  future: (() async =>
                      context.read<AccountsState>().filterdAccounts)(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(S.of(context).loading),
                                  const SizedBox(width: 20),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "${S.of(context).error} ${snapshot.error}",
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: Text(S.of(context).when_no_accounts)),
                          ],
                        ),
                      );
                    } else {
                      return Consumer<AccountsState>(
                        builder: (context, state, child) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: state.filterdAccounts.length,
                              itemBuilder: (context, index) =>
                                  Selector<AccountSecurity, bool>(
                                    selector: (context, state) =>
                                        state.isDetailsHidden,
                                    builder: (context, isDetailsHidden, child) {
                                      return AccountCard(
                                        accountSecurityEnabled: isDetailsHidden,
                                        account: state.filterdAccounts[index],
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(CupertinoPageRoute(builder: (context) => AddAccountPage())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
