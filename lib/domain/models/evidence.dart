import 'package:uuid/uuid.dart';

enum EvidenceType { audio, video, image }
enum EvidenceSource { silentDanger, manualAudio, manualVideo }
enum EvidenceStatus { recording, savedLocally, failed }

class Evidence {
  final String id;
  final EvidenceType type;
  final String filePath;
  final DateTime createdAt;
  final int durationSeconds; // 0 if still recording
  final EvidenceSource source;
  final String? emergencyId;
  final int fileSize;
  final EvidenceStatus status;

  Evidence({
    required this.id,
    required this.type,
    required this.filePath,
    required this.createdAt,
    required this.durationSeconds,
    required this.source,
    this.emergencyId,
    required this.fileSize,
    required this.status,
  });

  factory Evidence.create({
    required EvidenceType type,
    required String filePath,
    required EvidenceSource source,
    String? emergencyId,
  }) {
    return Evidence(
      id: const Uuid().v4(),
      type: type,
      filePath: filePath,
      createdAt: DateTime.now(),
      durationSeconds: 0,
      source: source,
      emergencyId: emergencyId,
      fileSize: 0,
      status: EvidenceStatus.recording,
    );
  }

  Evidence copyWith({
    String? id,
    EvidenceType? type,
    String? filePath,
    DateTime? createdAt,
    int? durationSeconds,
    EvidenceSource? source,
    String? emergencyId,
    int? fileSize,
    EvidenceStatus? status,
  }) {
    return Evidence(
      id: id ?? this.id,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      source: source ?? this.source,
      emergencyId: emergencyId ?? this.emergencyId,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'source': source.name,
      'emergencyId': emergencyId,
      'fileSize': fileSize,
      'status': status.name,
    };
  }

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'],
      type: EvidenceType.values.byName(json['type']),
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
      durationSeconds: json['durationSeconds'] ?? 0,
      source: EvidenceSource.values.byName(json['source']),
      emergencyId: json['emergencyId'],
      fileSize: json['fileSize'] ?? 0,
      status: EvidenceStatus.values.byName(json['status']),
    );
  }
}
