import 'package:flutter/material.dart';

import 'models/app_config.dart';
import 'models/visual_mode.dart';
import 'screens/config_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/config_store.dart';
import 'services/management_service.dart';
import 'services/quota_repository.dart';
import 'services/visual_mode_store.dart';
import 'theme/app_theme.dart';
import 'widgets/quantum_emblem.dart';

typedef RepositoryFactory = QuotaRepository Function(AppConfig config);

class CliProxyDashApp extends StatefulWidget {
  const CliProxyDashApp({
    super.key,
    this.configStore,
    this.repositoryFactory,
    this.visualModeStore,
  });

  final ConfigStore? configStore;
  final RepositoryFactory? repositoryFactory;
  final VisualModeStore? visualModeStore;

  @override
  State<CliProxyDashApp> createState() => _CliProxyDashAppState();
}

class _CliProxyDashAppState extends State<CliProxyDashApp> {
  late final ConfigStore _configStore;
  late final VisualModeStore _visualModeStore;
  AppConfig? _config;
  QuotaRepository? _repository;
  VisualMode _visualMode = VisualMode.console;
  Object? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _configStore = widget.configStore ?? PluginConfigStore();
    _visualModeStore = widget.visualModeStore ?? PluginVisualModeStore();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final config = await _configStore.load();
      VisualMode visualMode;
      try {
        visualMode = await _visualModeStore.load();
      } catch (_) {
        visualMode = VisualMode.console;
      }
      if (!mounted) return;
      setState(() {
        _config = config;
        _repository = config == null ? null : _createRepository(config);
        _visualMode = visualMode;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  QuotaRepository _createRepository(AppConfig config) {
    return widget.repositoryFactory?.call(config) ??
        ManagementService(baseUri: config.baseUri, managementKey: config.key);
  }

  Future<void> _saveConfig(AppConfig config) async {
    await _configStore.save(config);
    if (!mounted) return;
    setState(() {
      _config = config;
      _repository = _createRepository(config);
      _loadError = null;
    });
  }

  Future<void> _setVisualMode(VisualMode mode) async {
    if (_visualMode == mode) return;
    await _visualModeStore.save(mode);
    if (!mounted) return;
    setState(() => _visualMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CLIProxy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _loading
          ? const _BootstrapView()
          : _loadError != null
          ? ConfigScreen(
              configStore: _configStore,
              initialConfig: _config,
              loadError: _loadError.toString(),
              onSaved: _saveConfig,
            )
          : _config == null
          ? ConfigScreen(configStore: _configStore, onSaved: _saveConfig)
          : Builder(
              builder: (homeContext) => DashboardScreen(
                key: ValueKey(_config!.baseUrl),
                config: _config!,
                repository: _repository!,
                visualMode: _visualMode,
                onVisualModeChanged: _setVisualMode,
                onEditConfig: () async {
                  await Navigator.of(homeContext).push<AppConfig>(
                    MaterialPageRoute(
                      builder: (_) => ConfigScreen(
                        configStore: _configStore,
                        initialConfig: _config,
                        popOnSave: true,
                        onSaved: _saveConfig,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _BootstrapView extends StatelessWidget {
  const _BootstrapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const QuantumEmblem(size: 72),
              const SizedBox(height: 24),
              Text(
                'CLIProxy',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFF2F7FF),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'INITIALIZING SECURE CONSOLE',
                style: TextStyle(
                  color: Color(0xFF748198),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
