import 'package:accounts_saver/pages/accounts_page.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});
  final BioAuth _auth = BioAuth();

  Future<void> check(BuildContext context) async {
    if (await _auth.canAuthintecate() && await _auth.authinticate()) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const AccountsPage()));
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
          child: Text(S.of(context).unlook)
        ),
      ),
    );
  }
}
