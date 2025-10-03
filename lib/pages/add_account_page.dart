import 'dart:io';

import 'package:accounts_saver/components/custom_textfiled.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onAdd() {
    if (titleController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      AccountsState accountsState = context.read<AccountsState>();
      if (accountsState.accounts.isEmpty) {
        accountsState.doRefresh = true;
      }
      accountsState.dbAddAccount(titleController.text, emailController.text, passwordController.text);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).fill_missing_fileds),
        showCloseIcon: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).add_account),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // title
            CustomTextfiled(
              controller: titleController,
              label: S.of(context).emailType,
            ),
            const SizedBox(height: 20),

            // email
            CustomTextfiled(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              label: S.of(context).email,
            ),
            const SizedBox(height: 20),

            // password
            CustomTextfiled(
              controller: passwordController,
              label: S.of(context).password,
              action: TextInputAction.done,
              onSubmit: (_) => onAdd(),
            ),
            const SizedBox(height: 50),

            // send button
            Platform.isIOS ? CupertinoButton.filled(
              onPressed: () => onAdd(),
              child: Text(
                S.of(context).add_account,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ) : ElevatedButton(
                  onPressed: () => onAdd(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(13)),
                    padding: EdgeInsets.all(20)
                  ),
                  child: Text(
                    S.of(context).add_account,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
          ],
        ),
      ),
    );
  }
}
