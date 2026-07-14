import 'dart:io';
import 'package:flutter/material.dart';
import '../models/guest.dart';
import '../models/name_slot.dart';
import '../services/card_generator_service.dart';
import '../services/whatsapp_service.dart';

class SendScreen extends StatefulWidget {
  final File templateFile;
  final double naturalW;
  final double naturalH;
  final NameSlot nameSlot;
  final List<Guest> guests;
  final String messageTemplate; // use {name} as placeholder

  const SendScreen({
    super.key,
    required this.templateFile,
    required this.naturalW,
    required this.naturalH,
    required this.nameSlot,
    required this.guests,
    this.messageTemplate = "Hi {name}! You're warmly invited — please find your "
        "personalised invitation card attached. We'd love to have you celebrate with us!",
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  int _current = 0;
  bool _busy = false;

  Future<void> _sendCurrent() async {
    if (_current >= widget.guests.length) return;
    setState(() => _busy = true);

    final guest = widget.guests[_current];
    try {
      final bytes = await CardGeneratorService.generateCard(
        context: context,
        templateFile: widget.templateFile,
        slot: widget.nameSlot,
        naturalWidth: widget.naturalW,
        naturalHeight: widget.naturalH,
        guestName: guest.name,
      );
      final safeFileName = '${guest.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.png';
      final file = await CardGeneratorService.saveToTempFile(bytes, safeFileName);

      final caption = widget.messageTemplate.replaceAll('{name}', guest.name);
      await WhatsAppService.sendCard(
        cardFile: file,
        guestPhoneE164: guest.phoneE164,
        caption: caption,
      );

      setState(() {
        guest.sent = true;
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not prepare this card: $e')),
        );
      }
    }
  }

  void _next() {
    setState(() => _current = (_current + 1).clamp(0, widget.guests.length));
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.guests.where((g) => g.sent).length;
    final allDone = _current >= widget.guests.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Send invitations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: widget.guests.isEmpty ? 0 : done / widget.guests.length),
            const SizedBox(height: 8),
            Text('$done of ${widget.guests.length} sent'),
            const SizedBox(height: 24),
            if (allDone)
              const Expanded(
                child: Center(child: Text('All invitations prepared 🎉', style: TextStyle(fontSize: 18))),
              )
            else ...[
              Card(
                child: ListTile(
                  title: Text(widget.guests[_current].name),
                  subtitle: Text(widget.guests[_current].phoneE164),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap "Prepare & open WhatsApp", then tap Send inside WhatsApp — '
                'it opens from your own account with this guest\'s chat and the card ready.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _busy ? null : _sendCurrent,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_busy ? 'Preparing…' : 'Prepare & open WhatsApp'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.guests[_current].sent ? _next : null,
                child: const Text('Next guest'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
