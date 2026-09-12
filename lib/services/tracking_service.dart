import 'firebase_service.dart';

class TrackingService {
  final FirebaseService _firebaseService;

  TrackingService(this._firebaseService);

  void startTrip(String busId) {
    _firebaseService.startDriverTracking(busId);
  }

  void stopTrip(String busId) {
    _firebaseService.stopDriverTracking(busId);
  }

  bool get isTracking => _firebaseService.isDriverTrackingActive;
}
