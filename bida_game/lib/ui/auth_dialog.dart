import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/progression_service.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers cho Đăng nhập
  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers cho Đăng ký
  final _regNameController = TextEditingController();
  final _regAccountController = TextEditingController();
  final _regPasswordController = TextEditingController();

  String? _errorMessage;
  String? _successMessage;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginAccountController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regAccountController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final account = _loginAccountController.text.trim();
    final pass = _loginPasswordController.text;

    if (account.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ tài khoản và mật khẩu.');
      return;
    }

    final error = await AuthService.instance.login(
      emailOrUsername: account,
      password: pass,
    );

    if (mounted) {
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        setState(() => _successMessage = 'Đăng nhập thành công! Chào mừng ${AuthService.instance.displayName}.');
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final name = _regNameController.text.trim();
    final account = _regAccountController.text.trim();
    final pass = _regPasswordController.text;

    if (name.isEmpty || account.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ tất cả thông tin.');
      return;
    }

    final error = await AuthService.instance.register(
      emailOrUsername: account,
      password: pass,
      displayName: name,
    );

    if (mounted) {
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        setState(() => _successMessage = 'Tạo tài khoản thành công! Dữ liệu đã được lưu vào Firebase.');
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: (screenHeight * 0.9).clamp(380.0, 520.0),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1E19), Color(0xFF132A22), Color(0xFF0B1713)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF26A69A).withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              if (auth.isLoggedIn) {
                return _buildLoggedInView(auth);
              }
              return _buildAuthFormsView(auth);
            },
          ),
        ),
      ),
    );
  }

  /// Màn hình khi đã đăng nhập
  Widget _buildLoggedInView(AuthService auth) {
    final prog = ProgressionService.instance;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF081410),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_circle, color: Color(0xFF00E676), size: 24),
              const SizedBox(width: 8),
              const Text(
                'THÔNG TIN TÀI KHOẢN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar + Tên + Badge Admin
                CircleAvatar(
                  radius: 36,
                  backgroundColor: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00B0FF),
                  child: Icon(
                    auth.isAdmin ? Icons.shield : Icons.person,
                    size: 40,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 8),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: auth.isAdmin
                        ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                        : const Color(0xFF00E676).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        auth.isAdmin ? Icons.verified_user : Icons.sports_esports,
                        size: 14,
                        color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        auth.isAdmin ? 'QUẢN TRỊ VIÊN (ADMIN)' : 'THÀNH VIÊN CHÍNH THỨC',
                        style: TextStyle(
                          color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Thống kê người chơi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('CẤP ĐỘ', 'Lv.${prog.playerLevel}', Colors.amber),
                      _buildStatColumn('TIỀN VÀNG', '${prog.coins}', const Color(0xFFFFD54F)),
                      _buildStatColumn('CHIẾN THẮNG', '${prog.totalWins} Trận', const Color(0xFF00E676)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nút Đăng xuất
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFFFF5252)),
                    label: const Text(
                      'ĐĂNG XUẤT',
                      style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF5252)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  /// Màn hình biểu mẫu Đăng nhập / Đăng ký
  Widget _buildAuthFormsView(AuthService auth) {
    return Column(
      children: [
        // Tab Header
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF081410),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports, color: Color(0xFF00E676), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'TÀI KHOẢN FIREBASE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00E676),
                labelColor: const Color(0xFF00E676),
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'ĐĂNG NHẬP'),
                  Tab(text: 'ĐĂNG KÝ'),
                ],
              ),
            ],
          ),
        ),

        // Message alerts
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            color: const Color(0xFFD32F2F).withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        if (_successMessage != null)
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

        // Body TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLoginForm(auth),
              _buildRegisterForm(auth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _loginAccountController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tên tài khoản hoặc Email',
              hintText: 'admin hoặc email@gmail.com',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF00E676)),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPass,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E676)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPass ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                ),
                onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
              ),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 8),

          // Gợi ý tài khoản admin
          InkWell(
            onTap: () {
              _loginAccountController.text = 'admin';
              _loginPasswordController.text = 'admin';
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Điền nhanh tài khoản Admin: admin / admin',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: auth.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('ĐĂNG NHẬP NGAY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _regNameController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tên hiển thị (Nickname trong game)',
              hintText: 'Cơ Thủ Pro',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.badge, color: Color(0xFF00B0FF)),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regAccountController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tên tài khoản hoặc Email',
              hintText: 'player01 hoặc email@gmail.com',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person_add, color: Color(0xFF00B0FF)),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regPasswordController,
            obscureText: _obscureRegPass,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Mật khẩu (ít nhất 6 ký tự)',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00B0FF)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPass ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                ),
                onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
              ),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: auth.isLoading ? null : _handleRegister,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00B0FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: auth.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('TẠO TÀI KHOẢN MỚI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
