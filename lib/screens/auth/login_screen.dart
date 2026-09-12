import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../home/home_screen.dart';
import '../../driver/dashboard/driver_dashboard_screen.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final int initialRoleIndex; // 0: Student, 1: Driver, 2: Admin

  const LoginScreen({
    Key? key,
    this.initialRoleIndex = 0,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Text controllers
  final TextEditingController _studentRegNo = TextEditingController();
  final TextEditingController _studentPassword = TextEditingController();

  final TextEditingController _driverPassword = TextEditingController();

  final TextEditingController _adminId = TextEditingController();
  final TextEditingController _adminPassword = TextEditingController();

  // Selected bus for driver login
  String? _selectedBusId;
  String? _selectedBusName;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialRoleIndex,
    );
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null; // Clear error on tab change
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentRegNo.dispose();
    _studentPassword.dispose();
    _driverPassword.dispose();
    _adminId.dispose();
    _adminPassword.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    bool success = false;
    Widget? targetScreen;

    if (_tabController.index == 0) {
      // Student Auth
      success = await firebaseService.signInStudent(_studentRegNo.text, _studentPassword.text);
      if (success) targetScreen = const HomeScreen();
    } else if (_tabController.index == 1) {
      // Driver Auth - use selected bus
      if (_selectedBusId == null) {
        setState(() {
          _errorMessage = 'Please select a bus from the list';
          _isLoading = false;
        });
        return;
      }
      success = await firebaseService.signInDriver(_selectedBusId!, _driverPassword.text);
      if (success) targetScreen = const DriverDashboardScreen();
    } else {
      // Admin Auth
      success = await firebaseService.signInAdmin(_adminId.text, _adminPassword.text);
      if (success) targetScreen = const AdminDashboardScreen();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success && targetScreen != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen!),
        );
      } else {
        setState(() {
          _errorMessage = _tabController.index == 1
              ? 'Invalid Bus selection or Password'
              : 'Invalid credentials. Try demo credentials below.';
        });
      }
    }
  }

  void _autoFillDemo(int role) {
    setState(() {
      if (role == 0) {
        _tabController.animateTo(0);
        _studentRegNo.text = '22BCA001';
        _studentPassword.text = 'password';
      } else if (role == 1) {
        _tabController.animateTo(1);
        _selectedBusId = 'b12';
        _selectedBusName = 'BUS 12';
        _driverPassword.text = 'password';
      } else {
        _tabController.animateTo(2);
        _adminId.text = 'admin';
        _adminPassword.text = 'admin123';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Design
              Container(
                height: size.height * 0.32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.colorfulGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 52),
                      const SizedBox(height: 12),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.collegeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(colors: AppTheme.colorfulGradient),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'STUDENT'),
                      Tab(text: 'DRIVER'),
                      Tab(text: 'ADMIN'),
                    ],
                  ),
                ),
              ),

              // Inputs Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildStudentForm(isDark),
                            _buildDriverForm(isDark),
                            _buildAdminForm(isDark),
                          ],
                        ),
                      ),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.offlineColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          ),
                          backgroundColor: const Color(0xFF6A11CB),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Demo fill selector (highly interactive tool for fast testing)
                      _buildDemoFillSection(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Student Portal Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _studentRegNo,
          label: 'Register Number',
          icon: Icons.badge_rounded,
          hint: 'e.g. 22BCA001',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _studentPassword,
          label: 'Password',
          icon: Icons.lock_rounded,
          hint: '••••••••',
          isPassword: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDriverForm(bool isDark) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final buses = firebaseService.buses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Driver GPS Broadcast Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Bus Selection Dropdown
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[50],
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[200]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBusId,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus_rounded, color: const Color(0xFF6A11CB), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Select Your Bus',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF6A11CB)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              dropdownColor: isDark ? const Color(0xFF1B1D2A) : Colors.white,
              items: buses.map((bus) {
                return DropdownMenuItem<String>(
                  value: bus.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus_rounded, color: const Color(0xFF6A11CB), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bus.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                bus.routeName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedBusId = value;
                  if (value != null) {
                    final selectedBus = buses.firstWhere((b) => b.id == value);
                    _selectedBusName = selectedBus.name;
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _driverPassword,
          label: 'Password',
          icon: Icons.lock_rounded,
          hint: '••••••••',
          isPassword: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAdminForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Admin Console Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _adminId,
          label: 'Admin Username',
          icon: Icons.admin_panel_settings_rounded,
          hint: 'e.g. admin',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _adminPassword,
          label: 'Password',
          icon: Icons.lock_rounded,
          hint: '••••••••',
          isPassword: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDemoFillSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: Colors.purple.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.science_rounded, color: Colors.purple, size: 16),
              SizedBox(width: 6),
              Text(
                '🧪 QUICK DEMO LOGINS',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDemoButton('🎓 Student', () => _autoFillDemo(0)),
              _buildDemoButton('🚌 Driver', () => _autoFillDemo(1)),
              _buildDemoButton('🔑 Admin', () => _autoFillDemo(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: Colors.purple.withOpacity(0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
      ),
    );
  }
}
