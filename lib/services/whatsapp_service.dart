import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends a generated card to a specific guest's WhatsApp chat, from the
/// HOST'S OWN WhatsApp account.
///
/// Android: uses a native share-intent (see MainActivity.kt) that pre-opens
/// the guest's chat with the image + caption already attached. The host
/// still taps "Send" once — that's an Android/WhatsApp security requirement,
/// not something this app can or should bypass.
///
/// iOS: Apple's sandboxing does not allow pre-selecting a WhatsApp contact
/// this way. We open WhatsApp with the message pre-filled and hand the
/// image to iOS's share sheet so the host can attach it manually — the
/// same manual step as the web version, and a platform limit, not a bug.
class WhatsAppService {
  static const _channel = MethodChannel('com.example.invite_sender/whatsapp');

  static Future<void> sendCard({
    required File cardFile,
    required String guestPhoneE164,
    required String caption,
  }) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('sendCard', {
        'cardPath': cardFile.path,
        'phone': guestPhoneE164,
        'caption': caption,
      });
    } else {
      // iOS fallback: pre-fill the text via wa.me, then let the host
      // pick WhatsApp from the standard share sheet to attach the image.
      final waUri = Uri.parse('https://wa.me/$guestPhoneE164?text=${Uri.encodeComponent(caption)}');
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
      await Share.shareXFiles([XFile(cardFile.path)], text: caption);
    }
  }
}
