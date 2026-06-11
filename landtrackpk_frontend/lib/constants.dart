// LandTrack PK — API Base URL Configuration
//
// For Chrome (web):  uses http://localhost:5000/api  (same machine)
// For mobile device: uses your laptop's LAN IP      (same WiFi network)
//   → Update the IP below by running  ipconfig  in CMD

import 'package:flutter/foundation.dart' show kIsWeb;

const String _mobileBaseUrl = 'http://10.4.43.189:5000/api';
const String _webBaseUrl    = 'http://localhost:5000/api';

final String baseUrl = kIsWeb ? _webBaseUrl : _mobileBaseUrl;
