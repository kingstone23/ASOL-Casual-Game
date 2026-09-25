import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
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

    if (mounted && error != null) {
      setState(() => _errorMessage = error);
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

    if (mounted && error != null) {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final auth = AuthService.instance;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF0F2E23),
              Color(0xFF091A14),
              Color(0xFF040A08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24 : 16,
                vertical: 12,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 460 : 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- LOGO & TIÊU ĐỀ GAME ---
                    _buildGameHeader(isLandscape),
                    const SizedBox(height: 16),

                    // --- KHUNG FORM ĐĂNG NHẬP / ĐĂNG KÝ ---
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E221B).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF26A69A).withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TAB SELECTOR
                            Container(
                              color: const Color(0xFF071410),
                              child: TabBar(
                                controller: _tabController,
                                indicatorColor: const Color(0xFF00E676),
                                indicatorWeight: 3,
                                labelColor: const Color(0xFF00E676),
                                unselectedLabelColor: Colors.white54,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                                tabs: const [
                                  Tab(
                                    icon: Icon(Icons.login, size: 18),
                                    text: 'ĐĂNG NHẬP',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.person_add, size: 18),
                                    text: 'ĐĂNG KÝ',
                                  ),
                                ],
                              ),
                            ),

                            // MESSAGE ALERTS
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                color: const Color(0xFFD32F2F),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_successMessage != null)
                              Container(
                                width: double.infinity,
                                color: const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // FORM TABS CONTENT
                            SizedBox(
                              height: 310,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginForm(auth),
                                  _buildRegisterForm(auth),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // BẢO VỆ DỮ LIỆU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_clock, size: 14, color: Colors.white38),
                        SizedBox(width: 6),
                        Text(
                          'Dữ liệu đồng bộ Realtime Database & Firebase Auth an toàn',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(bool isLandscape) {
    return Column(
      children: [
        // Biểu tượng Bi 8 vàng viền bóng
        Container(
          width: isLandscape ? 56 : 64,
          height: isLandscape ? 56 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.3),
              radius: 0.8,
              colors: [Color(0xFF333333), Color(0xFF000000)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: const Color(0xFF00E676), width: 2),
          ),
          alignment: Alignment.center,
          child: Container(
            width: isLandscape ? 26 : 30,
            height: isLandscape ? 26 : 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '8',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: isLandscape ? 17 : 20,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '8 POOL BILLIARDS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Vui lòng đăng nhập để vào bàn đấu & đồng bộ xếp hạng',
          style: TextStyle(
            color: Color(0xFF80CBC4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _loginAccountController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tài khoản hoặc Email',
              hintText: 'admin hoặc player01',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF00E676), size: 20),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPass,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E676), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPass ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
              ),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),

          // Nút điền nhanh tài khoản Admin
          InkWell(
            onTap: () {
              _loginAccountController.text = 'admin';
              _loginPasswordController.text = 'admin';
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shield, color: Color(0xFFFFB300), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Điền nhanh tài khoản Admin (admin / admin)',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            icon: auth.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward, size: 20),
            label: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                  )
                : const Text(
                    'ĐĂNG NHẬP VÀO GAME',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _regNameController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tên hiển thị (Nickname)',
              hintText: 'Cơ Thủ Sài Gòn',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.badge, color: Color(0xFF00B0FF), size: 20),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _regAccountController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tên tài khoản hoặc Email',
              hintText: 'player01 hoặc email@gmail.com',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person_add, color: Color(0xFF00B0FF), size: 20),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _regPasswordController,
            obscureText: _obscureRegPass,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Mật khẩu (ít nhất 6 ký tự)',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00B0FF), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPass ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
              ),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: auth.isLoading ? null : _handleRegister,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00B0FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            icon: auth.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.how_to_reg, size: 20),
            label: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'TẠO TÀI KHOẢN MỚI',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                  ),
          ),
        ],
      ),
    );
  }
}
