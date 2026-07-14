import 'dart:io';
import 'package:excel/excel.dart';
import '../models/guest.dart';

class ExcelService {
  /// Reads a .xlsx file expecting columns "Guest Name" and "Contact Number"
  /// (case-insensitive, with a couple of common header variants tolerated).
  /// [defaultCountryCode] is prefixed to any 10-digit number missing one.
  static List<Guest> parseGuestList(File file, {String defaultCountryCode = '91'}) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final guests = <Guest>[];

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null || sheet.rows.isEmpty) return guests;

    final headerRow = sheet.rows.first;
    final headers = headerRow
        .map((cell) => (cell?.value?.toString() ?? '').trim().toLowerCase())
        .toList();

    int nameCol = headers.indexWhere((h) => h.contains('name'));
    int phoneCol = headers.indexWhere(
      (h) => h.contains('contact') || h.contains('phone') || h.contains('whatsapp') || h.contains('number'),
    );
    if (nameCol == -1) nameCol = 0;
    if (phoneCol == -1) phoneCol = 1;

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.length <= nameCol || row.length <= phoneCol) continue;

      final name = row[nameCol]?.value?.toString().trim() ?? '';
      final rawPhone = row[phoneCol]?.value?.toString().trim() ?? '';
      if (name.isEmpty || rawPhone.isEmpty) continue;

      final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
      final normalized = digits.length == 10 ? '$defaultCountryCode$digits' : digits;

      guests.add(Guest(name: name, phoneE164: normalized));
    }
    return guests;
  }
}
