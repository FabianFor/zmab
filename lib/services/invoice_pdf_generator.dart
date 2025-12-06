import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';

class InvoicePdfGenerator {
  static Future<String> generatePdf({
    required dynamic invoice,
    required BusinessProfile businessProfile,
    required SettingsProvider settingsProvider,
    required Map<String, String> translations,
    String languageCode = 'es',
  }) async {
    final pdf = pw.Document();

    // ✅ Cargar fuentes con soporte multiidioma (incluyendo chino)
    pw.Font? font;
    pw.Font? fontBold;
    
    try {
      // ✅ CORRECCIÓN: Usar fuentes que soporten chino
      if (languageCode == 'zh') {
        // Opción 1: Intentar Noto Sans con soporte CJK
        try {
          font = await PdfGoogleFonts.notoSansRegular();
          fontBold = await PdfGoogleFonts.notoSansBold();
          print('✅ Fuente Noto Sans cargada para chino');
        } catch (e1) {
          // Opción 2: Usar Roboto como fallback
          font = await PdfGoogleFonts.robotoRegular();
          fontBold = await PdfGoogleFonts.robotoBold();
          print('✅ Fuente Roboto cargada como fallback para chino');
        }
      } else {
        font = await PdfGoogleFonts.notoSansRegular();
        fontBold = await PdfGoogleFonts.notoSansBold();
      }
    } catch (e) {
      print('⚠️ Error cargando fuente de Google: $e');
      // Fallback final: usar fuente por defecto del sistema
      print('⚠️ Usando fuente por defecto del sistema');
    }

    pw.ImageProvider? logoImage;
    if (businessProfile.logoPath.isNotEmpty) {
      try {
        final logoFile = File(businessProfile.logoPath);
        if (await logoFile.exists()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('⚠️ No se pudo cargar el logo: $e');
      }
    }

    pw.TextStyle getTextStyle({
      double fontSize = 12,
      bool bold = false,
      PdfColor? color,
    }) {
      if (font != null) {
        return pw.TextStyle(
          font: bold ? fontBold ?? font : font,
          fontSize: fontSize,
          color: color ?? PdfColors.black,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        );
      }
      return pw.TextStyle(
        fontSize: fontSize,
        color: color ?? PdfColors.black,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Column(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 80,
                          height: 80,
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 70,
                          height: 70,
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 2),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '🏢',
                              style: const pw.TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                pw.Text(
                  businessProfile.name.isNotEmpty 
                    ? businessProfile.name 
                    : translations['businessName'] ?? 'Business Name',
                  style: getTextStyle(fontSize: 32, bold: true),
                ),

                pw.SizedBox(height: 12),

                if (businessProfile.address.isNotEmpty)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('📍 ', style: getTextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          businessProfile.address,
                          style: getTextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                if (businessProfile.address.isNotEmpty)
                  pw.SizedBox(height: 8),

                if (businessProfile.phone.isNotEmpty)
                  pw.Row(
                    children: [
                      pw.Text('📞 ', style: getTextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        businessProfile.phone,
                        style: getTextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                if (businessProfile.phone.isNotEmpty)
                  pw.SizedBox(height: 8),

                if (businessProfile.email.isNotEmpty)
                  pw.Row(
                    children: [
                      pw.Text('📧 ', style: getTextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          businessProfile.email,
                          style: getTextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                pw.SizedBox(height: 30),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2.8),
                    1: const pw.FlexColumnWidth(1.3),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            translations['productList'] ?? 'Product list',
                            style: getTextStyle(fontSize: 13, bold: true),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            translations['quantity'] ?? 'Quantity',
                            style: getTextStyle(fontSize: 13, bold: true),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            translations['unitPrice'] ?? 'Price',
                            style: getTextStyle(fontSize: 13, bold: true),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            translations['total'] ?? 'Total',
                            style: getTextStyle(fontSize: 13, bold: true),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    ...invoice.items.map<pw.TableRow>((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              item.productName,
                              style: getTextStyle(fontSize: 12),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${item.quantity}',
                              style: getTextStyle(fontSize: 12, bold: true),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              settingsProvider.formatPrice(item.price),
                              style: getTextStyle(fontSize: 12),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              settingsProvider.formatPrice(item.total),
                              style: getTextStyle(fontSize: 12),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 20),

                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text(
                    '${translations['totalLabel'] ?? 'Total:'} ${settingsProvider.formatPrice(invoice.total)}',
                    style: getTextStyle(fontSize: 24, bold: true),
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                    style: getTextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/invoice_${invoice.invoiceNumber}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}