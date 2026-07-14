import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/name_slot.dart';

class TemplateDesignerScreen extends StatefulWidget {
  final void Function(File imageFile, double naturalW, double naturalH, NameSlot slot) onSaved;

  const TemplateDesignerScreen({super.key, required this.onSaved});

  @override
  State<TemplateDesignerScreen> createState() => _TemplateDesignerScreenState();
}

class _TemplateDesignerScreenState extends State<TemplateDesignerScreen> {
  File? _templateFile;
  double _naturalW = 0, _naturalH = 0;
  double? _tapY; // in *displayed* widget coordinates
  double _displayHeight = 0;
  double _fontSize = 58;
  Color _color = const Color(0xFFB8894F);
  bool _bold = true;
  String _sampleName = 'Mr Shailesh';

  static const double _displayWidth = 320;

  Future<void> _pickTemplate() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final decoded = await decodeImageDimensions(bytes);

    setState(() {
      _templateFile = file;
      _naturalW = decoded.$1;
      _naturalH = decoded.$2;
      _displayHeight = _displayWidth * (_naturalH / _naturalW);
      _tapY = _displayHeight * 0.45;
    });
  }

  void _save() {
    if (_templateFile == null || _tapY == null) return;
    final scale = _naturalW / _displayWidth;
    final slot = NameSlot(
      y: _tapY! * scale,
      fontSize: _fontSize,
      color: _color,
      bold: _bold,
    );
    widget.onSaved(_templateFile!, _naturalW, _naturalH, slot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design your card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickTemplate,
              icon: const Icon(Icons.upload),
              label: const Text('Upload invitation card'),
            ),
            const SizedBox(height: 16),
            if (_templateFile != null) ...[
              const Text('Tap where the guest name should appear'),
              const SizedBox(height: 8),
              GestureDetector(
                onTapDown: (details) {
                  setState(() => _tapY = details.localPosition.dy);
                },
                child: SizedBox(
                  width: _displayWidth,
                  height: _displayHeight,
                  child: Stack(
                    children: [
                      Image.file(_templateFile!, width: _displayWidth, height: _displayHeight, fit: BoxFit.fill),
                      if (_tapY != null)
                        Positioned(
                          top: _tapY! - (_fontSize * (_displayWidth / _naturalW)) / 2,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              _sampleName,
                              style: TextStyle(
                                fontSize: _fontSize * (_displayWidth / _naturalW),
                                color: _color,
                                fontWeight: _bold ? FontWeight.bold : FontWeight.normal,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Preview name'),
                controller: TextEditingController(text: _sampleName),
                onChanged: (v) => setState(() => _sampleName = v),
              ),
              Row(
                children: [
                  const Text('Font size'),
                  Expanded(
                    child: Slider(
                      min: 20,
                      max: 140,
                      value: _fontSize,
                      onChanged: (v) => setState(() => _fontSize = v),
                    ),
                  ),
                  Text(_fontSize.round().toString()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Bold  '),
                      Switch(value: _bold, onChanged: (v) => setState(() => _bold = v)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showColorPicker(context, _color);
                      if (picked != null) setState(() => _color = picked);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: _color, shape: BoxShape.circle, border: Border.all()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Continue to guest list')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reads the natural (pixel) width/height of an image from its raw bytes,
/// so name-slot coordinates are stored relative to the real card resolution
/// rather than whatever size it happens to be displayed at on screen.
Future<(double, double)> decodeImageDimensions(List<int> bytes) async {
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  final frame = await codec.getNextFrame();
  return (frame.image.width.toDouble(), frame.image.height.toDouble());
}

/// Placeholder — wire up a real color picker package (e.g. flutter_colorpicker)
/// in the actual project. Kept as a stub so this scaffold compiles conceptually.
Future<Color?> showColorPicker(BuildContext context, Color current) async {
  return showDialog<Color>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('Pick a color'),
      children: [
        for (final c in [
          const Color(0xFFB8894F),
          const Color(0xFF8B0000),
          const Color(0xFF1D9E75),
          const Color(0xFF042C53),
          Colors.black,
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, c),
            child: Container(width: 24, height: 24, color: c),
          ),
      ],
    ),
  );
}
