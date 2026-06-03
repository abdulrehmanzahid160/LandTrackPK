import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/session_service.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';
import 'property_detail_screen.dart';
import 'transfer_request_screen.dart';
import 'dispute_screen.dart';
import 'fard_screen.dart';
import 'service_history_screen.dart';
import 'book_appointment_screen.dart';
import 'complaints_screen.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  String _name = '';
  String _cnic = '';
  int _citizenId = 0;
  final _searchController = TextEditingController();
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;
  Timer? _carouselTimer;

  // Carousel slide data
  final List<_CarouselSlide> _slides = [
    _CarouselSlide(
      gradient: [Color(0xFF1A5C2A), Color(0xFF2E7D32)],
      title: 'Land Records\nDigitized',
      subtitle: 'Secure & transparent property management',
      icon: Icons.security_rounded,
    ),
    _CarouselSlide(
      gradient: [Color(0xFF0D47A1), Color(0xFF1565C0)],
      title: 'Fast Property\nTransfers',
      subtitle: 'Online Intiqal in just a few taps',
      icon: Icons.speed_rounded,
    ),
    _CarouselSlide(
      gradient: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
      title: 'Verified\nOwnership',
      subtitle: 'Government-backed Fard documents',
      icon: Icons.verified_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_carouselController.hasClients) {
        final nextPage = (_currentCarouselPage + 1) % _slides.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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

  Future<void> _searchPlot() async {
    final plotNumber = _searchController.text.trim();
    if (plotNumber.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(plotNumber: plotNumber),
      ),
    );
  }

  void _showCnicVerification() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5C2A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Color(0xFF1A5C2A)),
            ),
            const SizedBox(width: 12),
            const Text('CNIC Verified',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _verifyRow('Name', _name),
            _verifyRow('CNIC', _cnic),
            _verifyRow('Status', 'Active'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5C2A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF1A5C2A), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your CNIC has been verified by the system.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: Color(0xFF1A5C2A))),
          ),
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with language tag and profile avatar
            Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Carousel
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: _slides.length,
                      onPageChanged: (i) =>
                          setState(() => _currentCarouselPage = i),
                      itemBuilder: (_, i) {
                        final slide = _slides[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: slide.gradient,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Decorative circles
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                bottom: -40,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(slide.icon,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 36),
                                    const SizedBox(height: 12),
                                    Text(
                                      slide.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      slide.subtitle,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Language tag
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE07B00),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          const Text('Eng',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  // Profile avatar
                  Positioned(
                    top: 8,
                    right: 12,
                    child: GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _name.isNotEmpty
                                ? _name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel dots
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentCarouselPage == i ? 10 : 8,
                    height: _currentCarouselPage == i ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentCarouselPage == i
                          ? const Color(0xFF1B2A4A)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Menu title
                    const Text(
                      'Main Menu',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6 Action Tiles in 2-column grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _MenuTile(
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFF1A5C2A),
                          title: 'Get a\nFard',
                          onTap: () {
                            _showFardSearchDialog();
                          },
                        ),
                        _MenuTile(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF5D4037),
                          title: 'Book an\nAppointment',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookAppointmentScreen(
                                    citizenId: _citizenId),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          icon: Icons.apartment_rounded,
                          iconColor: const Color(0xFF0D47A1),
                          title: 'My\nProperties',
                          onTap: () => _loadMyProperties(),
                        ),
                        _MenuTile(
                          icon: Icons.history_rounded,
                          iconColor: const Color(0xFF00796B),
                          title: 'My Service\nHistory',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceHistoryScreen(
                                    citizenId: _citizenId),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: const Color(0xFF455A64),
                          title: 'CNIC\nVerification',
                          onTap: _showCnicVerification,
                        ),
                        _MenuTile(
                          icon: Icons.headset_mic_rounded,
                          iconColor: const Color(0xFF00897B),
                          title: 'Complaints &\nSupport',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComplaintsScreen(
                                    citizenId: _citizenId,
                                    citizenName: _name),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions section
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search Plot (e.g. LHR-2024-001)',
                                hintStyle: TextStyle(fontSize: 13),
                                prefixIcon:
                                    Icon(Icons.search_rounded, size: 20),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onSubmitted: (_) => _searchPlot(),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            child: IconButton(
                              onPressed: _searchPlot,
                              icon:
                                  const Icon(Icons.arrow_forward_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1A5C2A),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Transfer Request + Disputes row
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.swap_horiz_rounded,
                            title: 'Transfer',
                            color: const Color(0xFF1565C0),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TransferRequestScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.gavel_rounded,
                            title: 'Disputes',
                            color: const Color(0xFFC62828),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const DisputeScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFardSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Get Fard',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter Plot Number',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5C2A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final plot = controller.text.trim();
              if (plot.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FardScreen(plotNumber: plot),
                  ),
                );
              }
            },
            child:
                const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMyProperties() async {
    if (_cnic.isEmpty) return;
    try {
      final result = await ApiService.getCitizen(_cnic);
      if (mounted && result['success'] == true) {
        final props =
            List<Map<String, dynamic>>.from(result['properties'] ?? []);
        _showPropertiesSheet(props);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPropertiesSheet(List<Map<String, dynamic>> properties) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'My Properties',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: properties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_work_rounded,
                                    size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text('No properties found',
                                    style: TextStyle(
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: properties.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, index) {
                              final p = properties[index];
                              return _PropertyListCard(
                                plotNumber: p['plot_number'] ?? '',
                                area:
                                    '${p['area']} ${p['area_unit'] ?? ''}',
                                district: p['district'] ?? '',
                                landType: p['land_type'] ?? '',
                                onTap: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PropertyDetailScreen(
                                        plotNumber: p['plot_number'],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CarouselSlide {
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final IconData icon;

  const _CarouselSlide({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E8E4), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2A4A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyListCard extends StatelessWidget {
  final String plotNumber;
  final String area;
  final String district;
  final String landType;
  final VoidCallback onTap;

  const _PropertyListCard({
    required this.plotNumber,
    required this.area,
    required this.district,
    required this.landType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAF8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5C2A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.landscape_rounded,
                    color: Color(0xFF1A5C2A)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plotNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('$area · $district · $landType',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
