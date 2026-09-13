import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
  Future<List<ConnectivityResult>> checkConnectivity();
}
