import 'dart:math' as math;
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
  bool _forceShowAuthForms = false;

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
        Future.delayed(const Duration(milliseconds: 1000), () {
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
        setState(() => _successMessage = 'Tạo tài khoản thành công!');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight <= 420;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: math.min(screenHeight * 0.94, isCompact ? 340.0 : 460.0),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F241C), Color(0xFF132F25), Color(0xFF081410)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF26A69A).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              if (auth.isLoggedIn && !_forceShowAuthForms && !auth.isGuest) {
                return _buildLoggedInView(auth, isCompact);
              }
              if (auth.isLoggedIn && !_forceShowAuthForms && auth.isGuest) {
                return _buildGuestProfileView(auth, isCompact);
              }
              return _buildAuthFormsView(auth, isCompact);
            },
          ),
        ),
      ),
    );
  }

  /// Màn hình khi đã đăng nhập chính thức
  Widget _buildLoggedInView(AuthService auth, bool isCompact) {
    final prog = ProgressionService.instance;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF081410),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_circle, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              const Text(
                'THÔNG TIN TÀI KHOẢN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 10 : 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: isCompact ? 26 : 32,
                  backgroundColor: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00B0FF),
                  child: Icon(
                    auth.isAdmin ? Icons.shield : Icons.person,
                    size: isCompact ? 28 : 34,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  auth.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                if (auth.currentUser?.email != null)
                  Text(
                    auth.currentUser!.email!,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                const SizedBox(height: 6),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: auth.isAdmin
                        ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                        : const Color(0xFF00E676).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        auth.isAdmin ? Icons.verified_user : Icons.sports_esports,
                        size: 12,
                        color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        auth.isAdmin ? 'QUẢN TRỊ VIÊN (ADMIN)' : 'THÀNH VIÊN CHÍNH THỨC',
                        style: TextStyle(
                          color: auth.isAdmin ? const Color(0xFFFFB300) : const Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Thống kê
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('CẤP ĐỘ', 'Lv.${prog.playerLevel}', Colors.amber),
                      _buildStatColumn('TIỀN VÀNG', '${prog.coins}', const Color(0xFFFFD54F)),
                      _buildStatColumn('CHIẾN THẮNG', '${prog.totalWins}', const Color(0xFF00E676)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Nút Đăng xuất
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFFFF5252), size: 16),
                    label: const Text(
                      'ĐĂNG XUẤT',
                      style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF5252)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  /// Màn hình khi đang chơi chế độ Khách (Guest)
  Widget _buildGuestProfileView(AuthService auth, bool isCompact) {
    final prog = ProgressionService.instance;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF081410),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFFFB300), size: 18),
              const SizedBox(width: 8),
              const Text(
                'TÀI KHOẢN KHÁCH',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 10 : 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: isCompact ? 24 : 28,
                  backgroundColor: const Color(0xFF2E4038),
                  child: const Icon(Icons.person_outline, size: 30, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  auth.displayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Chưa liên kết tài khoản • Dữ liệu lưu trên máy này',
                  style: TextStyle(color: Colors.white54, fontSize: 10.5),
                ),
                const SizedBox(height: 10),

                // Thống kê
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('CẤP ĐỘ', 'Lv.${prog.playerLevel}', Colors.amber),
                      _buildStatColumn('TIỀN VÀNG', '${prog.coins}', const Color(0xFFFFD54F)),
                      _buildStatColumn('CHIẾN THẮNG', '${prog.totalWins}', const Color(0xFF00E676)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Nút Đăng nhập / Đăng ký để lưu Cloud
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: () => setState(() => _forceShowAuthForms = true),
                    icon: const Icon(Icons.cloud_upload, size: 16),
                    label: const Text(
                      'ĐĂNG NHẬP / LƯU TIẾN TRÌNH CLOUD',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Đăng xuất
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: TextButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white60, size: 15),
                    label: const Text(
                      'Rời khỏi chế độ khách',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
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
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  /// Màn hình biểu mẫu Đăng nhập / Đăng ký trong Dialog
  Widget _buildAuthFormsView(AuthService auth, bool isCompact) {
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
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 2),
                child: Row(
                  children: [
                    if (_forceShowAuthForms)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                        onPressed: () => setState(() => _forceShowAuthForms = false),
                      ),
                    if (_forceShowAuthForms) const SizedBox(width: 8),
                    const Icon(Icons.sports_esports, color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'TÀI KHOẢN FIREBASE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.white70, size: 18),
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
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
            color: const Color(0xFFD32F2F).withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        if (_successMessage != null)
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              controller: _loginAccountController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Tài khoản hoặc Email',
                hintText: 'admin hoặc player01',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF00E676), size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _loginPasswordController,
              obscureText: _obscureLoginPass,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Mật khẩu',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E676), size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscureLoginPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Gợi ý tài khoản admin
          InkWell(
            onTap: () {
              _loginAccountController.text = 'admin';
              _loginPasswordController.text = 'admin';
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '⚡ Điền nhanh tài khoản Admin: admin / admin',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontSize: 10.5,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: auth.isLoading ? null : _handleLogin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: auth.isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                  : const Text('ĐĂNG NHẬP NGAY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              controller: _regNameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              enableSuggestions: false,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Tên hiển thị (Nickname)',
                hintText: 'Cơ Thủ Pro',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                prefixIcon: const Icon(Icons.badge, color: Color(0xFF00B0FF), size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _regAccountController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Tên tài khoản hoặc Email',
                hintText: 'player01 hoặc email@gmail.com',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                prefixIcon: const Icon(Icons.person_add, color: Color(0xFF00B0FF), size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _regPasswordController,
              obscureText: _obscureRegPass,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegister(),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Mật khẩu (ít nhất 6 ký tự)',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00B0FF), size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscureRegPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: auth.isLoading ? null : _handleRegister,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B0FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: auth.isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('TẠO TÀI KHOẢN MỚI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
