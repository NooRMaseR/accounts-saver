import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/pages/accounts_page.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  final void Function(ThemeMode) onThemModeChange;
  AuthPage({super.key, required this.onThemModeChange});
  final BioAuth _auth = BioAuth();

  Future<void> check(BuildContext context) async {
    if (await _auth.canAuthintecate()) {
      if (await _auth.authinticate()) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                AccountsPage(onThemModeChange: onThemModeChange)));
      }
    }
    else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              AccountsPage(onThemModeChange: onThemModeChange)));
    }
  }

  @override
  Widget build(BuildContext context) {
    check(context);
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () async {
              await check(context);
            },
            child: Text("unlook".tr())),
      ),
    );
  }
}
