import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'complaint_details_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bilingual_label.dart';
import '../../widgets/stamp_badge.dart';

class ComplaintsScreen extends StatefulWidget {
  final int citizenId;
  final String citizenName;
  const ComplaintsScreen({super.key, required this.citizenId, required this.citizenName});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getComplaints(widget.citizenId);
      if (mounted && result['success'] == true) {
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(result['complaints'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNewComplaintDialog() {
    final typeController = TextEditingController();
    final detailsController = TextEditingController();
    String selectedType = 'CNIC Verification';
    final types = [
      'CNIC Verification',
      'Land Record Issue',
      'Transfer Dispute',
      'Document Error',
      'Service Complaint',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const BilingualLabel(
            englishText: 'FILE A COMPLAINT',
            urduText: 'شکایت درج کریں',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Complaint Type'),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: detailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Complaint Details',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (detailsController.text.trim().isEmpty) return;
                try {
                  final result = await ApiService.createComplaint(
                    citizenId: widget.citizenId,
                    complaintType: selectedType,
                    details: detailsController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (result['success'] == true) {
                    _loadComplaints();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Complaint #${result['complaint_id']} submitted'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Complaints Registry'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewComplaintDialog,
        icon: const Icon(Icons.add),
        label: const Text('File Complaint'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.speaker_notes_off_outlined, size: 64, color: AppColors.outline),
                      const SizedBox(height: AppSpacing.md),
                      Text('No complaints found', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                    itemCount: _complaints.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final c = _complaints[index];
                      final isOpen = c['status'] == 'Open';
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComplaintDetailsScreen(
                                complaintId: c['complaint_id'],
                                citizenName: widget.citizenName,
                              ),
                            ),
                          ).then((_) => _loadComplaints());
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: AppDecorations.officialCard,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.assignment_late_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Complaint #${c['complaint_id']}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['complaint_type'] ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (c['submitted_date'] ?? '').toString().split('.').first,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StampBadge(
                                status: isOpen ? StampStatus.pending : StampStatus.resolved,
                                customText: c['status'],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
