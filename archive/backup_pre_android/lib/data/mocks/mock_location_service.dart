import '../../domain/services/location_service.dart';

class MockLocationService implements LocationService {
  @override
  Future<String?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate GPS delay
    return "31.5204° N, 74.3587° E"; // Example location (Lahore)
  }
}
