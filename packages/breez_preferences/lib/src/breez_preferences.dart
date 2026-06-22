import 'package:breez_preferences/src/model/bug_report_behavior.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger('BreezPreferences');

class BreezPreferences {
  // Preference Keys
  static const String _kBugReportBehavior = 'bug_report_behavior';
  static const String _kDefaultProfileName = 'default_profile_name';

  const BreezPreferences();

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  // Bug Report Behavior
  Future<BugReportBehavior> get bugReportBehavior async {
    final SharedPreferences prefs = await _preferences;
    final int? value = prefs.getInt(_kBugReportBehavior);
    final BugReportBehavior behavior = BugReportBehavior.values[value ?? BugReportBehavior.prompt.index];

    _logger.info('Fetched BugReportBehavior: $behavior');
    return behavior;
  }

  Future<void> setBugReportBehavior(BugReportBehavior behavior) async {
    _logger.info('Setting BugReportBehavior: $behavior');
    final SharedPreferences prefs = await _preferences;
    await prefs.setInt(_kBugReportBehavior, behavior.index);
  }

  // Default Profile Name
  Future<String?> get defaultProfileName async {
    final SharedPreferences prefs = await _preferences;
    final String? defaultProfileName = prefs.getString(_kDefaultProfileName);

    _logger.info('Fetched Default Profile Name: $defaultProfileName');
    return defaultProfileName;
  }

  Future<void> setDefaultProfileName(String defaultProfileName) async {
    _logger.info('Setting Default Profile Name: $defaultProfileName');
    final SharedPreferences prefs = await _preferences;
    await prefs.setString(_kDefaultProfileName, defaultProfileName);
  }

  Future<void> removeDefaultProfileName() async {
    _logger.info('Removing Default Profile Name');
    final SharedPreferences prefs = await _preferences;
    await prefs.remove(_kDefaultProfileName);
  }
}
