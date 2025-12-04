import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/permission_service.dart';
import '../widgets/permission_dialog.dart';

class SaveToGalleryHelper {
  /// Guardar imagen de boleta en la galería
  static Future<bool> saveImageToGallery({
    required BuildContext context,
    required File imageFile,
    String? fileName,
  }) async {
    try {
      // 1. Verificar permiso
      bool hasPermission = await PermissionService.hasSaveToGalleryPermission();
      
      if (!hasPermission) {
        if (!context.mounted) return false;
        
        final shouldRequest = await PermissionDialog.show(
          context: context,
          title: 'Permiso para Guardar',
          message: 'Necesitamos permiso para guardar la boleta en tu galería.',
        );
        
        if (shouldRequest != true) return false;
        
        hasPermission = await PermissionService.requestSaveToGalleryPermission();
        
        if (!hasPermission) {
          final isPermanentlyDenied = await PermissionService.isPermissionPermanentlyDenied();
          if (isPermanentlyDenied && context.mounted) {
            await PermanentlyDeniedDialog.show(context);
          }
          return false;
        }
      }
      
      // 2. Obtener directorio de documentos
      final directory = await getExternalStorageDirectory();
      if (directory == null) return false;
      
      // 3. Crear carpeta de boletas si no existe
      final boletasDir = Directory('${directory.path}/Boletas');
      if (!await boletasDir.exists()) {
        await boletasDir.create(recursive: true);
      }
      
      // 4. Guardar archivo
      final newFileName = fileName ?? 'boleta_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await imageFile.copy('${boletasDir.path}/$newFileName');
      
      // 5. Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Boleta guardada correctamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // Abrir ubicación del archivo
                Share.shareXFiles([XFile(savedFile.path)]);
              },
            ),
          ),
        );
      }
      
      return true;
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Compartir imagen de boleta
  static Future<void> shareImage({
    required BuildContext context,
    required File imageFile,
    String? text,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: text ?? 'Boleta - MiNegocio',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Obtener todas las boletas guardadas
  static Future<List<File>> getSavedBoletas() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return [];
      
      final boletasDir = Directory('${directory.path}/Boletas');
      if (!await boletasDir.exists()) return [];
      
      final files = boletasDir.listSync()
          .where((item) => item is File && item.path.endsWith('.jpg'))
          .map((item) => File(item.path))
          .toList();
      
      // Ordenar por fecha (más recientes primero)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
      
    } catch (e) {
      return [];
    }
  }
}
