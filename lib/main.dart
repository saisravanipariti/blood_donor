import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartBloodDonorApp());
}

class SmartBloodDonorApp extends StatelessWidget {
  const SmartBloodDonorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Blood Donor Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE11D48),
          primary: const Color(0xFFE11D48),
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

// ---------------- MODELS ----------------
class Donor {
  final String id;
  final String name;
  final String bloodType;
  final String city;
  final String phone;
  final String email;
  final int donations;
  final String lastDonation;
  bool isAvailable;

  Donor({
    required this.id,
    required this.name,
    required this.bloodType,
    required this.city,
    required this.phone,
    required this.email,
    required this.donations,
    required this.lastDonation,
    this.isAvailable = true,
  });
}

class EmergencyRequest {
  final String patientName;
  final String bloodType;
  final String hospital;
  final String city;
  final int units;
  final String timeAgo;
  final String contact;
  bool isFulfilled;

  EmergencyRequest({
    required this.patientName,
    required this.bloodType,
    required this.hospital,
    required this.city,
    required this.units,
    required this.timeAgo,
    required this.contact,
    this.isFulfilled = false,
  });
}

// ---------------- MAIN SHELL ----------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _activeTabIndex = 0;

  // Form State Variables
  String _selectedBloodType = 'O+';
  String _selectedCity = 'Visakhapatnam';
  bool _isAvailableToDonate = true;
  DateTime? _selectedLastDonationDate;
  String _dashboardSearchQuery = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _donationsController = TextEditingController(
    text: '0',
  );

  final List<Donor> donors = [
    Donor(
      id: '1',
      name: 'Ahmed Hassan',
      bloodType: 'O+',
      city: 'Dhaka',
      phone: '+8801711111111',
      email: 'ahmed@example.com',
      donations: 12,
      lastDonation: 'Aug 15, 2025',
      isAvailable: true,
    ),
    Donor(
      id: '2',
      name: 'Fatima Khan',
      bloodType: 'A+',
      city: 'Dhaka',
      phone: '+8801722222222',
      email: 'fatima@example.com',
      donations: 8,
      lastDonation: 'Sep 01, 2025',
      isAvailable: true,
    ),
    Donor(
      id: '3',
      name: 'Imran Hossain',
      bloodType: 'B+',
      city: 'Rajshahi',
      phone: '+8801733333333',
      email: 'imran@example.com',
      donations: 10,
      lastDonation: 'Jul 20, 2025',
      isAvailable: false,
    ),
    Donor(
      id: '4',
      name: 'Karim Mia',
      bloodType: 'O+',
      city: 'Dhaka',
      phone: '+8801744444444',
      email: 'karim@example.com',
      donations: 15,
      lastDonation: 'Jun 10, 2025',
      isAvailable: true,
    ),
    Donor(
      id: '5',
      name: 'Nusrat Jahan',
      bloodType: 'A-',
      city: 'Khulna',
      phone: '+8801755555555',
      email: 'nusrat@example.com',
      donations: 7,
      lastDonation: 'May 04, 2025',
      isAvailable: true,
    ),
    Donor(
      id: '6',
      name: 'Rahim Uddin',
      bloodType: 'B+',
      city: 'Chittagong',
      phone: '+8801766666666',
      email: 'rahim@example.com',
      donations: 5,
      lastDonation: 'Apr 18, 2025',
      isAvailable: false,
    ),
  ];

  final List<EmergencyRequest> requests = [
    EmergencyRequest(
      patientName: 'Emergency Patient',
      bloodType: 'O-',
      hospital: 'Square Hospital',
      city: 'Dhaka',
      units: 2,
      timeAgo: '16h ago',
      contact: '+8801799999999',
    ),
  ];
  // ---------------- POPUP: CREATE EMERGENCY BLOOD REQUEST ----------------
  void _showCreateBloodRequestDialog() {
    final patientNameCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final unitsCtrl = TextEditingController(text: '1');
    final contactPhoneCtrl = TextEditingController();
    String requestBloodType = 'O+';
    final List<String> bloodGroups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.emergency, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Request Blood (SOS)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Name *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: patientNameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Ramesh Kumar',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Blood Type *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: requestBloodType,
                              items: bloodGroups
                                  .map(
                                    (bg) => DropdownMenuItem(
                                      value: bg,
                                      child: Text(bg),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => requestBloodType = val!),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Units Needed *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: unitsCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Hospital & Location *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: hospitalCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Apollo Hospital, Visakhapatnam',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Attendant Phone (10 Digits) *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: contactPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Enter 10-digit mobile number',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final patient = patientNameCtrl.text.trim();
                final hospital = hospitalCtrl.text.trim();
                final phone = contactPhoneCtrl.text.trim();
                final units = int.tryParse(unitsCtrl.text.trim()) ?? 1;

                if (patient.isEmpty || hospital.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill out all hospital and patient details.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (phone.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mobile number must be exactly 10 digits.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Push record directly to Cloud Firestore
                await FirebaseFirestore.instance.collection('sos_requests').add(
                  {
                    'patientName': patient,
                    'bloodType': requestBloodType,
                    'hospital': hospital,
                    'city': _selectedCity,
                    'units': units,
                    'phone': '+91$phone',
                    'isFulfilled': false,
                    'createdAt': FieldValue.serverTimestamp(),
                  },
                );

                if (!mounted) return;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency request broadcasted live!'),
                    backgroundColor: Color(0xFF059669),
                  ),
                );
              },
              child: const Text('Broadcast SOS'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTopNav(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active screen view content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_activeTabIndex == 0) _buildHomeView(),
                      if (_activeTabIndex == 1) _buildSOSView(),
                      if (_activeTabIndex == 2) _buildFindDonorsView(),
                      if (_activeTabIndex == 3) _buildBecomeDonorView(),
                      if (_activeTabIndex == 4) _buildDashboardView(),
                    ],
                  ),
                  // Footer pinned cleanly to the bottom
                  _buildFooter(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBloodRequestDialog,
        backgroundColor: const Color(0xFFEF4444),
        icon: const Icon(Icons.emergency, color: Colors.white),
        label: const Text(
          'Request Blood',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopNav(BuildContext context) {
    final navItems = [
      'Home',
      'SOS Broadcast',
      'Find Donors',
      'Become a Donor',
      'Dashboard',
    ];
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      titleSpacing: 32,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Color(0xFFE11D48),
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Blood Donor',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Finder',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 32),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final isSelected = _activeTabIndex == index;
              return TextButton(
                onPressed: () => setState(() => _activeTabIndex = index),
                style: TextButton.styleFrom(
                  foregroundColor: isSelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF475569),
                ),
                child: Text(
                  navItems[index],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ---------------- VIEW 1: HOME ----------------
  Widget _buildHomeView() {
    final List<String> bloodTypes = [
      'O+',
      'A+',
      'B+',
      'AB+',
      'O-',
      'A-',
      'B-',
      'AB-',
    ];

    return Container(
      width: double.infinity,
      color: const Color(
        0xFF0C101B,
      ), // Dark navy background matching the design
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT SIDE: Text, Mascot, and Actions
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cute Mascot Image
                    Image.asset(
                      'assets/mascot.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // Tag Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE11D48).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monitor_heart_outlined,
                            color: Color(0xFFE11D48),
                            size: 15,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Real-time blood donor network',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headline with red accent
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Every drop\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: 'saves a life',
                            style: TextStyle(
                              color: Color(0xFFFF5252),
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Subtitle
                    const Text(
                      'Connect instantly with verified blood donors in your area.\nBroadcast emergency requests, find the right blood type, and\nsave lives — all in one platform.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button Row
                    Row(
                      children: [
                        // Glowing SOS Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE11D48)
                                    .withOpacity(0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _activeTabIndex = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.emergency, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Send SOS Request',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Find Donors Outline Button
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _activeTabIndex = 2),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF141A28)
                                .withOpacity(0.6),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.search,
                            size: 16,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Find Donors',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 48),

              // RIGHT SIDE: 3x3 Card Grid + Footer Tag
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.15,
                          ),
                      itemCount: 9, // 8 blood types + 1 icon slot
                      itemBuilder: (context, index) {
                        // Slot 8: Siren Icon
                        if (index == 8) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF131926),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.emergency_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 28,
                            ),
                          );
                        }

                        // Slot 0-7: Blood Group Badges
                        final type = bloodTypes[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF131926),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Bottom Subtitle Tag
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Color(0xFFE11D48),
                          size: 13,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '8 blood types · 1 mission',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- VIEW 2: SOS BROADCAST ----------------
  // ---------------- VIEW 2: SOS BROADCAST (FIRESTORE SYNCED) ----------------
  Widget _buildSOSView() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS Blood Requests',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Broadcast emergency needs or respond to active requests from patients',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateBloodRequestDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ New SOS Request'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sos_requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFFE11D48)),
                  ),
                );
              }

              final docs = snapshot.hasData ? snapshot.data!.docs : [];
              final activeDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['isFulfilled'] ?? false) == false;
              }).toList();
              final pastDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['isFulfilled'] ?? false) == true;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '● Active Emergencies (${activeDocs.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (activeDocs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'No active emergency requests right now',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    ...activeDocs.map((doc) => _buildLiveEmergencyCard(doc)),
                  const SizedBox(height: 32),
                  if (pastDocs.isNotEmpty) ...[
                    Text(
                      'Past Requests (${pastDocs.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...pastDocs.map(
                      (doc) => _buildLiveEmergencyCard(doc, isPast: true),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveEmergencyCard(DocumentSnapshot doc, {bool isPast = false}) {
    final data = doc.data() as Map<String, dynamic>;
    final String patientName = data['patientName'] ?? 'Unknown Patient';
    final String bloodType = data['bloodType'] ?? 'O+';
    final String hospital = data['hospital'] ?? 'General Hospital';
    final String city = data['city'] ?? 'Visakhapatnam';
    final int units = data['units'] ?? 1;
    final String phone = data['phone'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E293B),
            child: Text(
              bloodType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPast ? 'Fulfilled' : 'Critical',
                        style: TextStyle(
                          color: isPast ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$units unit(s) needed • $hospital, $city',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isPast)
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      patientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$units unit(s) of $bloodType blood needed'),
                        const SizedBox(height: 8),
                        Text('Location: $hospital, $city'),
                        const SizedBox(height: 4),
                        Text('Contact: $phone'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('sos_requests')
                              .doc(doc.id)
                              .update({'isFulfilled': true});
                          Navigator.pop(ctx);
                        },
                        child: const Text('Mark as Fulfilled'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              child: const Text('Help now'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(EmergencyRequest req, {bool isPast = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E293B),
            child: Text(
              req.bloodType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      req.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPast ? 'Fulfilled' : 'Critical',
                        style: TextStyle(
                          color: isPast ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${req.units} unit(s) needed • ${req.hospital}, ${req.city}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isPast)
            ElevatedButton(
              onPressed: () => _showRequestDetailsModal(req),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              child: const Text('Help now'),
            ),
        ],
      ),
    );
  }

  void _showRequestDetailsModal(EmergencyRequest req) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          req.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${req.units} unit(s) of ${req.bloodType} blood needed',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('Location: ${req.hospital}, ${req.city}'),
            const SizedBox(height: 4),
            Text('Contact: ${req.contact}'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() => req.isFulfilled = true);
              Navigator.pop(context);
            },
            child: const Text('Mark as Fulfilled'),
          ),
        ],
      ),
    );
  }

  // ---------------- VIEW 3: FIND DONORS ----------------
  // ---------------- VIEW 3: FIND DONORS ----------------
  Widget _buildFindDonorsView() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Blood Donors',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Search our network of verified donors by blood type, city, and availability',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('donors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFFE11D48)),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No donors registered yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final donor = Donor(
                    id: doc.id,
                    name: data['name'] ?? '',
                    bloodType: data['bloodType'] ?? 'O+',
                    city: data['city'] ?? '',
                    phone: data['phone'] ?? '',
                    email: data['email'] ?? '',
                    donations: data['donations'] ?? 0,
                    lastDonation: data['lastDonation'] ?? 'Never',
                    isAvailable: data['isAvailable'] ?? true,
                  );
                  return _buildDonorGridCard(donor);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonorGridCard(Donor donor) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE11D48).withOpacity(0.1),
                child: Text(
                  donor.bloodType,
                  style: const TextStyle(
                    color: Color(0xFFE11D48),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      donor.city,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: donor.isAvailable
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  donor.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: donor.isAvailable ? Colors.teal : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${donor.donations} donations',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showDonorDetailDialog(donor),
              child: const Text(
                'View details →',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDonorDetailDialog(Donor donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE11D48).withOpacity(0.1),
              child: Text(
                donor.bloodType,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE11D48),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              donor.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(donor.city, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(donor.phone),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(donor.email),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text('Last donation: ${donor.lastDonation}'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Contact ${donor.name}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- VIEW 4: BECOME A DONOR ----------------
  Widget _buildBecomeDonorView() {
    final List<String> bloodTypes = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];
    final List<String> cities = [
      'Visakhapatnam',
      'Vijayanagaram',
      'Srikakulam',
      'Tirupathi',
      'Godavari',
      'Kurnool',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dark Top Header Banner
        Container(
          color: const Color(0xFF0C101B),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Color(0xFF10B981),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Become a Donor',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join our network and help save lives in your community',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Body Form & Stats
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  // Three Info Badges
                  Row(
                    children: [
                      _buildInfoBadge(
                        icon: Icons.water_drop,
                        iconColor: const Color(0xFFEF4444),
                        text: '1 donation saves up to 3 lives',
                      ),
                      const SizedBox(width: 14),
                      _buildInfoBadge(
                        icon: Icons.favorite,
                        iconColor: const Color(0xFFEF4444),
                        text: 'Every 56 days you can donate',
                      ),
                      const SizedBox(width: 14),
                      _buildInfoBadge(
                        icon: Icons.groups_outlined,
                        iconColor: const Color(0xFF2563EB),
                        text: 'Join a growing community',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // White Card Form Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Your full name',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Blood Type Selector & City Dropdown
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Blood Type Chips
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Blood Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: bloodTypes.map((type) {
                                      final isSelected =
                                          _selectedBloodType == type;
                                      return InkWell(
                                        onTap: () => setState(
                                          () => _selectedBloodType = type,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 54,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFFE2E8F0),
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF475569),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),

                            // City Dropdown
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'City',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _selectedCity,
                                    items: cities
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedCity = val!),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Phone & Email Row
                        Row(
                          children: [
                            // 10-Digit Phone Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Enter 10-digit number',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Email Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email (optional)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'you@example.com',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Past Donations & Last Donation Date
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Past Donations',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _donationsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Last Donation Date (optional)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(
                                          () => _selectedLastDonationDate =
                                              picked,
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedLastDonationDate == null
                                                ? 'dd-mm-yyyy'
                                                : '${_selectedLastDonationDate!.day.toString().padLeft(2, '0')}-${_selectedLastDonationDate!.month.toString().padLeft(2, '0')}-${_selectedLastDonationDate!.year}',
                                            style: TextStyle(
                                              color:
                                                  _selectedLastDonationDate ==
                                                      null
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF1E293B),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18,
                                            color: Color(0xFF64748B),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Availability Checkbox Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAvailableToDonate,
                                activeColor: const Color(0xFF059669),
                                onChanged: (val) => setState(
                                  () => _isAvailableToDonate = val ?? true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'I am currently available to donate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'You can change this anytime from the dashboard',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final String donorName = _nameController.text
                                  .trim();
                              final String donorPhone = _phoneController.text
                                  .trim();

                              if (donorName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter your full name.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (donorPhone.length != 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Mobile number must be exactly 10 digits.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final String donorEmail =
                                  _emailController.text.trim().isEmpty
                                  ? 'donor@example.com'
                                  : _emailController.text.trim();
                              final int totalDonations =
                                  int.tryParse(
                                    _donationsController.text.trim(),
                                  ) ??
                                  0;
                              final String lastDonationStr =
                                  _selectedLastDonationDate != null
                                  ? '${_selectedLastDonationDate!.day}/${_selectedLastDonationDate!.month}/${_selectedLastDonationDate!.year}'
                                  : 'Never';

                              // Save to Firebase Firestore
                              await FirebaseFirestore.instance
                                  .collection('donors')
                                  .add({
                                    'name': donorName,
                                    'bloodType': _selectedBloodType,
                                    'city': _selectedCity,
                                    'phone': '+91$donorPhone',
                                    'email': donorEmail,
                                    'donations': totalDonations,
                                    'lastDonation': lastDonationStr,
                                    'isAvailable': _isAvailableToDonate,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                              _nameController.clear();
                              _phoneController.clear();
                              _emailController.clear();

                              setState(() {
                                _activeTabIndex = 2; // Jump to 'Find Donors'
                              });
                            },
                            child: const Text(
                              'Register as Donor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- VIEW 5: DASHBOARD ----------------
  // ---------------- VIEW 5: DASHBOARD (FIRESTORE SYNCED) ----------------
  // ---------------- VIEW 5: DASHBOARD (FIRESTORE SYNCED) ----------------
  Widget _buildDashboardView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('donors').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(64),
              child: CircularProgressIndicator(color: Color(0xFFE11D48)),
            ),
          );
        }

        // Convert Firestore documents into Donor objects
        final List<Donor> liveDonors = (snapshot.hasData)
            ? snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Donor(
                  id: doc.id,
                  name: data['name'] ?? '',
                  bloodType: data['bloodType'] ?? 'O+',
                  city: data['city'] ?? '',
                  phone: data['phone'] ?? '',
                  email: data['email'] ?? '',
                  donations: data['donations'] ?? 0,
                  lastDonation: data['lastDonation'] ?? 'Never',
                  isAvailable: data['isAvailable'] ?? true,
                );
              }).toList()
            : [];

        final int totalDonors = liveDonors.length;
        final int availableDonors = liveDonors
            .where((d) => d.isAvailable)
            .length;
        final int totalDonations = liveDonors.fold(
          0,
          (sum, d) => sum + d.donations,
        );

        final List<String> allBloodTypes = [
          'A+',
          'A-',
          'B+',
          'B-',
          'AB+',
          'AB-',
          'O+',
          'O-',
        ];
        final Map<String, int> bloodCounts = {
          for (var type in allBloodTypes) type: 0,
        };
        for (var d in liveDonors) {
          if (bloodCounts.containsKey(d.bloodType)) {
            bloodCounts[d.bloodType] = bloodCounts[d.bloodType]! + 1;
          }
        }

        final filteredDonors = liveDonors.where((d) {
          final q = _dashboardSearchQuery.toLowerCase();
          return d.name.toLowerCase().contains(q) ||
              d.city.toLowerCase().contains(q) ||
              d.bloodType.toLowerCase().contains(q);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark Header Banner
            Container(
              color: const Color(0xFF0C101B),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.dashboard_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Overview of donors, requests, and blood type distribution',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Dashboard Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      // Metric Cards
                      Row(
                        children: [
                          _buildDashboardMetricCard(
                            icon: Icons.people_alt,
                            iconColor: const Color(0xFF3B82F6),
                            value: '$totalDonors',
                            label: 'Total Donors',
                          ),
                          const SizedBox(width: 16),
                          _buildDashboardMetricCard(
                            icon: Icons.water_drop,
                            iconColor: const Color(0xFF10B981),
                            value: '$availableDonors',
                            label: 'Available Now',
                          ),
                          const SizedBox(width: 16),
                          _buildDashboardMetricCard(
                            icon: Icons.military_tech,
                            iconColor: const Color(0xFFF59E0B),
                            value: '$totalDonations',
                            label: 'Total Donations',
                          ),
                          const SizedBox(width: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('sos_requests')
                                .where('isFulfilled', isEqualTo: false)
                                .snapshots(),
                            builder: (context, sosSnap) {
                              final int activeSOS = sosSnap.hasData
                                  ? sosSnap.data!.docs.length
                                  : 0;
                              return _buildDashboardMetricCard(
                                icon: Icons.emergency,
                                iconColor: const Color(0xFFEF4444),
                                value: '$activeSOS',
                                label: 'Active SOS',
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Distribution & Management
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blood Type Distribution
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.show_chart,
                                        size: 18,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Blood Type Distribution',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ...allBloodTypes.map((type) {
                                    final count = bloodCounts[type] ?? 0;
                                    final double ratio = totalDonors > 0
                                        ? (count / totalDonors).clamp(0.12, 1.0)
                                        : 0.12;
                                    final bool isDark = type.contains('-');

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFEF4444),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              type,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return Stack(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  children: [
                                                    Container(
                                                      height: 26,
                                                      width: count == 0
                                                          ? 36
                                                          : constraints
                                                                    .maxWidth *
                                                                ratio,
                                                      decoration: BoxDecoration(
                                                        color: count == 0
                                                            ? const Color(
                                                                0xFFE2E8F0,
                                                              )
                                                            : const Color(
                                                                0xFFFB7185,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      alignment:
                                                          Alignment.centerRight,
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 10,
                                                          ),
                                                      child: Text(
                                                        '$count',
                                                        style: TextStyle(
                                                          color: count == 0
                                                              ? const Color(
                                                                  0xFF64748B,
                                                                )
                                                              : Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Donor Management List
                          Expanded(
                            flex: 6,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 18,
                                            color: Color(0xFF64748B),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Donor Management',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 180,
                                        height: 36,
                                        child: TextField(
                                          onChanged: (val) => setState(
                                            () => _dashboardSearchQuery = val,
                                          ),
                                          style: const TextStyle(fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Search...',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 13,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              size: 16,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 0,
                                                  horizontal: 10,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (filteredDonors.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No donors found in database.',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ...filteredDonors.map((donor) {
                                      final bool isDark = donor.bloodType
                                          .contains('-');
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF1F5F9),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFFEF4444),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                donor.bloodType,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    donor.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${donor.city} · ${donor.donations} donations',
                                                    style: const TextStyle(
                                                      color: Color(0xFF64748B),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Switch(
                                              value: donor.isAvailable,
                                              activeColor: const Color(
                                                0xFF10B981,
                                              ),
                                              activeTrackColor: const Color(
                                                0xFFD1FAE5,
                                              ),
                                              inactiveThumbColor: const Color(
                                                0xFF94A3B8,
                                              ),
                                              inactiveTrackColor: const Color(
                                                0xFFE2E8F0,
                                              ),
                                              onChanged: (val) {
                                                FirebaseFirestore.instance
                                                    .collection('donors')
                                                    .doc(donor.id)
                                                    .update({
                                                      'isAvailable': val,
                                                    });
                                              },
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('donors')
                                                    .doc(donor.id)
                                                    .delete();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bottom SOS Table (Live Firestore Stream)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.monitor_heart_outlined,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Recent SOS Requests',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('sos_requests')
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, sosSnapshot) {
                                if (sosSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  );
                                }

                                if (!sosSnapshot.hasData ||
                                    sosSnapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'No active emergency requests found in database.',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final sosDocs = sosSnapshot.data!.docs;

                                return Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2.5),
                                    1: FlexColumnWidth(1.5),
                                    2: FlexColumnWidth(2.5),
                                    3: FlexColumnWidth(1.2),
                                    4: FlexColumnWidth(1.5),
                                    5: FlexColumnWidth(1.5),
                                    6: FlexColumnWidth(0.8),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: [
                                    TableRow(
                                      children: [
                                        _tableHeader('Patient'),
                                        _tableHeader('Blood Type'),
                                        _tableHeader('Hospital'),
                                        _tableHeader('Units'),
                                        _tableHeader('Status'),
                                        _tableHeader('Contact'),
                                        const SizedBox.shrink(),
                                      ],
                                    ),
                                    ...sosDocs.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final bool isFulfilled =
                                          data['isFulfilled'] ?? false;

                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Text(
                                              data['patientName'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                data['bloodType'] ?? 'O+',
                                                style: const TextStyle(
                                                  color: Color(0xFFEF4444),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            data['hospital'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '${data['units'] ?? 1}',
                                            style: const TextStyle(
                                              color: Color(0xFF1E293B),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: InkWell(
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection('sos_requests')
                                                    .doc(doc.id)
                                                    .update({
                                                      'isFulfilled':
                                                          !isFulfilled,
                                                    });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isFulfilled
                                                      ? const Color(0xFFD1FAE5)
                                                      : const Color(0xFFFEE2E2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isFulfilled
                                                      ? 'Fulfilled'
                                                      : 'Critical',
                                                  style: TextStyle(
                                                    color: isFulfilled
                                                        ? const Color(
                                                            0xFF059669,
                                                          )
                                                        : const Color(
                                                            0xFFEF4444,
                                                          ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            data['phone'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 12,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('sos_requests')
                                                  .doc(doc.id)
                                                  .delete();
                                            },
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: const Row(
        children: [
          // Left: Copyright
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Smart Blood Donor Finder © 2026',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),

          // Center: Message
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Made with ❤️ for those who give and those in need',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),

          // Right: Empty spacer to keep the center balanced
          Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
