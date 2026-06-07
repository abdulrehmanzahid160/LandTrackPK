import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/transfer_request.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';

class ApproveTransfersScreen extends StatefulWidget {
  const ApproveTransfersScreen({super.key});

  @override
  State<ApproveTransfersScreen> createState() => _ApproveTransfersScreenState();
}

class _ApproveTransfersScreenState extends State<ApproveTransfersScreen> {
  bool _isLoading = true;
  List<TransferRequest> _transfers = [];

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    try {
      final result = await ApiService.getPendingTransfers();
      if (mounted) {
        setState(() {
          _transfers = result.map((t) => TransferRequest.fromJson(t)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transfers: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _approve(int id, String plotNumber) async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.approveTransfer(id);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer approved for Plot: $plotNumber'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadTransfers();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving transfer: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Transfers (Intiqal)')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _transfers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz_outlined, size: 64, color: AppColors.outline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No pending transfers found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransfers,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                      itemCount: _transfers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final t = _transfers[index];
                        return CertificateCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.swap_horiz_outlined,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      t.plotNumber,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'PENDING',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: AppSpacing.xl),
                              _detailItem('From Owner', t.fromOwner),
                              _detailItem('To Owner', t.toOwner),
                              _detailItem('Reason', t.reason),
                              _detailItem('Request Date', t.requestDate.split(' ').first),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Rejection requires review, coming soon.'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.error),
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('REJECT'),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _approve(t.transferId, t.plotNumber),
                                      child: const Text('APPROVE'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
