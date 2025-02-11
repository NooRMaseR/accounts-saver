import 'package:accounts_saver/components/custom_textfiled.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditAccountPage extends StatelessWidget {
  final Account account;
  const EditAccountPage({super.key, required this.account});

  void onEditCompleted(BuildContext context, Account oldAccount, String title,
      String email, String password) {
    Provider.of<AccountsState>(context, listen: false)
        .dbUpdateAccount(title, email, password, oldAccount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: account.title);
    TextEditingController emailController = TextEditingController(text: account.email);
    TextEditingController passwordController = TextEditingController(text: account.password);

    return Scaffold(
      appBar: AppBar(
        title: Text("edit_account".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // title
            CustomTextfiled(
              controller: titleController,
              label: "emailType".tr(),
            ),
            const SizedBox(height: 20),

            // email
            CustomTextfiled(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              label: "email".tr(),
            ),
            const SizedBox(height: 20),

            // password
            CustomTextfiled(
              controller: passwordController,
              label: "password".tr(),
            ),
            const SizedBox(height: 50),

            // send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onEditCompleted(
                    context,
                    account,
                    titleController.text,
                    emailController.text,
                    passwordController.text),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "edit_complete".tr(),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
