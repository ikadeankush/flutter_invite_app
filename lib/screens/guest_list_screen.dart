import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/guest.dart';
import '../services/excel_service.dart';

class GuestListScreen extends StatefulWidget {
  final void Function(List<Guest> guests) onContinue;

  const GuestListScreen({super.key, required this.onContinue});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final List<Guest> _guests = [];
  final _pasteController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '91');

  Future<void> _pickExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final parsed = ExcelService.parseGuestList(
      file,
      defaultCountryCode: _countryCodeController.text.trim().isEmpty ? '91' : _countryCodeController.text.trim(),
    );
    setState(() => _guests.addAll(parsed));
  }

  void _addPasted() {
    final lines = _pasteController.text.split('\n');
    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length < 2) continue;
      final name = parts[0].trim();
      final rawPhone = parts.sublist(1).join(',').trim();
      if (name.isEmpty || rawPhone.isEmpty) continue;

      final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
      final cc = _countryCodeController.text.trim().isEmpty ? '91' : _countryCodeController.text.trim();
      final normalized = digits.length == 10 ? '$cc$digits' : digits;
      _guests.add(Guest(name: name, phoneE164: normalized));
    }
    _pasteController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest list')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _countryCodeController,
              decoration: const InputDecoration(labelText: 'Default country code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickExcel,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload guest list (.xlsx)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pasteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Or paste: Name, Phone (one per line)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _addPasted, child: const Text('Add pasted guests')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _guests.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  title: Text(_guests[i].name),
                  subtitle: Text(_guests[i].phoneE164),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _guests.removeAt(i)),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _guests.isEmpty ? null : () => widget.onContinue(_guests),
              child: Text('Continue with ${_guests.length} guest(s)'),
            ),
          ],
        ),
      ),
    );
  }
}

