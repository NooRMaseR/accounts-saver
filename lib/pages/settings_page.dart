import 'package:accounts_saver/components/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:accounts_saver/models/common_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounts_saver/utils/bio_auth.dart';
import 'package:accounts_saver/models/account.dart';
import 'package:accounts_saver/utils/sql.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeMode) onThemModeChange;
  final void Function(bool isHidden) onHideDetails;
  final void Function(String? onSearchByOptionChange) onSearchByOptionChange;
  final void Function(List<Account>) onRestoreBackup;
  final BioAuth _auth = BioAuth();
  final Sql db = Sql();
  List<Account> accounts;
  SettingsPage(
      {super.key,
      required this.accounts,
      required this.onHideDetails,
      required this.onRestoreBackup,
      required this.onThemModeChange,
      required this.onSearchByOptionChange});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _bioActive = false;
  bool _hideDetails = false;
  late SharedPreferences _data;
  ThemeMode _mode = ThemeMode.system;
  Locale? _local;
  String? _searchByDropDown = SharedPrefsKeys.all.value;

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
    final String? theme = _data.getString(SharedPrefsKeys.theme.value);
    final String? searchBy = _data.getString(SharedPrefsKeys.searchBy.value);
    final bool? bio = _data.getBool(SharedPrefsKeys.biometric.value);
    final List<String> storageLocale =
        (_data.getString("locale") ?? "en_US").split("_");

    final bool? hideDetails =
        _data.getBool(SharedPrefsKeys.hideAccountDetails.value);
    setState(() {
      switch (theme) {
        case "light":
          _mode = ThemeMode.light;

        case "dark":
          _mode = ThemeMode.dark;

        default:
          _mode = ThemeMode.system;
      }

      if (searchBy != null) {
        _searchByDropDown = searchBy;
      }

      if (bio == true) {
        _bioActive = true;
      }

      if (hideDetails == true) {
        _hideDetails = true;
      }
      _local = Locale(storageLocale[0], storageLocale[1]);
    });
  }

  Future<void> setBio(bool active) async {
    // check if the user has a password
    if (await widget._auth.canAuthintecate()) {
      // if the user want's to close the biomitric
      if (!active) {
        // do authentication
        if (await widget._auth.authinticate()) {
          await _data.setBool(SharedPrefsKeys.biometric.value, active);
          setState(() {
            _bioActive = active;
          });
        }

        // if he want to open it when there's no password
      } else {
        await _data.setBool(SharedPrefsKeys.biometric.value, active);
        setState(() {
          _bioActive = active;
        });
      }

      // if he doesn't have a password
    } else {
      await _data.setBool(SharedPrefsKeys.biometric.value, false);
      setState(() {
        _bioActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("set_phone_password".tr()), showCloseIcon: true));
    }
  }

  Future<void> setTheme(ThemeMode? theme) async {
    await _data.setString(SharedPrefsKeys.theme.value, theme!.name);
    setState(() {
      _mode = theme;
    });
    widget.onThemModeChange(theme);
  }

  Future<void> backup() async {
    if (await checkStoragePermission()) {
      String? path = await FilePicker.platform.getDirectoryPath(
          dialogTitle: "Pick A place to save the backup file",
          lockParentWindow: true);

      final File filePath = File("$path/accountsBackup.json");
      List<Map> newAccounts = [];
      for (Account account in widget.accounts) {
        newAccounts.add(account.toJson(account));
      }

      await filePath.writeAsString(jsonEncode(newAccounts));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("backup_successfully".tr()),
        showCloseIcon: true,
      ));
    } else {
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

          widget.onRestoreBackup(accounts);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("backup_restored_successfully".tr()),
            showCloseIcon: true,
          ));
        } else {
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
    } else {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChoiceChip.elevated(
                    selectedColor: const Color.fromARGB(255, 184, 217, 245),
                    side: BorderSide(
                      color:
                          _mode == ThemeMode.system ? Colors.blue : Colors.grey,
                    ),
                    label: Text("system".tr()),
                    selected: _mode == ThemeMode.system,
                    onSelected: (value) {
                      setTheme(ThemeMode.system);
                      setState(() {
                        _mode = ThemeMode.system;
                      });
                    },
                  ),
                  ChoiceChip.elevated(
                    selectedColor: const Color.fromARGB(255, 184, 217, 245),
                    side: BorderSide(
                      color:
                          _mode == ThemeMode.light ? Colors.blue : Colors.grey,
                    ),
                    label: Text("light".tr()),
                    selected: _mode == ThemeMode.light,
                    onSelected: (value) {
                      setTheme(ThemeMode.light);
                      setState(() {
                        _mode = ThemeMode.light;
                      });
                    },
                  ),
                  ChoiceChip.elevated(
                    selectedColor: const Color.fromARGB(255, 184, 217, 245),
                    side: BorderSide(
                      color:
                          _mode == ThemeMode.dark ? Colors.blue : Colors.grey,
                    ),
                    label: Text("dark".tr()),
                    selected: _mode == ThemeMode.dark,
                    onSelected: (value) {
                      setTheme(ThemeMode.dark);
                      setState(() {
                        _mode = ThemeMode.dark;
                      });
                    },
                  )
                ],
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
                  Switch.adaptive(value: _bioActive, onChanged: setBio),
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("hide_acc".tr()),
                    Switch.adaptive(
                        value: _hideDetails,
                        onChanged: (bool willActive) async {
                          if (await widget._auth.canAuthintecate()) {
                            if (!willActive) {
                              if (await widget._auth.authinticate()) {
                                setState(() {
                                  _hideDetails = willActive;
                                });
                                widget.onHideDetails(willActive);
                              }
                            } else {
                              setState(() {
                                _hideDetails = willActive;
                              });
                              widget.onHideDetails(willActive);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("set_phone_password".tr()),
                                showCloseIcon: true));
                          }
                        }),
                  ]),

              // Search Settings
              const SizedBox(height: 20),
              Text("search_settings".tr(), style: titleStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("search_by".tr()),
                  DropdownButton(
                      value: _searchByDropDown,
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
                      onChanged: (value) {
                        setState(() {
                          _searchByDropDown = value;
                        });
                        widget.onSearchByOptionChange(value);
                      }),
                ],
              ),

              // Search Settings
              const SizedBox(height: 20),
              Text("language_settings".tr(), style: titleStyle), // add trans
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("language".tr()),
                  DropdownButton(
                    value: context.locale,
                    items: languages(),
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

  List<DropdownMenuItem<Locale>> languages() {
    List<DropdownMenuItem<Locale>> drops = [];
    for (Locale i in context.supportedLocales) {
      drops.add(
        DropdownMenuItem<Locale>(
            value: i, child: Text(i.languageCode.tr())),
      );
    }
    return drops;
  }
}
