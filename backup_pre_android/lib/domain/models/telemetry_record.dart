class TelemetryRecord {
  final String id;
  final DateTime timestamp;
  final String location;
  final String status;

  TelemetryRecord({
    required this.id,
    required this.timestamp,
    required this.location,
    required this.status,
  });

  TelemetryRecord copyWith({
    String? id,
    DateTime? timestamp,
    String? location,
    String? status,
  }) {
    return TelemetryRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
}
