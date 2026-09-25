import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedTab = 0; // 0: Đăng nhập, 1: Đăng ký

  // Controllers & FocusNodes cho Đăng nhập
  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginAccountFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();

  // Controllers & FocusNodes cho Đăng ký
  final _regNameController = TextEditingController();
  final _regAccountController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regNameFocus = FocusNode();
  final _regAccountFocus = FocusNode();
  final _regPasswordFocus = FocusNode();

  String? _errorMessage;
  String? _successMessage;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;

  @override
  void dispose() {
    _loginAccountController.dispose();
    _loginPasswordController.dispose();
    _loginAccountFocus.dispose();
    _loginPasswordFocus.dispose();

    _regNameController.dispose();
    _regAccountController.dispose();
    _regPasswordController.dispose();
    _regNameFocus.dispose();
    _regAccountFocus.dispose();
    _regPasswordFocus.dispose();

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

  Future<void> _handleGuestLogin() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final error = await AuthService.instance.loginAsGuest();
    if (mounted && error != null) {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = size.width > size.height;
    final auth = AuthService.instance;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [
              Color(0xFF0F3226),
              Color(0xFF091F17),
              Color(0xFF040D0A),
            ],
          ),
        ),
        child: SafeArea(
          child: isLandscape
              ? _buildLandscapeLayout(context, auth)
              : _buildPortraitLayout(context, auth),
        ),
      ),
    );
  }

  // =========================================================================
  // GIAO DIỆN MOBILE LANDSCAPE (CÂY WIDGET CỐ ĐỊNH, KHÔNG BỊ UNMOUNT KHI MỞ BÀN PHÍM)
  // =========================================================================
  Widget _buildLandscapeLayout(BuildContext context, AuthService auth) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- CỘT TRÁI: LOGO, TÊN GAME & NÚT CHƠI NGAY (KHÁCH) ---
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: _buildBrandPanel(auth),
                ),
              ),

              // --- CỘT PHẢI: KHUNG ĐĂNG NHẬP / ĐĂNG KÝ PHONG CÁCH GAMING ---
              Expanded(
                flex: 6,
                child: _buildFormCard(auth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // CỘT THƯƠNG HIỆU & NÚT CHƠI NGAY
  // =========================================================================
  Widget _buildBrandPanel(AuthService auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo Bi 8 + Tiêu đề ngang
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _build8BallLogo(size: 48),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '8 POOL MASTER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'BIDA 8 LỖ CASUAL • MULTIPLAYER',
                    style: TextStyle(
                      color: Color(0xFF69F0AE),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Các đặc sắc của game (Features bullet list)
        _buildFeatureItem(Icons.sports_esports, 'Vật lý bi chuẩn xác, trải nghiệm chân thực'),
        const SizedBox(height: 6),
        _buildFeatureItem(Icons.leaderboard, 'Bảng xếp hạng & thành tích đồng bộ Realtime'),
        const SizedBox(height: 6),
        _buildFeatureItem(Icons.people_alt, 'Đấu với Bạn bè, Bot AI và Luyện tập nâng cao'),

        const SizedBox(height: 14),

        // Nút CHƠI NGAY (KHÁCH) - Rất quan trọng trên mobile
        InkWell(
          onTap: auth.isLoading ? null : _handleGuestLogin,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A2F), Color(0xFF132720)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Color(0xFF00E676),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CHƠI NGAY (KHÁCH)',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Vào bàn ngay tức thì, không cần đăng ký',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF00E676),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00B0FF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // KHUNG BIỂU MẪU ĐĂNG NHẬP / ĐĂNG KÝ
  // =========================================================================
  Widget _buildFormCard(AuthService auth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E17).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF26A69A).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh chuyển đổi Tab (Đăng nhập / Đăng ký)
            _buildTabSelector(),

            // Thông báo lỗi / thành công (nếu có)
            if (_errorMessage != null) _buildAlertBanner(_errorMessage!, isError: true),
            if (_successMessage != null) _buildAlertBanner(_successMessage!, isError: false),

            // Nội dung biểu mẫu theo Tab đang chọn
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: _selectedTab == 0
                  ? _buildLoginForm(auth)
                  : _buildRegisterForm(auth),
            ),
          ],
        ),
      ),
    );
  }

  // Bộ chọn Tab phong cách Game Capsule
  Widget _buildTabSelector() {
    return Container(
      color: const Color(0xFF061410),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'ĐĂNG NHẬP',
              icon: Icons.login,
              isSelected: _selectedTab == 0,
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                  _errorMessage = null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              title: 'ĐĂNG KÝ',
              icon: Icons.person_add_alt_1,
              isSelected: _selectedTab == 1,
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                  _errorMessage = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F3628) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF00E676) : Colors.white54,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E676) : Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String message, {required bool isError}) {
    return Container(
      color: isError
          ? const Color(0xFFD32F2F).withValues(alpha: 0.9)
          : const Color(0xFF2E7D32).withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => setState(() {
              _errorMessage = null;
              _successMessage = null;
            }),
            child: const Icon(Icons.close, color: Colors.white70, size: 14),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BIỂU MẪU ĐĂNG NHẬP
  // =========================================================================
  Widget _buildLoginForm(AuthService auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Tài khoản
        _buildTextField(
          controller: _loginAccountController,
          focusNode: _loginAccountFocus,
          labelText: 'Tài khoản hoặc Email',
          hintText: 'admin hoặc player01',
          icon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _loginPasswordFocus.requestFocus(),
        ),
        const SizedBox(height: 8),

        // Input Mật khẩu
        _buildTextField(
          controller: _loginPasswordController,
          focusNode: _loginPasswordFocus,
          labelText: 'Mật khẩu',
          hintText: '••••••',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscureLoginPass,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _obscureLoginPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white54,
              size: 16,
            ),
            onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
          ),
        ),

        const SizedBox(height: 6),

        // Nút điền nhanh tài khoản Admin gọn gàng
        InkWell(
          onTap: () {
            _loginAccountController.text = 'admin';
            _loginPasswordController.text = 'admin';
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFFFFB300), size: 13),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '⚡ Điền nhanh tài khoản Admin: admin / admin',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Nút Đăng nhập chính
        SizedBox(
          height: 38,
          child: FilledButton.icon(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.zero,
              elevation: 3,
            ),
            icon: auth.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.play_arrow, size: 18),
            label: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                  )
                : const Text(
                    'VÀO BÀN CHƠI',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // BIỂU MẪU ĐĂNG KÝ
  // =========================================================================
  Widget _buildRegisterForm(AuthService auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _regNameController,
          focusNode: _regNameFocus,
          labelText: 'Tên hiển thị (Nickname)',
          hintText: 'Cơ Thủ Sài Gòn',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _regAccountFocus.requestFocus(),
        ),
        const SizedBox(height: 7),
        _buildTextField(
          controller: _regAccountController,
          focusNode: _regAccountFocus,
          labelText: 'Tên tài khoản hoặc Email',
          hintText: 'player01 hoặc email@gmail.com',
          icon: Icons.person_add_outlined,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _regPasswordFocus.requestFocus(),
        ),
        const SizedBox(height: 7),
        _buildTextField(
          controller: _regPasswordController,
          focusNode: _regPasswordFocus,
          labelText: 'Mật khẩu (tối thiểu 6 ký tự)',
          hintText: '••••••',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscureRegPass,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _obscureRegPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white54,
              size: 16,
            ),
            onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: FilledButton.icon(
            onPressed: auth.isLoading ? null : _handleRegister,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00B0FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.zero,
              elevation: 3,
            ),
            icon: auth.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.how_to_reg, size: 18),
            label: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'TẠO TÀI KHOẢN MỚI',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Tiện ích tạo TextField nhỏ gọn, tối ưu cho mobile
  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autocorrect: false,
        enableSuggestions: false,
        scrollPadding: const EdgeInsets.only(bottom: 120),
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 11.5),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
          prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 16),
          prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          filled: true,
          fillColor: Colors.black38,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFF00E676)),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // GIAO DIỆN PORTRAIT FALLBACK (NẾU MỞ TRÊN MÀN HÌNH DỌC)
  // =========================================================================
  Widget _buildPortraitLayout(BuildContext context, AuthService auth) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _build8BallLogo(size: 54),
              const SizedBox(height: 8),
              const Text(
                '8 POOL MASTER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Vui lòng đăng nhập để đồng bộ thành tích',
                style: TextStyle(color: Color(0xFF80CBC4), fontSize: 12),
              ),
              const SizedBox(height: 16),
              _buildFormCard(auth),
              const SizedBox(height: 12),
              // Nút chơi ngay ở màn hình dọc
              TextButton.icon(
                onPressed: auth.isLoading ? null : _handleGuestLogin,
                icon: const Icon(Icons.bolt, color: Color(0xFF00E676), size: 18),
                label: const Text(
                  'HOẶC CHƠI NGAY DƯỚI DẠNG KHÁCH',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logo Bi 8 3D với viền sáng
  Widget _build8BallLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [Color(0xFF4A4A4A), Color(0xFF141414), Color(0xFF000000)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: const Color(0xFF00E676), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.46,
        height: size * 0.46,
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
            fontSize: size * 0.32,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
