import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class ReceiptPdfHelper {
  static Future<void> generateAndDownloadReceipt(TransactionModel transaction) async {
    final pdf = pw.Document();

    // Load fonts if needed, but standard ones are fine for now
    // final font = await PdfGoogleFonts.interRegular();
    // final boldFont = await PdfGoogleFonts.interBold();

    final isReceived = transaction.amount.startsWith('+');
    final status = transaction.status.toUpperCase();
    final amountText = "${isReceived ? '+' : '-'} RS ${formatFullPrice(transaction.amountValue)}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo Section (Replicating Logoor)
              pw.Row(
                children: [
                  pw.Container(
                    width: 4,
                    height: 40,
                    color: PdfColor.fromHex('#D9BAA0'), // Primary color
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "B&L",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Real Estate",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "& Constructions",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "PVT. LTD.",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#D9BAA0'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Title
              pw.Center(
                child: pw.Text(
                  "TRANSACTION RECEIPT",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: status == 'COMPLETED' ? PdfColors.green100 : PdfColors.orange100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    status,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: status == 'COMPLETED' ? PdfColors.green : PdfColors.orange,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Amount
              pw.Center(
                child: pw.Text(
                  amountText,
                  style: pw.TextStyle(
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 50),

              // Details Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  children: [
                    _buildPdfRow("Property Name", transaction.propertyName),
                    _buildPdfDivider(),
                    _buildPdfRow("Date", transaction.date),
                    _buildPdfDivider(),
                    _buildPdfRow("EMI Number", "EMI #${transaction.emiNumber}"),
                    _buildPdfDivider(),
                    _buildPdfRow("Payment Type", transaction.paymentType.toUpperCase()),
                    _buildPdfDivider(),
                    _buildPdfRow("Reference ID", "TXN-${transaction.propertyName.hashCode.abs().toString().substring(0, 6)}"),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "This is a computer generated receipt and does not require a physical signature.",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  "Thank you for choosing B&L Real Estate & Constructions PVT. LTD.",
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    // Save and Share/Download
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${transaction.propertyName.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfDivider() {
    return pw.Divider(color: PdfColors.grey200, height: 1);
  }
}
