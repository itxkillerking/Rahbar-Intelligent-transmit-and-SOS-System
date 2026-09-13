import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/logging/app_logger.dart';
import '../domain/models/telemetry_record.dart';
import 'providers.dart';

enum NetworkStatus { online, offline, reconnecting, syncing }

class TelemetryState {
  final NetworkStatus networkStatus;
  final List<TelemetryRecord> records;
  final String currentLocation;
  final DateTime lastUpdate;

  TelemetryState({
    this.networkStatus = NetworkStatus.online,
    this.records = const [],
    this.currentLocation = 'Waiting for location...',
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  int get pendingSyncCount => records.where((r) => r.status != 'Synced').length;

  TelemetryState copyWith({
    NetworkStatus? networkStatus,
    List<TelemetryRecord>? records,
    String? currentLocation,
    DateTime? lastUpdate,
  }) {
    return TelemetryState(
      networkStatus: networkStatus ?? this.networkStatus,
      records: records ?? this.records,
      currentLocation: currentLocation ?? this.currentLocation,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class TelemetryController extends StateNotifier<TelemetryState> {
  final Ref _ref;

  StreamSubscription? _connectivitySubscription;

  TelemetryController(this._ref) : super(TelemetryState()) {
    _init();
  }

  Future<void> _init() async {
    await updateLocation();
    _initConnectivity();
  }

  void _initConnectivity() {
    final connectivity = _ref.read(connectivityServiceProvider);
    
    // Check initial state
    connectivity.checkConnectivity().then(_updateConnectionStatus);
    
    // Listen to changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      if (state.networkStatus != NetworkStatus.offline) {
        setOffline();
      }
    } else {
      if (state.networkStatus == NetworkStatus.offline) {
        setOnline();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> updateLocation() async {
    final locationService = _ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      state = state.copyWith(currentLocation: location, lastUpdate: DateTime.now());
    }
  }

  void setOffline() {
    state = state.copyWith(networkStatus: NetworkStatus.offline);
    AppLogger.info('Telemetry state changed: Offline');
  }

  void setOnline() async {
    if (state.networkStatus == NetworkStatus.online) return;
    
    state = state.copyWith(networkStatus: NetworkStatus.reconnecting);
    AppLogger.info('Telemetry state changed: Reconnecting');
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate reconnection delay
    
    if (state.pendingSyncCount > 0) {
      await simulateSync();
    } else {
      state = state.copyWith(networkStatus: NetworkStatus.online);
      AppLogger.info('Telemetry state changed: Online');
    }
  }

  Future<void> simulateSync() async {
    if (state.pendingSyncCount == 0) return;
    
    state = state.copyWith(networkStatus: NetworkStatus.syncing);
    AppLogger.info('Telemetry state changed: Syncing');

    // First transition to Pending Sync for visualization, if they were Cached Locally
    var intermediateRecords = state.records.map((r) {
      if (r.status == 'Cached Locally') {
        return r.copyWith(status: 'Pending Sync');
      }
      return r;
    }).toList();
    
    state = state.copyWith(records: intermediateRecords);
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate upload delay

    // Mark all as synced
    final updatedRecords = state.records.map((r) {
      if (r.status == 'Pending Sync') {
        return r.copyWith(status: 'Synced');
      }
      return r;
    }).toList();

    state = state.copyWith(
      records: updatedRecords,
      networkStatus: NetworkStatus.online,
      lastUpdate: DateTime.now(),
    );
    AppLogger.info('Telemetry state changed: Online (Sync Complete)');
  }

  Future<void> addMockTelemetry() async {
    final recordStatus = state.networkStatus == NetworkStatus.online ? 'Synced' : 'Cached Locally';
    
    final newRecord = TelemetryRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      location: state.currentLocation,
      status: recordStatus,
    );

    state = state.copyWith(
      records: [...state.records, newRecord],
      lastUpdate: DateTime.now(),
    );
    
    AppLogger.info('Mock telemetry added. Status: $recordStatus');
  }
}

final telemetryControllerProvider = StateNotifierProvider<TelemetryController, TelemetryState>((ref) {
  return TelemetryController(ref);
});
