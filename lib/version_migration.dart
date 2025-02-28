library version_migration;

import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_migration/version.dart';

class VersionMigration {
  static const String _lastMigratedVersionKey =
      "Migrator.lastMigratedVersionKey";
  static const String _lastUpdatedAppVersionKey =
      "Migrator.lastUpdatedAppVersionKey";

  /// Migrate to version [version] executing the function [migrationFunction]
  static Future<bool> migrateToVersion(
      String version, Function migrationFunction) async {
    bool migrated = false;
    Version newVersion = Version(version: version);

    if (await _newVersionIsGreaterThanLastMigratedVersion(newVersion) &&
        await _newVersionIsNotGreatherThanAppVersion(newVersion)) {
      await migrationFunction();
      await _setLastMigratedVersion(version.toString());
      migrated = true;
    }

    return migrated;
  }

  /// If you need a block that runs every time your application version changes, executing the function [updatedFunction]
  static Future<void> applicationUpdate(Function updateFunction) async {
    Version lastUpdatedAppVersion = await _getLastUpdatedAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (lastUpdatedAppVersion.toString() != packageInfo.version) {
      updateFunction();
      _setLastUpdatedAppVersion(packageInfo.version);
    }
  }

  /// Reset in shared preferences the last migrated version and last updated app version
  static reset() {
    _resetLastMigratedVersion();
    _resetLastUpdatedAppVersion();
  }

  static Future<bool> _resetLastMigratedVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(_lastMigratedVersionKey);
  }

  static Future<bool> _resetLastUpdatedAppVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(_lastUpdatedAppVersionKey);
  }

  static Future<Version> _getLastMigratedVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(
        version: prefs.getString(_lastMigratedVersionKey) ?? "0.0.0");
  }

  static Future<bool> _setLastMigratedVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_lastMigratedVersionKey, value);
  }

  static Future<Version> _getLastUpdatedAppVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(
        version: prefs.getString(_lastUpdatedAppVersionKey) ?? "0.0.0");
  }

  static Future<bool> _setLastUpdatedAppVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_lastUpdatedAppVersionKey, value);
  }

  static Future<bool> _newVersionIsGreaterThanLastMigratedVersion(
      Version newVersion) async {
    Version lastMigratedVersion = await _getLastMigratedVersion();

    return newVersion.compareTo(lastMigratedVersion) == 1;
  }

  static Future<bool> _newVersionIsNotGreatherThanAppVersion(
      Version newVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version appVersion = Version(version: packageInfo.version);

    return newVersion.compareTo(appVersion) < 1;
  }
}
