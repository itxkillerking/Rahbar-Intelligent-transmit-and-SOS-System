import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/evidence.dart';
import '../core/logging/app_logger.dart';

final evidenceRepositoryProvider = Provider<EvidenceRepository>((ref) {
  return LocalEvidenceRepository();
});

abstract class EvidenceRepository {
  Future<void> init();
  Future<List<Evidence>> getAllEvidence();
  Future<void> saveEvidence(Evidence evidence);
  Future<void> deleteEvidence(String id);
}

class LocalEvidenceRepository implements EvidenceRepository {
  static const String _key = 'rahbar_evidence_metadata';
  List<Evidence> _cached = [];
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];
      _cached = data.map((e) => Evidence.fromJson(jsonDecode(e))).toList();
      _cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _initialized = true;
    } catch (e) {
      AppLogger.error('Failed to init LocalEvidenceRepository', e);
    }
  }

  @override
  Future<List<Evidence>> getAllEvidence() async {
    await init();
    return List.unmodifiable(_cached);
  }

  @override
  Future<void> saveEvidence(Evidence evidence) async {
    await init();
    final index = _cached.indexWhere((e) => e.id == evidence.id);
    if (index >= 0) {
      _cached[index] = evidence;
    } else {
      _cached.insert(0, evidence); // newest first
    }
    _cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _persist();
  }

  @override
  Future<void> deleteEvidence(String id) async {
    await init();
    _cached.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _cached.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_key, data);
    } catch (e) {
      AppLogger.error('Failed to persist LocalEvidenceRepository', e);
    }
  }
}
