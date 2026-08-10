class AppConfig {
  const AppConfig({required this.baseUrl, required this.key});

  static const defaultBaseUrl = '';

  /// App version string — keep in sync with `pubspec.yaml`.
  static const appVersion = '1.0.0';

  final String baseUrl;
  final String key;

  Uri get baseUri => Uri.parse(baseUrl);

  AppConfig copyWith({String? baseUrl, String? key}) {
    return AppConfig(baseUrl: baseUrl ?? this.baseUrl, key: key ?? this.key);
  }
}
