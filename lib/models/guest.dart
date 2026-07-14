class Guest {
  final String name;
  final String phoneE164; // digits only, with country code, e.g. "919607145656"
  bool sent;

  Guest({required this.name, required this.phoneE164, this.sent = false});
}
