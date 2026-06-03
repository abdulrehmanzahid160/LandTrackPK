import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../login_screen.dart';
import 'register_land_screen.dart';
import 'approve_transfers_screen.dart';
import 'add_citizen_screen.dart';
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
        title: const Text('LandTrack PK — Officer Panel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () { setState(() => _isLoading = true); _loadData(); }),
          IconButton(icon: const Icon(Icons.logout_rounded), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome, $_name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
                  const SizedBox(height: 4),
                  Text('Officer Dashboard', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 24),

                  // Stats Row
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
                    children: [
                      _StatCard(label: 'Total Plots', value: '$_totalPlots', icon: Icons.landscape_rounded, color: const Color(0xFF1A5C2A)),
                      _StatCard(label: 'Pending Transfers', value: '$_pendingTransfers', icon: Icons.swap_horiz_rounded, color: const Color(0xFFE65100)),
                      _StatCard(label: 'Active Disputes', value: '$_activeDisputes', icon: Icons.gavel_rounded, color: const Color(0xFFC62828)),
                      _StatCard(label: 'Total Citizens', value: '$_totalCitizens', icon: Icons.people_rounded, color: const Color(0xFF1565C0)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
                  const SizedBox(height: 14),

                  _ActionTile(icon: Icons.add_location_alt_rounded, title: 'Register New Land', subtitle: 'Add a new land parcel to the registry', color: const Color(0xFF1A5C2A),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterLandScreen())).then((_) => _loadData())),
                  const SizedBox(height: 10),
                  _ActionTile(icon: Icons.check_circle_outline_rounded, title: 'Approve Transfers', subtitle: 'Review and approve pending Intiqal requests', color: const Color(0xFFE65100),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveTransfersScreen())).then((_) => _loadData())),
                  const SizedBox(height: 10),
                  _ActionTile(icon: Icons.person_add_rounded, title: 'Add Citizen', subtitle: 'Register a new citizen or officer', color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCitizenScreen())).then((_) => _loadData())),
                  const SizedBox(height: 10),
                  _ActionTile(icon: Icons.gavel_rounded, title: 'View All Disputes', subtitle: 'View all land disputes', color: const Color(0xFFC62828),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisputeScreen()))),
                ]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Icon(icon, size: 20, color: color),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, borderRadius: BorderRadius.circular(14), elevation: 1, shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ])),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ]),
        ),
      ),
    );
  }
}
