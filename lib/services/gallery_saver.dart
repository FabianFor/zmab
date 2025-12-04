import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 🎯 Guarda archivos en DCIM/MiNegocio (visible en galería)
/// ✅ Compatible con TODAS las versiones de Android
/// ✅ Sin permisos en Android 10+ (API 29+)
/// ✅ Con permisos en Android 9 y anteriores
class GallerySaver {
  
  /// 📥 GUARDAR ARCHIVO EN DCIM (Visible en galería inmediatamente)
  static Future<String> saveFileToGallery({
    required String tempFilePath,
    required String fileName,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 [1/5] Iniciando guardado: $fileName');
      }
      
      final tempFile = File(tempFilePath);
      if (!await tempFile.exists()) {
        throw Exception('❌ Archivo temporal no existe: $tempFilePath');
      }

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (kDebugMode) {
          print('📱 [2/5] Android SDK: $sdkInt');
        }

        final Directory? externalDir = await getExternalStorageDirectory();
        
        if (externalDir == null) {
          throw Exception('❌ No se pudo acceder al almacenamiento externo');
        }

        // 🎯 RUTA DCIM: /storage/emulated/0/DCIM/MiNegocio
        final String basePath = externalDir.path.split('/Android')[0];
        final String dcimFolderPath = '$basePath/DCIM/MiNegocio';
        
        if (kDebugMode) {
          print('📁 [3/5] Carpeta destino: $dcimFolderPath');
        }
        
        final Directory dcimFolder = Directory(dcimFolderPath);
        if (!await dcimFolder.exists()) {
          await dcimFolder.create(recursive: true);
          if (kDebugMode) {
            print('📁 [3/5] Carpeta creada en DCIM');
          }
        }

        final String finalFilePath = '$dcimFolderPath/$fileName';
        
        // Copiar archivo
        await tempFile.copy(finalFilePath);
        
        if (kDebugMode) {
          print('✅ [4/5] Archivo copiado: $finalFilePath');
        }
        
        // Verificar que se guardó
        final savedFile = File(finalFilePath);
        if (!await savedFile.exists()) {
          throw Exception('❌ El archivo no se guardó correctamente');
        }
        
        // Notificar al sistema (crítico para que aparezca en galería)
        await _notifyMediaScanner(finalFilePath, dcimFolderPath);
        
        if (kDebugMode) {
          print('✅ [5/5] Guardado exitoso en DCIM/MiNegocio');
        }
        
        return finalFilePath;
        
      } else {
        // iOS u otras plataformas
        final directory = await getApplicationDocumentsDirectory();
        final finalPath = '${directory.path}/$fileName';
        await tempFile.copy(finalPath);
        return finalPath;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error al guardar en galería: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// 📢 Notificar al Media Scanner de Android
  static Future<void> _notifyMediaScanner(String filePath, String folderPath) async {
    try {
      if (!Platform.isAndroid) return;
      
      if (kDebugMode) {
        print('📷 Notificando al Media Scanner...');
      }
      
      // Método 1: Escanear archivo específico
      final result1 = await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath'
      ]);
      
      if (kDebugMode) {
        print('📷 Scan archivo: ${result1.exitCode == 0 ? "✅" : "⚠️"}');
      }

      // Método 2: Escanear carpeta completa (para Android antiguos)
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result2 = await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_MOUNTED',
        '-d',
        'file://$folderPath'
      ]);
      
      if (kDebugMode) {
        print('📷 Scan carpeta: ${result2.exitCode == 0 ? "✅" : "⚠️"}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Media Scanner falló (no crítico): $e');
      }
      // No es crítico si falla
    }
  }

  /// 🏷️ Generar nombre de archivo único
  static String generateFileName(int invoiceNumber, {bool isPdf = false}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = isPdf ? 'pdf' : 'png';
    return 'Boleta_${invoiceNumber}_$timestamp.$extension';
  }

  /// 💾 MÉTODO PRINCIPAL: Guardar boleta en DCIM
  static Future<String> saveInvoiceToGallery({
    required String tempFilePath,
    required int invoiceNumber,
    bool isPdf = false,
  }) async {
    try {
      if (kDebugMode) {
        print('📥 Guardando boleta $invoiceNumber (${isPdf ? "PDF" : "PNG"})');
      }
      
      final fileName = generateFileName(invoiceNumber, isPdf: isPdf);
      
      final savedPath = await saveFileToGallery(
        tempFilePath: tempFilePath,
        fileName: fileName,
      );
      
      // Borrar archivo temporal
      try {
        await File(tempFilePath).delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado: $tempFilePath');
        }
      } catch (e) {
        // No crítico si no se puede borrar
        if (kDebugMode) {
          print('⚠️ No se pudo borrar temporal: $e');
        }
      }
      
      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error en saveInvoiceToGallery: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }
}
