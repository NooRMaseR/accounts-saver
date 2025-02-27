import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:accounts_saver/pages/edit_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/widget_states.dart';
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
  final ExpansionTileController cardController = ExpansionTileController();
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
            content: Text("success_${type}_copy".tr()),
            showCloseIcon: true,
          ));
        }
      }
    } else {
      Clipboard.setData(ClipboardData(text: widget.account.email));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("success_${type}_copy".tr()),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      "${"emailType".tr()}: ${widget.account.title}",
                      style: widget.textStyle,
                    ),
                    subtitle: ValueListenableBuilder(
                      valueListenable: accountDetailsHidden,
                      builder: (context, isHidden, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"email".tr()}: ${widget.accountSecurityEnabled && isHidden ? hiddenCode : widget.account.email}",
                            style: widget.textStyle,
                          ),
                          Text(
                            "${"password".tr()}: ${widget.accountSecurityEnabled && isHidden ? hiddenCode : widget.account.password}",
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
                          buttonLabel: const Text("copy_email").tr(),
                          icon: const Icon(Icons.email_outlined),
                        ),
                        CustomElevatedButton(
                          onPressed: () =>
                              copy(widget.account.password, "password"),
                          buttonLabel: Text("copy_password".tr()),
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
                          buttonLabel: const Text("edit").tr(),
                          icon: const Icon(Icons.edit),
                        ),
                        CustomElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog.adaptive(
                                      title: Text("are_you_sure".tr()),
                                      content: Text("delete_warning".tr()),
                                      actions: [
                                        CustomElevatedButton(
                                            buttonLabel: Text(
                                              "delete".tr(),
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
                                            buttonLabel: Text("cancel".tr()),
                                            onPressed: () =>
                                                Navigator.of(context).pop()),
                                      ],
                                    ));
                          },
                          buttonLabel: Text(
                            "delete".tr(),
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
                                              ? "show".tr()
                                              : "hide".tr()),
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
