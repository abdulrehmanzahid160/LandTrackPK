import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/service_tile.dart';
import '../login_screen.dart';
import 'register_land_screen.dart';
import 'approve_transfers_screen.dart';
import 'add_citizen_screen.dart';
import 'manage_users_screen.dart';
import '../citizen/dispute_screen.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  String _name = '';
  bool _isLoading = true;
  int _totalPlots = 0;
  int _pendingTransfers = 0;
  int _activeDisputes = 0;
  int _totalCitizens = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await SessionService.getFullName() ?? '';
    setState(() => _name = name);
    try {
      final stats = await ApiService.getDashboardStats();
      if (mounted) {
        setState(() {
          _totalPlots = stats['total_plots'] ?? 0;
          _pendingTransfers = stats['pending_transfers'] ?? 0;
          _activeDisputes = stats['active_disputes'] ?? 0;
          _totalCitizens = stats['total_citizens'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Panel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _isLoading = true); _loadData(); }),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, $_name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Text('Officer Dashboard', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.xl),

                    // Stats Row
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.6,
                      children: [
                        _StatCard(label: 'Total Plots', value: '$_totalPlots', icon: Icons.landscape_outlined, color: AppColors.primary),
                        _StatCard(label: 'Pending Transfers', value: '$_pendingTransfers', icon: Icons.swap_horiz_outlined, color: AppColors.error),
                        _StatCard(label: 'Active Disputes', value: '$_activeDisputes', icon: Icons.gavel_outlined, color: AppColors.error),
                        _StatCard(label: 'Total Citizens', value: '$_totalCitizens', icon: Icons.people_outline, color: AppColors.tertiary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),

                    ServiceTile(
                      icon: Icons.add_location_alt_outlined,
                      englishLabel: 'Register New Land',
                      urduLabel: 'زمین رجسٹر کریں',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterLandScreen())).then((_) => _loadData()),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ServiceTile(
                      icon: Icons.check_circle_outline,
                      englishLabel: 'Approve Transfers',
                      urduLabel: 'انتقال منظور کریں',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveTransfersScreen())).then((_) => _loadData()),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ServiceTile(
                      icon: Icons.person_add_outlined,
                      englishLabel: 'Add Citizen',
                      urduLabel: 'شہری شامل کریں',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCitizenScreen())).then((_) => _loadData()),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ServiceTile(
                      icon: Icons.manage_accounts_outlined,
                      englishLabel: 'Manage Users',
                      urduLabel: 'صارفین کا انتظام',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())).then((_) => _loadData()),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ServiceTile(
                      icon: Icons.gavel_outlined,
                      englishLabel: 'View All Disputes',
                      urduLabel: 'تمام تنازعات دیکھیں',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisputeScreen())),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.officialCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
