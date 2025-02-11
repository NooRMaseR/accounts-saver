import 'package:accounts_saver/components/custom_textfiled.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key});

  void onAdd(BuildContext context, String title, String email, String password) {
    if (title.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      Provider.of<AccountsState>(context, listen: false).dbAddAccount(title, email, password);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("fill_missing_fileds".tr()),
        showCloseIcon: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("add_account".tr()),
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
                onPressed: () => onAdd(context, titleController.text,
                    emailController.text, passwordController.text),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "add_account".tr(),
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
