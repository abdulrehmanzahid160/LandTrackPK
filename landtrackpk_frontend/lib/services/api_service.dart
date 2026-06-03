import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  // ─── AUTH ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String cnic, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cnic': cnic, 'password': password, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addCitizen({
    required String fullName,
    required String cnic,
    required String phone,
    required String street,
    required String city,
    required String district,
    required String postalCode,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-citizen'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'cnic': cnic,
        'phone': phone,
        'street': street,
        'city': city,
        'district': district,
        'postal_code': postalCode,
        'password': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  // ─── PROPERTY ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getProperty(String plotNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/property/$plotNumber'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerLand({
    required String plotNumber,
    required double area,
    required String areaUnit,
    required String landType,
    required String district,
    required String tehsil,
    required String ownerCnic,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-land'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'plot_number': plotNumber,
        'area': area,
        'area_unit': areaUnit,
        'land_type': landType,
        'district': district,
        'tehsil': tehsil,
        'owner_cnic': ownerCnic,
      }),
    );
    return jsonDecode(response.body);
  }

  // ─── CITIZEN ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getCitizen(String cnic) async {
    final response = await http.get(
      Uri.parse('$baseUrl/citizen/$cnic'),
    );
    return jsonDecode(response.body);
  }

  // ─── TRANSFERS ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createTransferRequest({
    required String plotNumber,
    required String fromCnic,
    required String toCnic,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transfer-request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'plot_number': plotNumber,
        'from_cnic': fromCnic,
        'to_cnic': toCnic,
        'reason': reason,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getPendingTransfers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transfers/pending'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> approveTransfer(int transferId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approve-transfer/$transferId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // ─── DISPUTES ──────────────────────────────────────────
  static Future<List<dynamic>> getDisputes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/disputes'),
    );
    return jsonDecode(response.body);
  }

  // ─── DASHBOARD ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
    );
    return jsonDecode(response.body);
  }

  // ─── HEALTH ────────────────────────────────────────────
  static Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
    );
    return jsonDecode(response.body);
  }

  // ─── FARD (Land Record Document) ──────────────────────
  static Future<Map<String, dynamic>> getFard(String plotNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/fard/$plotNumber'),
    );
    return jsonDecode(response.body);
  }

  // ─── SERVICE HISTORY ──────────────────────────────────
  static Future<Map<String, dynamic>> getServiceHistory(int citizenId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/service-history/$citizenId'),
    );
    return jsonDecode(response.body);
  }

  // ─── APPOINTMENTS ─────────────────────────────────────
  static Future<Map<String, dynamic>> bookAppointment({
    required int citizenId,
    required String serviceCenter,
    required String tehsil,
    required String reason,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book-appointment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'citizen_id': citizenId,
        'service_center': serviceCenter,
        'tehsil': tehsil,
        'reason': reason,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
      }),
    );
    return jsonDecode(response.body);
  }

  // ─── COMPLAINTS ───────────────────────────────────────
  static Future<Map<String, dynamic>> getComplaints(int citizenId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints/$citizenId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getComplaintDetails(int complaintId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaint/$complaintId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createComplaint({
    required int citizenId,
    required String complaintType,
    required String details,
    String attachmentPath = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaint/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'citizen_id': citizenId,
        'complaint_type': complaintType,
        'details': details,
        'attachment_path': attachmentPath,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addComplaintComment({
    required int complaintId,
    required String senderType,
    required String senderName,
    required String commentText,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaint/comment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'complaint_id': complaintId,
        'sender_type': senderType,
        'sender_name': senderName,
        'comment_text': commentText,
      }),
    );
    return jsonDecode(response.body);
  }
}
