import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:accounts_saver/pages/edit_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountCard extends StatefulWidget {
  Account account;
  final void Function(Account account) onDelete;
  final void Function(Account oldAccount, TextEditingController title,
      TextEditingController email, TextEditingController password) onEdit;
  final TextStyle textStyle = const TextStyle(fontSize: 18);
  bool accountSecurityEnabled;
  AccountCard(
      {super.key,
      required this.accountSecurityEnabled,
      required this.account,
      required this.onEdit,
      required this.onDelete});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool accountDetailsHidden = true;
  final String hiddenCode = "*****";
  final BioAuth authintecation = BioAuth();

  Future<bool> authinticatedSuccessfully() async =>
      await authintecation.canAuthintecate() &&
      await authintecation.authinticate();

  void hide() {
    setState(() {
      accountDetailsHidden = true;
    });
  }

  void show() {
    if (widget.accountSecurityEnabled) {
      setState(() {
        accountDetailsHidden = false;
      });
    }
  }

  void authToDisplayText() async {
    if (widget.accountSecurityEnabled && accountDetailsHidden) {
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
        Clipboard.setData(ClipboardData(text: widget.account.email));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("success_${type}_copy".tr()),
          showCloseIcon: true,
        ));
      }
    } else {
      Clipboard.setData(ClipboardData(text: widget.account.email));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("success_${type}_copy".tr()),
        showCloseIcon: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 4,
          child: InkWell(
            onTap: () {},
            child: ExpansionTile(
              shape: const OutlineInputBorder(borderSide: BorderSide.none),
              expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 600)),
              title: Text(
                "${"emailType".tr()}: ${widget.account.title}",
                style: widget.textStyle,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${"email".tr()}: ${widget.accountSecurityEnabled && accountDetailsHidden ? hiddenCode : widget.account.email}",
                    style: widget.textStyle,
                  ),
                  Text(
                    "${"password".tr()}: ${widget.accountSecurityEnabled && accountDetailsHidden ? hiddenCode : widget.account.password}",
                    style: widget.textStyle,
                  ),
                ],
              ),

              // buttons
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <CustomElevatedButton>[
                          CustomElevatedButton(
                            onPressed: () =>
                                copy(widget.account.email, "email"),
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
                                  Navigator.of(context).push(CupertinoPageRoute(
                                      builder: (context) => EditAccountPage(
                                          account: widget.account,
                                          onEditCompleted: widget.onEdit)));
                                }
                              } else {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) => EditAccountPage(
                                        account: widget.account,
                                        onEditCompleted: widget.onEdit)));
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
                                                    widget.onDelete(
                                                        widget.account);
                                                  }
                                                } else {
                                                  widget
                                                      .onDelete(widget.account);
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomElevatedButton(
                                buttonLabel: Text(widget.accountSecurityEnabled && accountDetailsHidden
                                    ? "show".tr()
                                    : "hide".tr()),
                                onPressed: authToDisplayText)
                          ])
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
