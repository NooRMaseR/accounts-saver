import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/widget_states.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  final BioAuth _auth = BioAuth();
  final Sql db = Sql();
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences _data;

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

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    _data = await SharedPreferences.getInstance();
    final List<String> storageLocale =
        (_data.getString("locale") ?? "en_US").split("_");

    setState(() {
      Locale(storageLocale[0], storageLocale[1]);
    });
  }

  Future<void> setBio(bool active) async {
    // check if the user has a password
    if (await widget._auth.canAuthintecate()) {
      // if the user want's to close the biomitric
      if (!active) {
        // do authentication
        if (await widget._auth.authinticate() && mounted) {
          Provider.of<AccountSecurity>(context, listen: false)
              .updateBioActive(active);
        }

        // if he want to open it when there's no password
      } else {
        if (mounted) {
          Provider.of<AccountSecurity>(context, listen: false)
              .updateBioActive(active);
        }
      }

      // if he doesn't have a password
    } else {
      if (mounted) {
        Provider.of<AccountSecurity>(context, listen: false)
            .updateBioActive(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("set_phone_password".tr()), showCloseIcon: true));
      }
    }
  }

  Future<void> setHideDetails(bool willActive) async {
    if (await widget._auth.canAuthintecate()) {
      if (!willActive) {
        if (await widget._auth.authinticate() && mounted) {
          Provider.of<AccountSecurity>(context, listen: false)
              .updateHideDetails(willActive);
        }
      } else {
        if (mounted) {
          Provider.of<AccountSecurity>(context, listen: false)
              .updateHideDetails(willActive);
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("set_phone_password".tr()), showCloseIcon: true));
    }
  }

  Future<void> setTheme(ThemeMode? theme) async {
    Provider.of<ThemeState>(context).updateTheme(context, theme!);
  }

  Future<void> backup() async {
    if (await checkStoragePermission()) {
      String? path = await FilePicker.platform.getDirectoryPath(
          dialogTitle: "Pick A place to save the backup file",
          lockParentWindow: true);

      // String? path = await FilePicker.platform.saveFile(
      //   dialogTitle: "Pick A place to save the backup file",
      //   lockParentWindow: true,
      //   type: FileType.custom,
      //   allowedExtensions: ['json'],
      //   fileName: "accountsBackup.json"
      // );

      if (path == null) return;
      final File filePath = File("$path/accountsBackup.json");
      List<Map> newAccounts = Provider.of<AccountsState>(context)
          .accounts
          .map((account) => account.toJson())
          .toList();

      await filePath.writeAsString(jsonEncode(newAccounts));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("backup_successfully".tr()),
          showCloseIcon: true,
        ));
      }
    } else if (mounted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
                title: Text("need_storage_permission".tr()),
                content: Text("need_storage_permission_details".tr()),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("cancel".tr())),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await openAppSettings();
                      },
                      child: Text("open_settings".tr()))
                ],
              ));
    }
  }

  Future<void> restoreBackup() async {
    if (await checkStoragePermission()) {
      FilePickerResult? files = await FilePicker.platform.pickFiles(
          dialogTitle: "Pick The File To Restore",
          type: FileType.custom,
          allowedExtensions: ["json"],
          lockParentWindow: true);

      if (files != null || files!.files.isNotEmpty == true) {
        final File file = File(files.files.first.path!);

        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          List<Account> accounts = await widget.db.addFromJson(fileContent);

          if (mounted) {
            Provider.of<AccountsState>(context).addManyAccount(accounts);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("backup_restored_successfully".tr()),
              showCloseIcon: true,
            ));
          }
        } else if (mounted) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog.adaptive(
                    title: Text("empty_file".tr()),
                    content: Text("empty_file_details".tr()),
                    actions: [
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("ok".tr())),
                    ],
                  ));
        }
      }
    } else if (mounted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
                title: Text("need_storage_permission".tr()),
                content: Text("need_storage_permission_details".tr()),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("cancel".tr())),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await openAppSettings();
                      },
                      child: Text("open_settings".tr()))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle titleStyle =
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // themes
              Text("themes".tr(), style: titleStyle),
              Consumer<ThemeState>(
                builder: (context, themeState, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: themeState.themeMode == ThemeMode.system
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text("system".tr()),
                      selected: themeState.themeMode == ThemeMode.system,
                      onSelected: (value) {
                        themeState.updateTheme(context, ThemeMode.system);
                      },
                    ),
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: themeState.themeMode == ThemeMode.light
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text("light".tr()),
                      selected: themeState.themeMode == ThemeMode.light,
                      onSelected: (value) {
                        themeState.updateTheme(context, ThemeMode.light);
                      },
                    ),
                    ChoiceChip.elevated(
                      selectedColor: const Color.fromARGB(255, 184, 217, 245),
                      side: BorderSide(
                        color: themeState.themeMode == ThemeMode.dark
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text("dark".tr()),
                      selected: themeState.themeMode == ThemeMode.dark,
                      onSelected: (value) {
                        themeState.updateTheme(context, ThemeMode.dark);
                      },
                    )
                  ],
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text("system".tr()),
              //     Radio<ThemeMode>.adaptive(
              //       value: ThemeMode.system,
              //       groupValue: _mode,
              //       onChanged: (ThemeMode? theme) => setTheme(theme),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text("light".tr()),
              //     Radio<ThemeMode>.adaptive(
              //         value: ThemeMode.light,
              //         groupValue: _mode,
              //         onChanged: (ThemeMode? theme) => setTheme(theme)),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text("dark".tr()),
              //     Radio<ThemeMode>.adaptive(
              //         value: ThemeMode.dark,
              //         groupValue: _mode,
              //         onChanged: (ThemeMode? theme) => setTheme(theme)),
              //   ],
              // ),

              // privacy Settings
              const SizedBox(height: 20),
              Text("privacy".tr(), style: titleStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("use_bio".tr()),
                  Consumer<AccountSecurity>(
                    builder: (context, state, child) => Switch.adaptive(
                        value: state.isBioActive, onChanged: setBio),
                  )
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("hide_acc".tr()),
                    Consumer<AccountSecurity>(
                      builder: (context, state, child) => Switch.adaptive(
                          value: state.isDetailsHidden,
                          onChanged: setHideDetails),
                    ),
                  ]),

              // Search Settings
              const SizedBox(height: 20),
              Text("search_settings".tr(), style: titleStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("search_by".tr()),
                  Consumer<SearchByState>(
                    builder: (context, state, child) => DropdownButton(
                        value: state.searchBy,
                        items: [
                          DropdownMenuItem(
                            value: "email type",
                            child: Text("emailType".tr()),
                          ),
                          DropdownMenuItem(
                            value: "email",
                            child: Text("email".tr()),
                          ),
                          DropdownMenuItem(
                            value: "password",
                            child: Text("password".tr()),
                          ),
                          DropdownMenuItem(
                            value: "all",
                            child: Text("all".tr()),
                          ),
                        ],
                        onChanged: (newvalue) {
                          state.updateSearchBy(newvalue!);
                        }),
                  ),
                ],
              ),

              // language Settings
              const SizedBox(height: 20),
              Text("language_settings".tr(), style: titleStyle), // add trans
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("language".tr()),
                  DropdownButton<Locale>(
                    value: context.locale,
                    items: context.supportedLocales
                        .map((local) => DropdownMenuItem(
                            value: local,
                            child: Text(local.languageCode.toString())))
                        .toList(),
                    onChanged: (Locale? value) {
                      context.setLocale(value!);
                      _data.setString("locale", value.toString());
                    },
                  )
                ],
              ),

              // backups
              const SizedBox(height: 20),
              Text(
                "backups".tr(),
                style: titleStyle,
              ),
              Text("backup_details".tr(),
                  style: const TextStyle(
                      color: Color.fromARGB(179, 128, 127, 127))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // backup
                  CustomElevatedButton(
                    onPressed: backup,
                    buttonLabel: Text("backup".tr()),
                    icon: const Icon(Icons.backup),
                  ),

                  // restore backup
                  CustomElevatedButton(
                    onPressed: restoreBackup,
                    buttonLabel: Text("restore_backup".tr()),
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
