/// A kitchen ticket, as a document that can actually print.
///
/// SPEC-097 097-A. The till has had a print button on its kitchen board for as
/// long as the board has existed, and it has never printed anything. Two
/// reasons, both silent:
///
///   * `EscPosKitchenTicketBuilder` encodes Latin-1 and its own divider was
///     made of U+2500 box-drawing characters, so building the bytes **threw**
///     for every order (fixed in the till, same change).
///   * Even once it builds, `ThermalPrintService` reaches the printer over a
///     `dart:io` socket or Bluetooth. Neither exists on web, and web is the
///     only target these apps ship. dart2js resolves `dart:io` to a stub whose
///     members throw at runtime, so the code compiles and fails in the kitchen.
///
/// So this takes the route the checkout already uses for receipts:
/// `Printing.layoutPdf`, which hands the document to the browser's own print
/// dialog and from there to whatever printer the machine has. No socket, no
/// pairing, no printer record to configure.
///
/// Laid out for an 80mm roll, which is what a kitchen printer takes. The
/// content is deliberately the same information the ESC/POS chit carried —
/// order number, table, time, server, priority, then the lines with their
/// modifiers and notes — because a cook already knows how to read it.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/kitchen_order.dart';
import '../models/screen_role.dart';

/// 80mm roll, minus the few millimetres a thermal head cannot reach.
const _rollWidth = 76.0 * PdfPageFormat.mm;

/// Builds the ticket.
///
/// [screenRoutingCategoryIds] and [isExpo] narrow the lines to the ones this
/// screen is responsible for, through the same `screenShowsLine` rule the board
/// filters by — printing the whole order from a grill screen would hand the
/// grill a list of desserts.
Future<List<int>> buildKitchenTicketPdf(
  KitchenOrder order, {
  required List<String> screenRoutingCategoryIds,
  required bool isExpo,
  String? locationName,
}) async {
  final lines = order.items
      .where((i) => screenShowsLine(
            lineRoutingCategoryIds: i.routingCategoryIds,
            screenRoutingCategoryIds: screenRoutingCategoryIds,
            isExpo: isExpo,
          ))
      .toList();

  final doc = pw.Document();
  final placed = order.orderTime.toLocal();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        _rollWidth,
        double.infinity,
        marginAll: 4 * PdfPageFormat.mm,
      ),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          if (order.priority != KitchenOrderPriority.normal)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              color: PdfColors.black,
              child: pw.Center(
                child: pw.Text(
                  order.priority.label.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              '#${order.orderNumber}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (order.tableNumber != null)
            pw.Center(
              child: pw.Text(
                'TABLE ${order.tableNumber}'
                '${order.tableSectionName != null ? ' · ${order.tableSectionName}' : ''}',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
          pw.SizedBox(height: 6),
          pw.Divider(height: 1, thickness: 1),
          pw.SizedBox(height: 4),
          // `.toLocal()` is load-bearing: the model normalises every date to
          // UTC, because the same field arrives as a Firestore Timestamp from
          // one writer and an ISO string from another. This slip is read by a
          // cook standing next to the printer, so it says the time on the wall.
          _row('Time', _clock(placed)),
          if (locationName != null) _row('Where', locationName),
          if (order.serverName != null) _row('Server', order.serverName!),
          _row('Type', order.orderType.label),
          pw.SizedBox(height: 4),
          pw.Divider(height: 1, thickness: 1),
          pw.SizedBox(height: 6),
          ...lines.map(_line),
          if (order.specialInstructions != null) ...[
            pw.SizedBox(height: 6),
            pw.Divider(height: 1, thickness: 1),
            pw.SizedBox(height: 4),
            pw.Text('ORDER NOTE',
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text(order.specialInstructions!,
                style: const pw.TextStyle(fontSize: 11)),
          ],
          if (order.allergyInfo != null) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(3),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1.5),
              ),
              child: pw.Text(
                'ALLERGY: ${order.allergyInfo}',
                style:
                    pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
          pw.SizedBox(height: 10),
        ],
      ),
    ),
  );

  return doc.save();
}

String _clock(DateTime at) {
  final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
  final minute = at.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${at.hour >= 12 ? 'PM' : 'AM'}';
}

pw.Widget _row(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 48,
            child: pw.Text(label,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );

pw.Widget _line(KitchenOrderItem item) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 26,
                child: pw.Text('${item.quantity}x',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                child: pw.Text(
                  item.productName,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
          // Indented under the line they belong to, so a modifier can never be
          // read as a dish of its own.
          ...item.modifiers.map(
            (m) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 26),
              child: pw.Text('${m.action.label} ${m.name}',
                  style: const pw.TextStyle(fontSize: 11)),
            ),
          ),
          if (item.cookingPreference != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 26),
              child: pw.Text(item.cookingPreference!.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
          if (item.specialInstructions != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 26),
              child: pw.Text('** ${item.specialInstructions}',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
        ],
      ),
    );
