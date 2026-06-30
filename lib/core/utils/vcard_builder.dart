import '../../data/models/models.dart';

/// Builds a standard vCard (VCF) 3.0 string from a Member — the
/// universal contact-card format that any phone's camera/QR
/// scanner already knows how to read and offer to save, with no
/// app required. Used for the QR code on the back of the ID card.
///
/// Deliberately includes ONLY public-safe contact fields (name,
/// phone, email, organization, emergency contact) — never anything
/// sensitive like NRC, date of birth, or rank/unit detail, since
/// this card can be scanned by anyone, not just other members.
class VCardBuilder {
  VCardBuilder._();

  static String build(Member member) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${member.nameEn}',
      'ORG:Myanmar Red Cross Society — Botahtaung Brigade',
      if (member.phone.isNotEmpty) 'TEL;TYPE=CELL:${member.phone}',
      if (member.email.isNotEmpty) 'EMAIL:${member.email}',
      if (member.emergencyContact.isNotEmpty && member.emergencyPhone.isNotEmpty)
        'NOTE:Emergency contact — ${member.emergencyContact}: ${member.emergencyPhone}',
      'END:VCARD',
    ];
    return lines.join('\n');
  }
}