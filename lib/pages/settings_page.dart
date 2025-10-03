import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/generated/l10n.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BioAuth _auth = BioAuth();
  final Sql db = Sql();

  Future<bool> checkStoragePermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;
    PermissionStatus manageStorageStatus =
        await Permission.manageExternalStorage.status;

    if (storageStatus.isDenied) {
      storageStatus = await Permission.storage.request();
    }

    if (manageStorageStatus.isDenied) {
      manageStorageStatus = await Permission.manageExternalStorage.request();
    }

    return storageStatus.isGranted || manageStorageStatus.isGranted;
  }

  Future<void> setBio(bool active) async {
    // check if the user has a password
    if (await _auth.canAuthintecate()) {
      // if the user want's to close the biomitric
      if (!active) {
        // do authentication
        if (await _auth.authinticate() && mounted) {
          context.read<AccountSecurity>().updateBioActive(active);
        }

        // if he want to open it when there's no password
      } else {
        if (mounted) {
          context.read<AccountSecurity>().updateBioActive(active);
        }
      }

      // if he doesn't have a password
    } else {
      if (mounted) {
        context.read<AccountSecurity>().updateBioActive(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).set_phone_password),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  Future<void> setHideDetails(bool willActive) async {
    if (await _auth.canAuthintecate()) {
      if (!willActive) {
        if (await _auth.authinticate() && mounted) {
          context.read<AccountSecurity>().updateHideDetails(willActive);
        }
      } else {
        if (mounted) {
          context.read<AccountSecurity>().updateHideDetails(willActive);
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).set_phone_password),
          showCloseIcon: true,
        ),
      );
    }
  }

  Future<void> backup() async {
    if (await checkStoragePermission()) {
      // String? path = await FilePicker.platform.getDirectoryPath(
      //     dialogTitle: "Pick A place to save the backup file",
      //     lockParentWindow: true);
      if (!mounted) return;
      String encodedData = base64Encode(
        utf8.encode(
          jsonEncode({
            "accounts": context
                .read<AccountsState>()
                .accounts
                .map((account) => account.toJson())
                .toList(),
          }),
        ),
      );

      final String? s = await FilePicker.platform.saveFile(
        dialogTitle: "Pick A place to save the backup file",
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: ['json'],
        fileName: "accountsBackup.json",
        bytes: utf8.encode(encodedData),
      );

      if (s != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).backup_successfully),
            showCloseIcon: true,
          ),
        );
      }
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(S.of(context).need_storage_permission),
          content: Text(S.of(context).need_storage_permission_details),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text(S.of(context).open_settings),
            ),
          ],
        ),
      );
    }
  }

  void onSuccessRestore(List<Account> accounts) {
    if (mounted) {
      if (accounts.isNotEmpty) {
        AccountsState accountsState = context.read<AccountsState>();
        if (accountsState.accounts.isEmpty) {
          accountsState.doRefresh = true;
        }
        accountsState.addManyAccount(accounts);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).backup_restored_successfully),
            showCloseIcon: true,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).backup_restored_failed),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  Future<void> addMoreOnRestore(String fileContent) async {
    try {
      String decodedData = utf8.decode(base64Decode(fileContent));
      List<Account> accounts = await db.addFromJson(decodedData);
      onSuccessRestore(accounts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).backup_restored_failed),
          showCloseIcon: true,
        ),
      );
      return;
    }
  }

  Future<void> replaceOnRestore(String fileContent) async {
    try {
      String decodedData = utf8.decode(base64Decode(fileContent));
      await db.deleteAccount("DELETE FROM accounts");
      List<Account> accounts = await db.addFromJson(decodedData);
      onSuccessRestore(accounts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).backup_restored_failed),
          showCloseIcon: true,
        ),
      );
      return;
    }
  }

  Future<void> restoreBackup() async {
    if (await checkStoragePermission()) {
      FilePickerResult? files = await FilePicker.platform.pickFiles(
        dialogTitle: "Pick The File To Restore",
        type: FileType.custom,
        allowedExtensions: ["json"],
        lockParentWindow: true,
      );

      if (files != null && files.files.isNotEmpty) {
        final File file = File(files.files.first.path!);

        String fileContent = await file.readAsString();

        if (fileContent.isNotEmpty && mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: Text(S.of(context).dlg_on_restore_title),
              content: Text(S.of(context).dlg_on_restore_details),
              actionsAlignment: MainAxisAlignment.start,
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await replaceOnRestore(fileContent);
                  },
                  child: Text(
                    S.of(context).replace,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await addMoreOnRestore(fileContent);
                  },
                  child: Text(S.of(context).append),
                ),
              ],
            ),
          );
        } else if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: Text(S.of(context).empty_file),
              content: Text(S.of(context).empty_file_details),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).ok),
                ),
              ],
            ),
          );
        }
      }
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(S.of(context).need_storage_permission),
          content: Text(S.of(context).need_storage_permission_details),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text(S.of(context).open_settings),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // themes
              Text(S.of(context).themes, style: titleStyle),
              Selector<ThemeState, ThemeMode>(
                selector: (context, themeState) => themeState.themeMode,
                builder: (context, currentTheme, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: currentTheme == ThemeMode.system
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text(S.of(context).system),
                      selected: currentTheme == ThemeMode.system,
                      onSelected: (value) {
                        context.read<ThemeState>().updateTheme(
                          context,
                          ThemeMode.system,
                        );
                      },
                    ),
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: currentTheme == ThemeMode.light
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text(S.of(context).light),
                      selected: currentTheme == ThemeMode.light,
                      onSelected: (value) {
                        context.read<ThemeState>().updateTheme(
                          context,
                          ThemeMode.light,
                        );
                      },
                    ),
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: currentTheme == ThemeMode.dark
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text(S.of(context).dark),
                      selected: currentTheme == ThemeMode.dark,
                      onSelected: (value) {
                        context.read<ThemeState>().updateTheme(
                          context,
                          ThemeMode.dark,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // privacy Settings
              const SizedBox(height: 20),
              Text(S.of(context).privacy, style: titleStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).use_bio),
                  Selector<AccountSecurity, bool>(
                    selector: (context, state) => state.isBioActive,
                    builder: (context, isBioActive, child) =>
                        Switch.adaptive(value: isBioActive, onChanged: setBio),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).hide_acc),
                  Selector<AccountSecurity, bool>(
                    selector: (context, state) => state.isDetailsHidden,
                    builder: (context, isDetailsHidden, child) =>
                        Switch.adaptive(
                          value: isDetailsHidden,
                          onChanged: setHideDetails,
                        ),
                  ),
                ],
              ),

              // Search Settings
              const SizedBox(height: 20),
              Text(S.of(context).search_settings, style: titleStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).search_by),
                  Consumer<SearchByState>(
                    builder: (context, state, child) => DropdownButton(
                      value: state.searchBy,
                      items: [
                        DropdownMenuItem(
                          value: "email type",
                          child: Text(S.of(context).emailType),
                        ),
                        DropdownMenuItem(
                          value: "email",
                          child: Text(S.of(context).email),
                        ),
                        DropdownMenuItem(
                          value: "password",
                          child: Text(S.of(context).password),
                        ),
                        DropdownMenuItem(
                          value: "all",
                          child: Text(S.of(context).all),
                        ),
                      ],
                      onChanged: (newvalue) {
                        state.updateSearchBy(newvalue!);
                      },
                    ),
                  ),
                ],
              ),

              // language Settings
              const SizedBox(height: 20),
              Text(
                S.of(context).language_settings,
                style: titleStyle,
              ), // add trans
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).language),
                  Selector<AccountSecurity, Locale>(
                    selector: (context, state) => state.currentLocale,
                    builder: (context, currentLocale, child) {
                      return DropdownButton<Locale>(
                        value: Locale(Intl.getCurrentLocale()),
                        items: S.delegate.supportedLocales
                            .map(
                              (local) => DropdownMenuItem(
                                value: local,
                                child: Text(local.languageCode.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (Locale? value) {
                          context.read<AccountSecurity>().currentLocale = value;
                        }
                      );
                    },
                  ),
                ],
              ),

              // backups
              const SizedBox(height: 20),
              Text(S.of(context).backups, style: titleStyle),
              Text(
                S.of(context).backup_details,
                style: const TextStyle(
                  color: Color.fromARGB(179, 128, 127, 127),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // backup
                  CustomElevatedButton(
                    onPressed: backup,
                    buttonLabel: Text(S.of(context).backup),
                    icon: const Icon(Icons.backup),
                  ),

                  // restore backup
                  CustomElevatedButton(
                    onPressed: restoreBackup,
                    buttonLabel: Text(S.of(context).restore_backup),
                    icon: const Icon(Icons.settings_backup_restore),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
