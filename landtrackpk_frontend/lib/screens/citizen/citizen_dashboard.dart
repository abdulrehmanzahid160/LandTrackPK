import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/session_service.dart';
import '../../services/api_service.dart';
import '../../utils/image_helpers.dart';
import '../login_screen.dart';
import 'property_detail_screen.dart';
import 'transfer_request_screen.dart';
import 'dispute_screen.dart';
import 'fard_screen.dart';
import 'service_history_screen.dart';
import 'book_appointment_screen.dart';
import 'complaints_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/news_ticker.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  String _name = '';
  String _cnic = '';
  int _citizenId = 0;
  int _navIndex = 0;
  List<Map<String, dynamic>> _properties = [];
  bool _isLoadingProperties = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final name = await SessionService.getFullName() ?? '';
    final cnic = await SessionService.getCnic() ?? '';
    final citizenId = await SessionService.getCitizenId() ?? 0;
    if (mounted) {
      setState(() {
        _name = name;
        _cnic = cnic;
        _citizenId = citizenId;
      });
      _loadProperties();
    }
  }

  Future<void> _loadProperties() async {
    if (_cnic.isEmpty) return;
    try {
      final result = await ApiService.getCitizen(_cnic);
      if (mounted && result['success'] == true) {
        setState(() {
          _properties = List<Map<String, dynamic>>.from(result['properties'] ?? []);
          _isLoadingProperties = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProperties = false);
      }
    }
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showFardSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Get Fard'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter Plot Number'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final plot = controller.text.trim();
              if (plot.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FardScreen(plotNumber: plot)),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // ─── TAB BODIES ────────────────────────────────────────

  Widget _buildHomeTab() {
    return Column(
      children: [
        const NewsTicker(
          newsItems: [
            'New policies for property transfer active from next month.',
            'Ensure your CNIC is linked to your property record.',
            'Report corrupt practices at 0800-LAND.'
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.edgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header with flag
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: ImageHelpers.pakistanFlag,
                      width: 32,
                      height: 20,
                      errorWidget: (_, __, ___) => const SizedBox(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Welcome, $_name',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Hero land image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: ImageHelpers.propertyPhoto(keywords: 'pakistan,agriculture,green,field'),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 160, color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.primaryContainer,
                      child: const Center(child: Icon(Icons.landscape, size: 48, color: AppColors.primary)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Snapshot Card
                CertificateCard(
                  hasGuilloche: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BilingualLabel(
                        englishText: 'PROPERTY SNAPSHOT',
                        urduText: 'جائیداد کا خلاصہ',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_isLoadingProperties)
                        const CircularProgressIndicator()
                      else if (_properties.isEmpty)
                        const Text('No properties registered to your CNIC.')
                      else
                        Column(
                          children: _properties.take(2).map((p) => ListTile(
                            leading: const Icon(Icons.landscape, color: AppColors.tertiary),
                            title: Text(p['plot_number'] ?? ''),
                            subtitle: Text('${p['area']} ${p['area_unit']}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PropertyDetailScreen(plotNumber: p['plot_number'])),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                const BilingualLabel(
                  englishText: 'OFFICIAL SERVICES',
                  urduText: 'سرکاری خدمات',
                ),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                  children: [
                    ServiceTile(
                      icon: Icons.description_outlined,
                      englishLabel: 'Get a Fard',
                      urduLabel: 'فرد حاصل کریں',
                      onTap: _showFardSearchDialog,
                    ),
                    ServiceTile(
                      icon: Icons.calendar_month_outlined,
                      englishLabel: 'Book Appointment',
                      urduLabel: 'وقت مقرر کریں',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BookAppointmentScreen(citizenId: _citizenId)),
                      ),
                    ),
                    ServiceTile(
                      icon: Icons.swap_horiz_outlined,
                      englishLabel: 'Transfer Request',
                      urduLabel: 'انتقال کی درخواست',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransferRequestScreen()),
                      ),
                    ),
                    ServiceTile(
                      icon: Icons.gavel_outlined,
                      englishLabel: 'Disputes',
                      urduLabel: 'تنازعات',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DisputeScreen()),
                      ),
                    ),
                    ServiceTile(
                      icon: Icons.history_outlined,
                      englishLabel: 'Service History',
                      urduLabel: 'خدمات کی تاریخ',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceHistoryScreen(citizenId: _citizenId)),
                      ),
                    ),
                    ServiceTile(
                      icon: Icons.headset_mic_outlined,
                      englishLabel: 'Complaints',
                      urduLabel: 'شکایات',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ComplaintsScreen(citizenId: _citizenId, citizenName: _name)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BilingualLabel(
            englishText: 'LAND MAP VIEW',
            urduText: 'زمین کا نقشہ',
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: ImageHelpers.propertyPhoto(w: 900, h: 500, keywords: 'satellite,map,aerial,farmland'),
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(height: 280, color: Colors.white),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 280,
                color: AppColors.surfaceVariant,
                child: const Center(child: Icon(Icons.map, size: 64, color: AppColors.primary)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Property list with images
          if (_isLoadingProperties)
            const Center(child: CircularProgressIndicator())
          else if (_properties.isEmpty)
            CertificateCard(
              child: Column(
                children: [
                  const Icon(Icons.map_outlined, size: 48, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('No land parcels found for your CNIC.'),
                ],
              ),
            )
          else
            ..._properties.map((p) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: ImageHelpers.propertyPhoto(w: 600, h: 200, keywords: 'pakistan,land,${p['land_type'] ?? 'agricultural'}'),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(height: 120, color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(height: 120, color: AppColors.primaryContainer),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.landscape, color: AppColors.tertiary),
                    title: Text(p['plot_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p['area']} ${p['area_unit']} • ${p['district'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(plotNumber: p['plot_number'])),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildVerifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
      child: Column(
        children: [
          const BilingualLabel(
            englishText: 'VERIFICATION CENTER',
            urduText: 'تصدیقی مرکز',
          ),
          const SizedBox(height: AppSpacing.xl),
          // QR Code verification
          CertificateCard(
            hasGuilloche: true,
            child: Column(
              children: [
                const Icon(Icons.verified_user, size: 48, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Your Digital Identity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('CNIC: $_cnic', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                Text('Name: $_name', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.lg),
                // QR Code from free API
                CachedNetworkImage(
                  imageUrl: ImageHelpers.qrCode('LandTrackPK-CNIC-$_cnic-VERIFIED', size: 160),
                  width: 160,
                  height: 160,
                  placeholder: (_, __) => const SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.qr_code, size: 160, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Scan to verify identity',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Property QR codes
          if (_properties.isNotEmpty) ...[
            const BilingualLabel(
              englishText: 'PROPERTY CERTIFICATES',
              urduText: 'جائیداد سرٹیفکیٹ',
            ),
            const SizedBox(height: AppSpacing.md),
            ..._properties.map((p) => CertificateCard(
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: ImageHelpers.qrCode('LandTrackPK-Plot-${p['plot_number']}'),
                    width: 80,
                    height: 80,
                    errorWidget: (_, __, ___) => const Icon(Icons.qr_code, size: 80),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['plot_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${p['area']} ${p['area_unit']}', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            const Text('Verified', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.edgeMargin),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Avatar from UI Avatars API
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.primaryContainer,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: ImageHelpers.avatar(_name.isEmpty ? 'User' : _name, size: 256),
                width: 112,
                height: 112,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.person, size: 56, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'CNIC: $_cnic',
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Citizen', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Stats row
          Row(
            children: [
              Expanded(child: _profileStat('Properties', '${_properties.length}', Icons.landscape_outlined)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _profileStat('Status', 'Active', Icons.check_circle_outline)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Actions
          _profileAction(Icons.description_outlined, 'My Fard Records', () => _showFardSearchDialog()),
          _profileAction(Icons.history_outlined, 'Service History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceHistoryScreen(citizenId: _citizenId)))),
          _profileAction(Icons.headset_mic_outlined, 'My Complaints', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintsScreen(citizenId: _citizenId, citizenName: _name)))),
          _profileAction(Icons.gavel_outlined, 'My Disputes', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisputeScreen()))),
          const Divider(height: 32),
          _profileAction(Icons.logout, 'Logout', _logout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _profileStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.officialCard,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _profileAction(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(label, style: TextStyle(color: isDestructive ? AppColors.error : null, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: isDestructive ? AppColors.error : AppColors.onSurfaceVariant),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CachedNetworkImage(
              imageUrl: ImageHelpers.pakistanFlag,
              width: 24,
              height: 16,
              errorWidget: (_, __, ___) => const SizedBox(),
            ),
            const SizedBox(width: 8),
            const Text('LandTrackPK'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Verify'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeTab(),
            _buildMapTab(),
            _buildVerifyTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }
}
