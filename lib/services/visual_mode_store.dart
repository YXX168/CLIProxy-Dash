import 'package:shared_preferences/shared_preferences.dart';

import '../models/visual_mode.dart';

abstract interface class VisualModeStore {
  Future<VisualMode> load();
  Future<void> save(VisualMode mode);
}

class PluginVisualModeStore implements VisualModeStore {
  PluginVisualModeStore({
    Future<SharedPreferences> Function()? preferencesFactory,
  }) : _preferencesFactory =
           preferencesFactory ?? SharedPreferences.getInstance;

  static const _key = 'visual_mode';
  final Future<SharedPreferences> Function() _preferencesFactory;

  @override
  Future<VisualMode> load() async {
    final preferences = await _preferencesFactory();
    return VisualMode.fromStorage(preferences.getString(_key));
  }

  @override
  Future<void> save(VisualMode mode) async {
    final preferences = await _preferencesFactory();
    await preferences.setString(_key, mode.storageValue);
  }
}
