import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:accounts_saver/pages/edit_account_page.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountCard extends StatefulWidget {
  final Account account;
  final TextStyle textStyle = const TextStyle(fontSize: 18);
  final bool accountSecurityEnabled;
  const AccountCard({
    super.key,
    required this.accountSecurityEnabled,
    required this.account,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  ValueNotifier<bool> accountDetailsHidden = ValueNotifier<bool>(true);
  final String hiddenCode = "*****";
  final BioAuth authintecation = BioAuth();
  final ExpansibleController cardController = ExpansibleController();
  bool isExpanded = false;

  Future<bool> authinticatedSuccessfully() async =>
      await authintecation.canAuthintecate() &&
      await authintecation.authinticate();

  void hide() {
    accountDetailsHidden.value = true;
  }

  void show() {
    if (widget.accountSecurityEnabled) {
      accountDetailsHidden.value = false;
    }
  }

  void authToDisplayText() async {
    if (widget.accountSecurityEnabled && accountDetailsHidden.value) {
      if (await authinticatedSuccessfully()) {
        show();
      }
    } else {
      hide();
    }
  }

  void copy(String data, String type) async {
    if (widget.accountSecurityEnabled) {
      if (await authinticatedSuccessfully()) {
        Clipboard.setData(ClipboardData(
            text: type == "email"
                ? widget.account.email
                : widget.account.password));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).success_copy(type)),
            showCloseIcon: true,
          ));
        }
      }
    } else {
      Clipboard.setData(ClipboardData(text: widget.account.email));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).success_copy(type)),
        showCloseIcon: true,
      ));
    }
  }

  void onEdit(Account oldAccount, String title, String email, String password) {
    context
        .read<AccountsState>()
        .dbUpdateAccount(title, email, password, oldAccount);
    Navigator.of(context).pop();
  }

  void onDelete(Account accountToDelete) {
    AccountsState accountsState = context.read<AccountsState>();
    accountsState.dbRemoveAccount(accountToDelete);
    Future.microtask(() {
      if (accountsState.accounts.isEmpty) {
        accountsState.doRefresh = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Card(
          elevation: 4,
          child: InkWell(
            onTap: () {},
            child: Selector<CurrentExpandedAccount, int?>(
              selector: (context, state) => state.currentAccountId,
              builder: (context, currentId, child) {
                if (currentId == widget.account.id && isExpanded) {
                  Future.microtask(() {
                    cardController.expand();
                  });
                } else {
                  Future.microtask(() {
                    cardController.collapse();
                  });
                }
                return ExpansionTile(
                    shape:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    expansionAnimationStyle: AnimationStyle(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 600)),
                    title: Text(
                      "${S.of(context).emailType}: ${widget.account.title}",
                      style: widget.textStyle,
                    ),
                    subtitle: ValueListenableBuilder(
                      valueListenable: accountDetailsHidden,
                      builder: (context, isHidden, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${S.of(context).email}: ${widget.accountSecurityEnabled && isHidden ? hiddenCode : widget.account.email}",
                            style: widget.textStyle,
                          ),
                          Text(
                            "${S.of(context).password}: ${widget.accountSecurityEnabled && isHidden ? hiddenCode : widget.account.password}",
                            style: widget.textStyle,
                          ),
                        ],
                      ),
                    ),
                    controller: cardController,
                    onExpansionChanged: (expanded) {
                      isExpanded = expanded;
                      if (expanded) {
                        context
                            .read<CurrentExpandedAccount>()
                            .currentAccountId = widget.account.id;
                      }
                    },

                    // buttons
                    children: <Widget>[if (child != null) child]);
              },

              // buttons
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <CustomElevatedButton>[
                        CustomElevatedButton(
                          onPressed: () => copy(widget.account.email, "email"),
                          buttonLabel: Text(S.of(context).copy_email),
                          icon: const Icon(Icons.email_outlined),
                        ),
                        CustomElevatedButton(
                          onPressed: () =>
                              copy(widget.account.password, "password"),
                          buttonLabel: Text(S.of(context).copy_password),
                          icon: const Icon(Icons.password),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomElevatedButton(
                          onPressed: () async {
                            if (widget.accountSecurityEnabled) {
                              if (await authinticatedSuccessfully()) {
                                hide();
                                if (context.mounted) {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                      builder: (context) => EditAccountPage(
                                          account: widget.account)));
                                }
                              }
                            } else {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => EditAccountPage(
                                      account: widget.account)));
                            }
                          },
                          buttonLabel: Text(S.of(context).edit),
                          icon: const Icon(Icons.edit),
                        ),
                        CustomElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog.adaptive(
                                      title: Text(S.of(context).are_you_sure),
                                      content: Text(S.of(context).delete_warning),
                                      actions: [
                                        CustomElevatedButton(
                                            buttonLabel: Text(
                                              S.of(context).delete,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              if (widget
                                                  .accountSecurityEnabled) {
                                                if (await authinticatedSuccessfully()) {
                                                  onDelete(widget.account);
                                                }
                                              } else {
                                                onDelete(widget.account);
                                              }
                                            }),
                                        CustomElevatedButton(
                                            buttonLabel: Text(S.of(context).cancel),
                                            onPressed: () =>
                                                Navigator.of(context).pop()),
                                      ],
                                    ));
                          },
                          buttonLabel: Text(
                            S.of(context).delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder(
                        valueListenable: accountDetailsHidden,
                        builder: (context, isHidden, child) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomElevatedButton(
                                      buttonLabel: Text(
                                          widget.accountSecurityEnabled &&
                                                  isHidden
                                              ? S.of(context).show
                                              : S.of(context).hide),
                                      onPressed: authToDisplayText)
                                ])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
