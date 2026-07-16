import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactService {
  ContactService._();

  static final ContactService instance = ContactService._();

  /// "0532 111 22 33" gibi girişleri uluslararası rakamlara çevirir (90532...).
  String _normalizePhone(String phone, {bool international = false}) {
    var digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (international) {
      if (digits.startsWith('+')) {
        digits = digits.substring(1);
      } else if (digits.startsWith('00')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0')) {
        digits = '90${digits.substring(1)}';
      }
    }
    return digits;
  }

  Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: _normalizePhone(phone));
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Önce WhatsApp uygulamasını (`whatsapp://`), olmazsa `wa.me` web linkini dener.
  Future<bool> whatsApp(String phone, {String? message}) async {
    final number = _normalizePhone(phone, international: true);
    if (number.isEmpty) return false;

    final text = message?.trim() ?? '';

    final candidates = <Uri>[
      Uri(
        scheme: 'whatsapp',
        host: 'send',
        queryParameters: {
          'phone': number,
          if (text.isNotEmpty) 'text': text,
        },
      ),
      Uri.https(
        'wa.me',
        '/$number',
        text.isNotEmpty ? {'text': text} : null,
      ),
      Uri.parse(
        'https://api.whatsapp.com/send?phone=$number'
        '${text.isNotEmpty ? '&text=${Uri.encodeComponent(text)}' : ''}',
      ),
    ];

    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } on MissingPluginException {
        return false;
      } on PlatformException {
        // Sonraki adayı dene.
      } catch (_) {
        // Sonraki adayı dene.
      }
    }
    return false;
  }
}
