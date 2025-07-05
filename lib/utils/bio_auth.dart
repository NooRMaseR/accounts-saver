import 'package:easy_localization/easy_localization.dart';
import 'package:local_auth/local_auth.dart';

class BioAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthintecate() async => await _auth.canCheckBiometrics && await _auth.isDeviceSupported();

  Future<bool> authinticate() async {
    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
        localizedReason: "auth".tr(),
        options: const AuthenticationOptions(stickyAuth: true, useErrorDialogs: true)
      );
    } catch (e) {
      authenticated = false;
    }

    return authenticated;
  }
}
