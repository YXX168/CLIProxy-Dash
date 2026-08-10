class QuotaWindow {
  const QuotaWindow({
    required this.usedPercent,
    required this.remainingPercent,
    this.resetAt,
  });

  final double? usedPercent;
  final double? remainingPercent;
  final DateTime? resetAt;

  factory QuotaWindow.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('Quota window is missing');
    }
    final used = _asDouble(json['used_percent'] ?? json['usedPercent']);
    return QuotaWindow(
      usedPercent: used,
      remainingPercent: used == null ? null : (100 - used).clamp(0, 100),
      resetAt: parseResetTime(json['reset_at'] ?? json['resetAt']),
    );
  }

  double get progress => ((usedPercent ?? 0) / 100).clamp(0, 1);

  static DateTime? parseResetTime(Object? value) {
    if (value is num && value > 0) {
      final milliseconds = value > 100000000000
          ? value.toInt()
          : value.toInt() * 1000;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    if (value is String) {
      final numeric = double.tryParse(value);
      if (numeric != null) return parseResetTime(numeric);
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
