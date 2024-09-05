import 'package:accounts_saver/components/custom_textfiled.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditAccountPage extends StatelessWidget {
  final void Function(
    Account oldAccount,
    TextEditingController title,
    TextEditingController email,
    TextEditingController password,
  ) onEditCompleted;
  final Account account;
  const EditAccountPage({super.key, required this.account, required this.onEditCompleted});

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
                onPressed: () => onEditCompleted(account, titleController, emailController, passwordController),
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
