import 'dart:io';
import 'package:flutter/material.dart';
import 'models/guest.dart';
import 'models/name_slot.dart';
import 'screens/template_designer_screen.dart';
import 'screens/guest_list_screen.dart';
import 'screens/send_screen.dart';

void main() => runApp(const InviteSenderApp());

class InviteSenderApp extends StatelessWidget {
  const InviteSenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invite Sender',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB8894F),
        useMaterial3: true,
      ),
      home: const FlowController(),
    );
  }
}

/// Walks the host through: design template -> add guests -> send.
/// Kept as simple in-memory state; swap for a real state-management
/// approach (Riverpod/Bloc) as the app grows past a single flow.
class FlowController extends StatefulWidget {
  const FlowController({super.key});

  @override
  State<FlowController> createState() => _FlowControllerState();
}

class _FlowControllerState extends State<FlowController> {
  File? _templateFile;
  double _naturalW = 0, _naturalH = 0;
  NameSlot? _nameSlot;
  List<Guest>? _guests;

  @override
  Widget build(BuildContext context) {
    if (_templateFile == null || _nameSlot == null) {
      return TemplateDesignerScreen(
        onSaved: (file, w, h, slot) {
          setState(() {
            _templateFile = file;
            _naturalW = w;
            _naturalH = h;
            _nameSlot = slot;
          });
        },
      );
    }

    if (_guests == null) {
      return GuestListScreen(
        onContinue: (guests) => setState(() => _guests = guests),
      );
    }

    return SendScreen(
      templateFile: _templateFile!,
      naturalW: _naturalW,
      naturalH: _naturalH,
      nameSlot: _nameSlot!,
      guests: _guests!,
    );
  }
}
