import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stamp_badge.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final int citizenId;
  const ServiceHistoryScreen({super.key, required this.citizenId});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _visits = [];
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await ApiService.getServiceHistory(widget.citizenId);
      if (mounted && result['success'] == true) {
        setState(() {
          _visits = List<Map<String, dynamic>>.from(result['visits'] ?? []);
          _transactions = List<Map<String, dynamic>>.from(result['transactions'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service History',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View details of the services you have availed in the past',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      labelColor: AppColors.onPrimary,
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: const [
                        Tab(text: 'My Visits'),
                        Tab(text: 'My Transactions'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVisitsTab(),
                      _buildTransactionsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVisitsTab() {
    if (_visits.isEmpty) {
      return _buildEmptyState(Icons.event_note_outlined, 'No visit records found');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
      itemCount: _visits.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) {
        final v = _visits[index];
        return _VisitCard(
          tokenNumber: v['token_number'] ?? '',
          serviceCenter: v['service_center'] ?? '',
          tehsil: v['tehsil'] ?? '',
          reason: v['reason'] ?? '',
          date: _formatDate(v['appointment_date'] ?? ''),
          time: v['appointment_time'] ?? '',
          status: v['status'] ?? 'Completed',
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return _buildEmptyState(Icons.receipt_long_outlined, 'No transaction records found');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) {
        final t = _transactions[index];
        return _TransactionCard(
          plotNumber: t['plot_number'] ?? '',
          district: t['district'] ?? '',
          fromOwner: t['from_owner'] ?? '',
          toOwner: t['to_owner'] ?? '',
          reason: t['reason'] ?? '',
          status: t['status'] ?? '',
          date: _formatDate(t['request_date'] ?? ''),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year % 100}';
    } catch (_) {
      return rawDate.split(' ').first;
    }
  }
}

class _VisitCard extends StatelessWidget {
  final String tokenNumber;
  final String serviceCenter;
  final String tehsil;
  final String reason;
  final String date;
  final String time;
  final String status;

  const _VisitCard({
    required this.tokenNumber,
    required this.serviceCenter,
    required this.tehsil,
    required this.reason,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.officialCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Token No. $tokenNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _infoRow('Service Center:', serviceCenter, time),
          const SizedBox(height: AppSpacing.xs),
          _infoRow('Tehsil:', tehsil, null),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _infoRow('Reason:', reason, null),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, String? trailing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String plotNumber;
  final String district;
  final String fromOwner;
  final String toOwner;
  final String reason;
  final String status;
  final String date;

  const _TransactionCard({
    required this.plotNumber,
    required this.district,
    required this.fromOwner,
    required this.toOwner,
    required this.reason,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending';
    final stampStatus = isPending ? StampStatus.pending : (status == 'Approved' ? StampStatus.verified : StampStatus.rejected);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.officialCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.swap_horiz_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plotNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(district, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              StampBadge(status: stampStatus, customText: status),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Text('$fromOwner → $toOwner', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(reason, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(date, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
