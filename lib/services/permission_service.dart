import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class PermissionService {
  static final Logger _logger = Logger();
  
  /// LEER de la galería
  static Future<bool> requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _logger.i('Solicitando permisos de LECTURA para Android SDK: $sdkInt');

      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        _logger.i('Permiso photos: $status');
        return status.isGranted;
      } else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        _logger.i('Permiso storage: $status');
        return status.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logger.e('Error al solicitar permisos de lectura: $e');
      return false;
    }
  }

  /// GUARDAR en la galería (para boletas/facturas)
  static Future<bool> requestSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _logger.i('Solicitando permisos de ESCRITURA para Android SDK: $sdkInt');

      // Android 13+ (API 33+) - No necesita permisos para guardar en MediaStore
      if (sdkInt >= 33) {
        _logger.i('Android 13+: No requiere permiso para guardar');
        return true;
      }
      
      // Android 11-12 (API 30-32) - Usar MediaStore sin permisos
      else if (sdkInt >= 30) {
        _logger.i('Android 11-12: Usar MediaStore');
        return true;
      }
      
      // Android 10 (API 29) con Scoped Storage
      else if (sdkInt == 29) {
        final status = await Permission.storage.request();
        _logger.i('Permiso storage Android 10: $status');
        return status.isGranted;
      }
      
      // Android 6-9 (API 23-28)
      else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        _logger.i('Permiso storage Android 6-9: $status');
        return status.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logger.e('Error al solicitar permisos de escritura: $e');
      return false;
    }
  }

  /// Verificar permiso de LECTURA
  static Future<bool> hasStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logger.e('Error al verificar permisos: $e');
      return false;
    }
  }

  /// Verificar permiso de ESCRITURA
  static Future<bool> hasSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 11+ no necesita permisos explícitos para MediaStore
      if (sdkInt >= 30) {
        return true;
      }
      
      // Android 6-10
      if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      return false;
    }
  }

  /// Verificar si fue denegado permanentemente
  static Future<bool> isPermissionPermanentlyDenied() async {
    try {
      if (!Platform.isAndroid) return false;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isPermanentlyDenied;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isPermanentlyDenied;
      }
      
      return false;
      
    } catch (e) {
      return false;
    }
  }

  /// Abrir configuración de la app
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Solicitar TODOS los permisos necesarios
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    results['read_storage'] = await requestStoragePermission();
    results['write_storage'] = await requestSaveToGalleryPermission();
    
    _logger.i('Resultados de permisos: $results');
    
    return results;
  }
}
