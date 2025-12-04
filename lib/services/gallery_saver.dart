import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Servicio para guardar imágenes en la galería
/// ✅ SEGURO: No expone rutas en logs de producción
class GallerySaver {
  static Future<String> saveImageToGallery({
    required String imagePath,
    required String fileName,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Guardando imagen...');
      }
      
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Archivo no encontrado');
      }

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (kDebugMode) {
          print('📱 Android SDK: $sdkInt');
        }

        final Directory? externalDir = await getExternalStorageDirectory();
        
        if (externalDir == null) {
          throw Exception('No se pudo acceder al almacenamiento');
        }

        final String basePath = externalDir.path.split('/Android')[0];
        final String targetPath = '$basePath/Pictures/MiNegocio';
        
        final Directory targetDir = Directory(targetPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
          if (kDebugMode) {
            print('📁 Carpeta creada');
          }
        }

        final String newPath = '$targetPath/$fileName';
        await file.copy(newPath);
        
        if (kDebugMode) {
          print('✅ Imagen guardada exitosamente');
        }
        
        await _scanFile(newPath);
        
        return newPath;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final newPath = '${directory.path}/$fileName';
        await file.copy(newPath);
        return newPath;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error al guardar: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  static Future<void> _scanFile(String path) async {
    try {
      if (Platform.isAndroid) {
        final result = await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$path'
        ]);
        
        if (kDebugMode && result.exitCode == 0) {
          print('📷 Media Scanner notificado');
        }
      }
    } catch (e) {
      // No crítico
    }
  }

  static String generateFileName(int invoiceNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'boleta_${invoiceNumber}_$timestamp.png';
  }

  static Future<String> saveInvoiceToGallery({
    required String tempImagePath,
    required int invoiceNumber,
  }) async {
    try {
      final fileName = generateFileName(invoiceNumber);
      final savedPath = await saveImageToGallery(
        imagePath: tempImagePath,
        fileName: fileName,
      );
      
      try {
        await File(tempImagePath).delete();
        if (kDebugMode) {
          print('🗑️ Archivo temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }
      
      return savedPath;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en saveInvoiceToGallery: $e');
      }
      rethrow;
    }
  }
}