import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/land_parcel.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String plotNumber;
  const PropertyDetailScreen({super.key, required this.plotNumber});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = true;
  LandParcel? _parcel;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final result = await ApiService.getProperty(widget.plotNumber);
      if (mounted) {
        if (result['success'] == true) {
          setState(() { _parcel = LandParcel.fromJson(result); _isLoading = false; });
        } else {
          setState(() { _error = result['message'] ?? 'Plot not found'; _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Connection error: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInfoCard(), const SizedBox(height: 20),
                    _buildOwnerCard(), const SizedBox(height: 20),
                    _buildHistorySection(),
                  ]),
                ),
    );
  }

  Widget _buildInfoCard() {
    final p = _parcel!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(p.plotNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B2A4A)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF1A5C2A).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A5C2A))),
          ),
        ]),
        const Divider(height: 28),
        _detailRow(Icons.straighten_rounded, 'Area', '${p.area} ${p.areaUnit}'),
        _detailRow(Icons.category_rounded, 'Land Type', p.landType),
        _detailRow(Icons.location_city_rounded, 'District', p.district),
        _detailRow(Icons.map_rounded, 'Tehsil', p.tehsil),
        _detailRow(Icons.calendar_today_rounded, 'Registered', p.registeredDate),
      ]),
    );
  }

  Widget _buildOwnerCard() {
    final p = _parcel!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A5C2A).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_rounded, color: Color(0xFF1A5C2A))),
          const SizedBox(width: 14),
          const Text('Current Owner', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
        ]),
        const Divider(height: 28),
        _detailRow(Icons.person_outline_rounded, 'Name', p.ownerName ?? 'N/A'),
        _detailRow(Icons.credit_card_rounded, 'CNIC', p.ownerCnic ?? 'N/A'),
        _detailRow(Icons.date_range_rounded, 'Acquired', p.acquiredDate ?? 'N/A'),
      ]),
    );
  }

  Widget _buildHistorySection() {
    final history = _parcel!.history;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Ownership History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
      const SizedBox(height: 12),
      if (history.isEmpty)
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No transfer history', style: TextStyle(color: Colors.grey.shade500)),
          ]))
      else
        ...history.map((h) => Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF6A1B9A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6A1B9A), size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${h['previous_owner']} → ${h['new_owner']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(h['transfer_date'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ])),
          ]),
        )),
    ]);
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Icon(icon, size: 18, color: Colors.grey.shade400), const SizedBox(width: 12),
      SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
    ]));
  }
}
