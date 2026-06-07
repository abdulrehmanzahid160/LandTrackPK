/// Free image API helpers — no API keys required.
class ImageHelpers {
  ImageHelpers._();

  // ─── DIRECT UNSPLASH CDN IMAGES (Highly Reliable, 100% Free) ───
  
  // High quality modern villa/house photo
  static String propertyPhoto({int w = 800, int h = 400, String keywords = ''}) {
    if (keywords.contains('satellite') || keywords.contains('map')) {
      return satelliteView(w: w, h: h);
    }
    if (keywords.contains('agriculture') || keywords.contains('farm')) {
      return farmPhoto(w: w, h: h);
    }
    return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=$w&q=80';
  }

  // Punjab/agricultural field photo
  static String farmPhoto({int w = 800, int h = 400}) =>
      'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?auto=format&fit=crop&w=$w&q=80';

  // Real estate / city view photo
  static String cityPhoto({int w = 800, int h = 400}) =>
      'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=$w&q=80';

  // Rural village/landscape photo
  static String villagePhoto({int w = 800, int h = 400}) =>
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=$w&q=80';

  // Satellite/aerial view of fields (perfect for GIS/Land map)
  static String satelliteView({int w = 800, int h = 400}) =>
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=$w&q=80';

  // ─── UI AVATARS (Citizen / Officer Profiles) ────────────
  static String avatar(String name, {int size = 128}) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=01411C&color=C9A84C&size=$size&bold=true';

  // ─── QR CODE (Certificate Verification) ─────────────────
  static String qrCode(String data, {int size = 120}) =>
      'https://api.qrserver.com/v1/create-qr-code/?size=${size}x$size&data=${Uri.encodeComponent(data)}&color=01411C';

  // ─── FLAG CDN ───────────────────────────────────────────
  static const String pakistanFlag = 'https://flagcdn.com/w80/pk.png';
  static const String pakistanFlagLarge = 'https://flagcdn.com/w320/pk.png';

  // ─── OPEN STREET MAP TILES ──────────────────────────────
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ─── PLACEHOLDER MAP IMAGE (static fallback) ────────────
  static String staticMap({double lat = 33.6844, double lon = 73.0479, int zoom = 13}) =>
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80';
}
