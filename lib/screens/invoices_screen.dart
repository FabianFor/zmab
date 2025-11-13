import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/invoice_provider.dart';
import '../providers/business_provider.dart';
import '../services/invoice_image_generator.dart';
import '../services/permission_handler.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletas'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: invoiceProvider.invoices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No hay boletas registradas',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: invoiceProvider.invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoiceProvider.invoices[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: InkWell(
                    onTap: () => _showInvoiceDetails(context, invoice),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Boleta #${invoice.invoiceNumber}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2196F3),
                                ),
                              ),
                              Text(
                                '\$${invoice.total.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            invoice.customerName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (invoice.customerPhone.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              invoice.customerPhone,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showInvoiceDetails(BuildContext context, invoice) {
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Boleta #${invoice.invoiceNumber}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '\$${invoice.total.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          invoice.customerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (invoice.customerPhone.isNotEmpty)
                          Text(
                            invoice.customerPhone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 24.h),
                        Text(
                          'Productos:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...invoice.items.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} x${item.quantity}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                Text(
                                  '\$${item.total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        Divider(height: 32.h, thickness: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${invoice.total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleShareInvoice(
                          context,
                          invoice,
                          businessProvider,
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDownloadInvoice(
                          context,
                          invoice,
                          businessProvider,
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleShareInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
  ) async {
    // Solicitar permisos primero
    final hasPermission = await AppPermissionHandler.requestStoragePermission(context);
    
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Se necesitan permisos para compartir la boleta'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('🔄 Generando imagen para compartir...');
      final imagePath = await InvoiceImageGenerator.generateImage(
        invoice: invoice,
        businessProfile: businessProvider.profile,
        context: context,
      );
      print('✅ Imagen generada: $imagePath');

      // Verificar que el archivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo no fue creado correctamente');
      }
      print('✅ Archivo verificado: ${await file.length()} bytes');

      if (context.mounted) Navigator.pop(context);

      print('📤 Compartiendo imagen...');
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Boleta #${invoice.invoiceNumber}',
      );
      print('✅ Resultado: ${result.status}');

      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Compartido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result.status == ShareResultStatus.dismissed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ℹ️ Compartir cancelado'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack: $stackTrace');

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleDownloadInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
  ) async {
    // Solicitar permisos primero
    final hasPermission = await AppPermissionHandler.requestStoragePermission(context);
    
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Se necesitan permisos para descargar la boleta'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('🔄 Descargando boleta...');
      final imagePath = await InvoiceImageGenerator.generateImage(
        invoice: invoice,
        businessProfile: businessProvider.profile,
        context: context,
      );
      print('✅ Guardado: $imagePath');

      // Verificar que el archivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo no fue creado correctamente');
      }
      print('✅ Archivo verificado: ${await file.length()} bytes');

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Guardado en:\n$imagePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack: $stackTrace');

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al descargar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}