// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Accounts`
  String get appbar_title {
    return Intl.message('Accounts', name: 'appbar_title', desc: '', args: []);
  }

  /// `Email Type`
  String get emailType {
    return Intl.message('Email Type', name: 'emailType', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Themes`
  String get themes {
    return Intl.message('Themes', name: 'themes', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Backups`
  String get backups {
    return Intl.message('Backups', name: 'backups', desc: '', args: []);
  }

  /// `Backup`
  String get backup {
    return Intl.message('Backup', name: 'backup', desc: '', args: []);
  }

  /// `Restore Backup`
  String get restore_backup {
    return Intl.message(
      'Restore Backup',
      name: 'restore_backup',
      desc: '',
      args: [],
    );
  }

  /// `No Accounts Found\nGo And Add Some 😊`
  String get when_no_accounts {
    return Intl.message(
      'No Accounts Found\nGo And Add Some 😊',
      name: 'when_no_accounts',
      desc: '',
      args: [],
    );
  }

  /// `The Backup file will be saved as accountsBackup`
  String get backup_details {
    return Intl.message(
      'The Backup file will be saved as accountsBackup',
      name: 'backup_details',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get add_account {
    return Intl.message('Add Account', name: 'add_account', desc: '', args: []);
  }

  /// `Edit Account`
  String get edit_account {
    return Intl.message(
      'Edit Account',
      name: 'edit_account',
      desc: '',
      args: [],
    );
  }

  /// `Edit Complete`
  String get edit_complete {
    return Intl.message(
      'Edit Complete',
      name: 'edit_complete',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Search....`
  String get search {
    return Intl.message('Search....', name: 'search', desc: '', args: []);
  }

  /// `Search By`
  String get search_by {
    return Intl.message('Search By', name: 'search_by', desc: '', args: []);
  }

  /// `Copy Email`
  String get copy_email {
    return Intl.message('Copy Email', name: 'copy_email', desc: '', args: []);
  }

  /// `Copy Password`
  String get copy_password {
    return Intl.message(
      'Copy Password',
      name: 'copy_password',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Are you Sure ?`
  String get are_you_sure {
    return Intl.message(
      'Are you Sure ?',
      name: 'are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `Are you Sure You Want To Delete This Account, You won't be able to restore it.`
  String get delete_warning {
    return Intl.message(
      'Are you Sure You Want To Delete This Account, You won\'t be able to restore it.',
      name: 'delete_warning',
      desc: '',
      args: [],
    );
  }

  /// `{successType} Successfully Copied.`
  String success_copy(String successType) {
    return Intl.message(
      '$successType Successfully Copied.',
      name: 'success_copy',
      desc: '',
      args: [successType],
    );
  }

  /// `Permission Needed`
  String get need_storage_permission {
    return Intl.message(
      'Permission Needed',
      name: 'need_storage_permission',
      desc: '',
      args: [],
    );
  }

  /// `This App Need The Premission To Access the Storage to get/create backup file, please accept it`
  String get need_storage_permission_details {
    return Intl.message(
      'This App Need The Premission To Access the Storage to get/create backup file, please accept it',
      name: 'need_storage_permission_details',
      desc: '',
      args: [],
    );
  }

  /// `Open App Settings`
  String get open_settings {
    return Intl.message(
      'Open App Settings',
      name: 'open_settings',
      desc: '',
      args: [],
    );
  }

  /// `Backup Restored Successfully ✔`
  String get backup_restored_successfully {
    return Intl.message(
      'Backup Restored Successfully ✔',
      name: 'backup_restored_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Backup Restored Faild, Please make sure the file is not corrupted`
  String get backup_restored_failed {
    return Intl.message(
      'Backup Restored Faild, Please make sure the file is not corrupted',
      name: 'backup_restored_failed',
      desc: '',
      args: [],
    );
  }

  /// `Accounts Backup Successfully ✔`
  String get backup_successfully {
    return Intl.message(
      'Accounts Backup Successfully ✔',
      name: 'backup_successfully',
      desc: '',
      args: [],
    );
  }

  /// `What Do You Want To Do?`
  String get dlg_on_restore_title {
    return Intl.message(
      'What Do You Want To Do?',
      name: 'dlg_on_restore_title',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to append the accounts to the current accounts or replace them?`
  String get dlg_on_restore_details {
    return Intl.message(
      'Do you want to append the accounts to the current accounts or replace them?',
      name: 'dlg_on_restore_details',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message('Replace', name: 'replace', desc: '', args: []);
  }

  /// `Append`
  String get append {
    return Intl.message('Append', name: 'append', desc: '', args: []);
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `The File Is Empty`
  String get empty_file {
    return Intl.message(
      'The File Is Empty',
      name: 'empty_file',
      desc: '',
      args: [],
    );
  }

  /// `The File Is Empty, could not restore the backup data`
  String get empty_file_details {
    return Intl.message(
      'The File Is Empty, could not restore the backup data',
      name: 'empty_file_details',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Hide`
  String get hide {
    return Intl.message('Hide', name: 'hide', desc: '', args: []);
  }

  /// `Authinticate to continue`
  String get auth {
    return Intl.message(
      'Authinticate to continue',
      name: 'auth',
      desc: '',
      args: [],
    );
  }

  /// `Somthing went wrong, please try again`
  String get auth_error {
    return Intl.message(
      'Somthing went wrong, please try again',
      name: 'auth_error',
      desc: '',
      args: [],
    );
  }

  /// `Enable Biomitric when open`
  String get use_bio {
    return Intl.message(
      'Enable Biomitric when open',
      name: 'use_bio',
      desc: '',
      args: [],
    );
  }

  /// `Unlook`
  String get unlook {
    return Intl.message('Unlook', name: 'unlook', desc: '', args: []);
  }

  /// `Privacy Settings`
  String get privacy {
    return Intl.message(
      'Privacy Settings',
      name: 'privacy',
      desc: '',
      args: [],
    );
  }

  /// `Hide Account Details with Authintication`
  String get hide_acc {
    return Intl.message(
      'Hide Account Details with Authintication',
      name: 'hide_acc',
      desc: '',
      args: [],
    );
  }

  /// `Set A password for your phone first`
  String get set_phone_password {
    return Intl.message(
      'Set A password for your phone first',
      name: 'set_phone_password',
      desc: '',
      args: [],
    );
  }

  /// `Search Settings`
  String get search_settings {
    return Intl.message(
      'Search Settings',
      name: 'search_settings',
      desc: '',
      args: [],
    );
  }

  /// `Somthing went Wrong, please try again.`
  String get error {
    return Intl.message(
      'Somthing went Wrong, please try again.',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Loading..`
  String get loading {
    return Intl.message('Loading..', name: 'loading', desc: '', args: []);
  }

  /// `Please fill up the missing fileds`
  String get fill_missing_fileds {
    return Intl.message(
      'Please fill up the missing fileds',
      name: 'fill_missing_fileds',
      desc: '',
      args: [],
    );
  }

  /// `Language Settings`
  String get language_settings {
    return Intl.message(
      'Language Settings',
      name: 'language_settings',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get en {
    return Intl.message('English', name: 'en', desc: '', args: []);
  }

  /// `Arabic`
  String get ar {
    return Intl.message('Arabic', name: 'ar', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
