import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../models/dispute.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stamp_badge.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  bool _isLoading = true;
  List<Dispute> _disputes = [];
  int? _citizenId;
  bool _isOfficer = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    _citizenId = await SessionService.getCitizenId();
    final role = await SessionService.getRole();
    _isOfficer = role == 'Officer';
    await _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoading = true);
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

  Future<void> _resolveDispute(int disputeId) async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.resolveDispute(disputeId);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute resolved successfully'), backgroundColor: AppColors.success),
        );
        _loadDisputes();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to resolve'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showFileDisputeDialog() {
    final plotController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.edgeMargin,
                right: AppSpacing.edgeMargin,
                top: AppSpacing.xl,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const BilingualLabel(
                      englishText: 'FILE NEW DISPUTE',
                      urduText: 'نئی شکایت درج کریں',
                    ),
                    const Divider(color: AppColors.tertiary),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: plotController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Plot Number',
                        hintText: 'e.g. LHR-2024-001',
                        prefixIcon: Icon(Icons.tag_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Plot number is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the dispute in detail...',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 10)
                              ? 'Please provide at least 10 characters'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: submitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => submitting = true);
                                try {
                                  final result = await ApiService.createDispute(
                                    citizenId: _citizenId ?? 0,
                                    plotNumber: plotController.text.trim().toUpperCase(),
                                    description: descController.text.trim(),
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  if (result['success'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Dispute filed successfully'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _loadDisputes();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'Failed to file dispute'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.onPrimary),
                              )
                            : const Icon(Icons.gavel_outlined),
                        label: Text(submitting ? 'Filing...' : 'SUBMIT DISPUTE'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Registry')),
      floatingActionButton: _citizenId != null
          ? FloatingActionButton.extended(
              onPressed: _showFileDisputeDialog,
              icon: const Icon(Icons.add),
              label: const Text('File Dispute'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disputes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gavel_outlined, size: 64, color: AppColors.outline),
                      const SizedBox(height: AppSpacing.md),
                      Text('No disputes found',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Tap the button below to file a new dispute',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDisputes,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.edgeMargin,
                      AppSpacing.md,
                      AppSpacing.edgeMargin,
                      100, // space for FAB
                    ),
                    itemCount: _disputes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final d = _disputes[index];
                      final isOpen = d.status == 'Open';
                      return CertificateCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isOpen ? AppColors.error : AppColors.primary)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.gavel_outlined,
                                      color: isOpen ? AppColors.error : AppColors.primary,
                                      size: 20),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    d.plotNumber,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ),
                                StampBadge(
                                  status: isOpen
                                      ? StampStatus.pending
                                      : StampStatus.verified,
                                  customText: d.status,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              d.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('Filed by: ${d.filedBy}',
                                      style: Theme.of(context).textTheme.labelSmall),
                                ),
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(d.filedDate.split(' ').first,
                                    style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                            if (_isOfficer && isOpen) ...[
                              const SizedBox(height: AppSpacing.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _resolveDispute(d.disputeId),
                                  icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                                  label: const Text('MARK RESOLVED', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
