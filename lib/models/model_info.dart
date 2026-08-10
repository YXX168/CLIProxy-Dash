/// Represents a single AI model configured in CLIProxyAPI.
class ModelInfo {
  const ModelInfo({
    required this.name,
    required this.provider,
    this.alias,
    this.label,
    this.baseUrl,
    this.ownedBy,
    this.type,
    this.excluded = false,
  });

  final String name;
  final String provider;
  final String? alias;
  final String? label;
  final String? baseUrl;
  final String? ownedBy;
  final String? type;
  final bool excluded;

  String get displayName => label ?? alias ?? name;

  factory ModelInfo.fromJson(Map<String, dynamic> json, String provider) {
    final name = (json['name'] ?? json['id'])?.toString().trim() ?? '';
    final alias = json['alias']?.toString().trim();
    final label = json['display_name']?.toString().trim();
    return ModelInfo(
      name: name,
      provider: provider,
      alias: alias == null || alias.isEmpty || alias == name ? null : alias,
      label: label == null || label.isEmpty || label == name ? null : label,
      baseUrl: json['base-url']?.toString() ?? json['base_url']?.toString(),
      ownedBy: json['owned_by']?.toString(),
      type: json['type']?.toString(),
    );
  }
}

/// Groups models by their provider.
class ProviderGroup {
  const ProviderGroup({
    required this.provider,
    required this.models,
    required this.excludedModels,
  });

  final String provider;
  final List<ModelInfo> models;
  final List<String> excludedModels;

  int get totalModels => models.length + excludedModels.length;
}

/// Aggregated model list response.
class ModelListResult {
  const ModelListResult({required this.providers, required this.rawConfig});

  final List<ProviderGroup> providers;
  final Map<String, dynamic> rawConfig;

  int get totalModels =>
      providers.fold(0, (total, p) => total + p.models.length);

  int get totalExcluded =>
      providers.fold(0, (total, p) => total + p.excludedModels.length);
}
