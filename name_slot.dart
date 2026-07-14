import 'package:flutter/material.dart';

/// Describes where and how the guest's name is drawn on a template.
/// Values are stored relative to the template's natural pixel size,
/// so the same slot works regardless of what size the phone displays it at.
class NameSlot {
  final double y; // vertical position in template pixels
  final double fontSize; // in template pixels
  final Color color;
  final bool bold;
  final double maxWidthRatio; // shrink font if the name is wider than this * template width

  const NameSlot({
    required this.y,
    this.fontSize = 58,
    this.color = const Color(0xFFB8894F),
    this.bold = true,
    this.maxWidthRatio = 0.8,
  });

  NameSlot copyWith({double? y, double? fontSize, Color? color, bool? bold}) {
    return NameSlot(
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      bold: bold ?? this.bold,
      maxWidthRatio: maxWidthRatio,
    );
  }
}

/// A saved template: the card image + its name slot + a category
/// (wedding, birthday, etc.) so the app can support a library of designs.
class CardTemplate {
  final String id;
  final String label;
  final String category;
  final String imagePath; // local file path
  final NameSlot nameSlot;
  final double naturalWidth;
  final double naturalHeight;

  const CardTemplate({
    required this.id,
    required this.label,
    required this.category,
    required this.imagePath,
    required this.nameSlot,
    required this.naturalWidth,
    required this.naturalHeight,
  });
}
