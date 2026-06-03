import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dispute.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  bool _isLoading = true;
  List<Dispute> _disputes = [];

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    try {
      final result = await ApiService.getDisputes();
      if (mounted) {
        setState(() {
          _disputes = result.map((d) => Dispute.fromJson(d)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disputes.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.gavel_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No disputes found', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadDisputes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _disputes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final d = _disputes[index];
                      final isOpen = d.status == 'Open';
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (isOpen ? Colors.red : const Color(0xFF1A5C2A)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.gavel_rounded, color: isOpen ? Colors.red : const Color(0xFF1A5C2A), size: 20)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(d.plotNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: (isOpen ? Colors.red : const Color(0xFF1A5C2A)).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(d.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOpen ? Colors.red : const Color(0xFF1A5C2A))),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Text(d.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(height: 10),
                          Row(children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text('Filed by: ${d.filedBy}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            const Spacer(),
                            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(d.filedDate.split(' ').first, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ]),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }
}
