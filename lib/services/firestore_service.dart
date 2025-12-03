import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/models.dart';

/// Service for managing Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================================
  // USER PROFILE OPERATIONS
  // ============================================================================

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUserId == null) return null;
      
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (currentUserId == null) return false;
      
      await _firestore.collection('users').doc(currentUserId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Create initial user document (called during registration)
  Future<bool> createUserDocument(String uid, String email, {String? displayName}) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName ?? email.split('@')[0],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'settings': {
          'temperatureUnit': 'celsius',
          'notifications': true,
          'theme': 'light',
        },
        'thresholds': {
          'temperatureMin': 15.0,
          'temperatureMax': 25.0,
          'humidityMin': 40.0,
          'humidityMax': 70.0,
        },
      });
      return true;
    } catch (e) {
      print('Error creating user document: $e');
      return false;
    }
  }

  // ============================================================================
  // DEVICE MANAGEMENT
  // ============================================================================

  /// Add a new device/freezer
  Future<String?> addDevice({
    required String deviceName,
    required String deviceId,
    String? location,
  }) async {
    try {
      if (currentUserId == null) return null;

      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('devices')
          .add({
        'deviceName': deviceName,
        'deviceId': deviceId,
        'location': location,
        'userId': currentUserId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding device: $e');
      return null;
    }
  }

  /// Get all devices for current user
  Stream<QuerySnapshot> getUserDevices() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('devices')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update device info
  Future<bool> updateDevice(String deviceDocId, Map<String, dynamic> data) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('devices')
          .doc(deviceDocId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating device: $e');
      return false;
    }
  }

  /// Delete a device
  Future<bool> deleteDevice(String deviceDocId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('devices')
          .doc(deviceDocId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting device: $e');
      return false;
    }
  }

  // ============================================================================
  // SENSOR DATA OPERATIONS
  // ============================================================================

  /// Save sensor reading to Firestore
  Future<bool> saveSensorReading({
    required String deviceId,
    required double temperature,
    required double humidity,
    DoorStatus? doorStatus,
    double? batteryLevel,
    double? solarInput,
  }) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('sensor_readings')
          .add({
        'deviceId': deviceId,
        'userId': currentUserId,
        'temperature': temperature,
        'humidity': humidity,
        'doorStatus': doorStatus?.name,
        'batteryLevel': batteryLevel,
        'solarInput': solarInput,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving sensor reading: $e');
      return false;
    }
  }

  /// Get sensor readings for a specific time range
  Stream<QuerySnapshot> getSensorReadings({
    required String deviceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    if (currentUserId == null) {
      return Stream.empty();
    }

    Query query = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('sensor_readings')
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots();
  }

  /// Get latest sensor reading
  Future<DocumentSnapshot?> getLatestSensorReading(String deviceId) async {
    try {
      if (currentUserId == null) return null;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('sensor_readings')
          .where('deviceId', isEqualTo: deviceId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      print('Error getting latest sensor reading: $e');
      return null;
    }
  }

  // ============================================================================
  // ALERTS & NOTIFICATIONS
  // ============================================================================

  /// Save alert notification
  Future<String?> saveAlert({
    required String deviceId,
    required AlertType type,
    required String title,
    required String message,
    required double value,
    required double threshold,
  }) async {
    try {
      if (currentUserId == null) return null;

      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('alerts')
          .add({
        'deviceId': deviceId,
        'userId': currentUserId,
        'type': type.name,
        'title': title,
        'message': message,
        'value': value,
        'threshold': threshold,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error saving alert: $e');
      return null;
    }
  }

  /// Get all alerts for user
  Stream<QuerySnapshot> getUserAlerts({int limit = 50}) {
    if (currentUserId == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Mark alert as read
  Future<bool> markAlertAsRead(String alertId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('alerts')
          .doc(alertId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      print('Error marking alert as read: $e');
      return false;
    }
  }

  /// Mark all alerts as read
  Future<bool> markAllAlertsAsRead() async {
    try {
      if (currentUserId == null) return false;

      final batch = _firestore.batch();
      final alerts = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('alerts')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in alerts.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all alerts as read: $e');
      return false;
    }
  }

  /// Delete alert
  Future<bool> deleteAlert(String alertId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('alerts')
          .doc(alertId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting alert: $e');
      return false;
    }
  }

  // ============================================================================
  // SETTINGS & PREFERENCES
  // ============================================================================

  /// Get user threshold settings
  Future<Map<String, double>?> getUserThresholds() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();
      final data = doc.data();
      
      if (data != null && data['thresholds'] != null) {
        return Map<String, double>.from(data['thresholds']);
      }
      return null;
    } catch (e) {
      print('Error getting user thresholds: $e');
      return null;
    }
  }

  /// Update user threshold settings
  Future<bool> updateThresholds({
    double? temperatureMin,
    double? temperatureMax,
    double? humidityMin,
    double? humidityMax,
  }) async {
    try {
      if (currentUserId == null) return false;

      Map<String, dynamic> updates = {};
      if (temperatureMin != null) updates['thresholds.temperatureMin'] = temperatureMin;
      if (temperatureMax != null) updates['thresholds.temperatureMax'] = temperatureMax;
      if (humidityMin != null) updates['thresholds.humidityMin'] = humidityMin;
      if (humidityMax != null) updates['thresholds.humidityMax'] = humidityMax;

      await _firestore.collection('users').doc(currentUserId).update(updates);
      return true;
    } catch (e) {
      print('Error updating thresholds: $e');
      return false;
    }
  }

  /// Get user settings
  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();
      final data = doc.data();
      
      if (data != null && data['settings'] != null) {
        return Map<String, dynamic>.from(data['settings']);
      }
      return null;
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  /// Update user settings
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      if (currentUserId == null) return false;

      Map<String, dynamic> updates = {};
      settings.forEach((key, value) {
        updates['settings.$key'] = value;
      });

      await _firestore.collection('users').doc(currentUserId).update(updates);
      return true;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  // ============================================================================
  // STATISTICS & ANALYTICS
  // ============================================================================

  /// Get statistics for a device over a time period
  Future<Map<String, dynamic>?> getDeviceStatistics(
    String deviceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (currentUserId == null) return null;

      final readings = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('sensor_readings')
          .where('deviceId', isEqualTo: deviceId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .get();

      if (readings.docs.isEmpty) return null;

      List<double> temperatures = [];
      List<double> humidities = [];

      for (var doc in readings.docs) {
        final data = doc.data();
        if (data['temperature'] != null) temperatures.add(data['temperature']);
        if (data['humidity'] != null) humidities.add(data['humidity']);
      }

      return {
        'totalReadings': readings.docs.length,
        'avgTemperature': temperatures.isEmpty ? 0 : temperatures.reduce((a, b) => a + b) / temperatures.length,
        'minTemperature': temperatures.isEmpty ? 0 : temperatures.reduce((a, b) => a < b ? a : b),
        'maxTemperature': temperatures.isEmpty ? 0 : temperatures.reduce((a, b) => a > b ? a : b),
        'avgHumidity': humidities.isEmpty ? 0 : humidities.reduce((a, b) => a + b) / humidities.length,
        'minHumidity': humidities.isEmpty ? 0 : humidities.reduce((a, b) => a < b ? a : b),
        'maxHumidity': humidities.isEmpty ? 0 : humidities.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      print('Error getting device statistics: $e');
      return null;
    }
  }
}
