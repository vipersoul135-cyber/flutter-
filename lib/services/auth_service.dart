import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService;

  AuthService(this._firebaseService);

  Future<bool> loginStudent(String regNo, String password) {
    return _firebaseService.signInStudent(regNo, password);
  }

  Future<bool> loginDriver(String busId, String password) {
    return _firebaseService.signInDriver(busId, password);
  }

  Future<bool> loginAdmin(String adminId, String password) {
    return _firebaseService.signInAdmin(adminId, password);
  }

  void logout() {
    _firebaseService.signOut();
  }
}
