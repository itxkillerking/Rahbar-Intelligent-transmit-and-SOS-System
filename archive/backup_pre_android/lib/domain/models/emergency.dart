import 'package:uuid/uuid.dart';
import 'emergency_mode.dart';
import 'emergency_status.dart';

class Emergency {
  final String emergencyId;
  final String userId;
  final EmergencyMode mode;
  final EmergencyStatus status;
  final DateTime createdAt;
  final String? location;
  final int? batteryLevel;
  final String? networkStatus;
  final String? evidenceStatus;
  final String? synchronizationStatus;

  Emergency({
    required this.emergencyId,
    required this.userId,
    required this.mode,
    required this.status,
    required this.createdAt,
    this.location,
    this.batteryLevel,
    this.networkStatus,
    this.evidenceStatus,
    this.synchronizationStatus,
  });

  factory Emergency.create({
    required String userId,
    required EmergencyMode mode,
    EmergencyStatus status = EmergencyStatus.idle,
  }) {
    return Emergency(
      emergencyId: const Uuid().v4(),
      userId: userId,
      mode: mode,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  Emergency copyWith({
    String? emergencyId,
    String? userId,
    EmergencyMode? mode,
    EmergencyStatus? status,
    DateTime? createdAt,
    String? location,
    int? batteryLevel,
    String? networkStatus,
    String? evidenceStatus,
    String? synchronizationStatus,
  }) {
    return Emergency(
      emergencyId: emergencyId ?? this.emergencyId,
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      networkStatus: networkStatus ?? this.networkStatus,
      evidenceStatus: evidenceStatus ?? this.evidenceStatus,
      synchronizationStatus: synchronizationStatus ?? this.synchronizationStatus,
    );
  }
}
