import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  bool _isInitialized = false;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  NetworkService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      // Initialize connectivity
      await _connectivity.checkConnectivity();
      _isInitialized = true;

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('Connectivity error: $error');
          _connectionStatusController.add(false);
        },
      );

      // Initial check
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      _connectionStatusController.add(false);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!_isInitialized) return;
    
    try {
      final isConnected = result != ConnectivityResult.none;
      _connectionStatusController.add(isConnected);
    } catch (e) {
      debugPrint('Error updating connection status: $e');
      _connectionStatusController.add(false);
    }
  }

  Future<bool> isConnected() async {
    if (!_isInitialized) {
      try {
        await _initConnectivity();
      } catch (e) {
        debugPrint('Error in isConnected: $e');
        return false;
      }
    }

    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
} 