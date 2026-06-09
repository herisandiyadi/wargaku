import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class PanicService {
  PanicService._();

  static final _firestore = FirebaseFirestore.instance;

  static Future<Position> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static Future<String> sendPanicAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    final position = await _getLocation();

    final doc = await _firestore.collection('panic_logs').add({
      'user_id': user?.uid ?? 'anonymous',
      'sender_name': user?.displayName ?? 'Warga',
      'phone': user?.phoneNumber ?? '',
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'rt_id': 'rt03_rw01',
      'resolved_at': null,
    });

    return doc.id;
  }

  static Future<void> resolvePanic(String panicId) async {
    await _firestore.collection('panic_logs').doc(panicId).update({
      'status': 'resolved',
      'resolved_at': FieldValue.serverTimestamp(),
    });
  }
}
