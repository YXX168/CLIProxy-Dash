class RequestBucket {
  const RequestBucket({
    required this.time,
    required this.success,
    required this.failed,
  });

  final DateTime? time;
  final int success;
  final int failed;

  int get total => success + failed;

  factory RequestBucket.fromJson(Map<String, dynamic> json) {
    return RequestBucket(
      time: DateTime.tryParse(json['time']?.toString() ?? '')?.toLocal(),
      success: _asInt(json['success']),
      failed: _asInt(json['failed']),
    );
  }

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
