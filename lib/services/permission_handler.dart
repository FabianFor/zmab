import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// 🔒 Manejador de permisos compatible con TODAS las versiones de Android
class AppPermissionHandler {
  
  /// 📋 Solicitar permisos de almacenamiento según la versión de Android
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (kDebugMode) {
        print('📱 Android SDK: $sdkInt');
      }
      
      PermissionStatus status;

      // ==========================================
      // ANDROID 13+ (API 33+)
      // ==========================================
      if (sdkInt >= 33) {
        // En Android 13+, se usa READ_MEDIA_IMAGES
        // PERO para escribir en DCIM NO se necesita permiso
        if (kDebugMode) {
          print('✅ Android 13+: No se necesita permiso para DCIM');
        }
        return true;
        
      // ==========================================
      // ANDROID 10-12 (API 29-32)
      // ==========================================
      } else if (sdkInt >= 29) {
        // Scoped Storage: NO se necesita permiso para DCIM/Pictures
        if (kDebugMode) {
          print('✅ Android 10-12: No se necesita permiso para DCIM');
        }
        return true;
        
      // ==========================================
      // ANDROID 6-9 (API 23-28)
      // ==========================================
      } else if (sdkInt >= 23) {
        // Legacy Storage: SÍ necesita WRITE_EXTERNAL_STORAGE
        status = await Permission.storage.status;
        
        if (kDebugMode) {
          print('📋 Estado WRITE_EXTERNAL_STORAGE: $status');
        }
        
        if (status.isGranted) {
          if (kDebugMode) {
            print('✅ Permiso ya concedido');
          }
          return true;
        }
        
        // Pedir permiso
        status = await Permission.storage.request();
        
        if (kDebugMode) {
          print('📋 Nuevo estado: $status');
        }
        
        // Si fue denegado permanentemente
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            _showSettingsDialog(context);
          }
          return false;
        }
        
        return status.isGranted;
        
      // ==========================================
      // ANDROID 5 y anteriores (API < 23)
      // ==========================================
      } else {
        // No necesita runtime permissions
        if (kDebugMode) {
          print('✅ Android < 6: No necesita runtime permissions');
        }
        return true;
      }
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error al solicitar permisos: $e');
        print('Stack: $stackTrace');
      }
      
      // En caso de error, intentar de todos modos
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Continuando sin verificar permisos...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    }
  }

  /// ⚙️ Mostrar diálogo para ir a configuración
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permiso denegado',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Para guardar boletas en la galería, necesitas habilitar el permiso de almacenamiento.\n\n'
          'Ve a:\n'
          'Configuración → Apps → MiNegocio → Permisos → Almacenamiento',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
}
