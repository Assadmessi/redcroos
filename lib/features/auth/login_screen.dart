import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _memberNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _memberNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _memberNoController.text,
      _passwordController.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = auth.language;
    final isEN = lang == AppLanguage.english;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1923),
                  Color(0xFF1C2531),
                  Color(0xFF0F1923),
                ],
              ),
            ),
          ),

          // Decorative red circle top right
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Decorative circle bottom left
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Logo + Title
                      Center(
                        child: Column(
                          children: [
                            // Cross logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '✚',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // App name
                            Text(
                              isEN ? AppStrings.appName : AppStrings.appNameMM,
                              style: AppTextStyles.displaySmall.copyWith(
                                color: AppColors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isEN
                                  ? AppStrings.organization
                                  : AppStrings.organizationMM,
                              style: AppTextStyles.burmese(
                                fontSize: 13,
                                color: AppColors.grey500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Login card
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXxl),
                          boxShadow: AppShadows.xl,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEN ? 'Sign In' : 'ဝင်ရောက်ရန်',
                                style: AppTextStyles.displaySmall.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEN
                                    ? 'Enter your member credentials'
                                    : 'အဖွဲ့ဝင် အချက်အလက်များ ထည့်သွင်းပါ',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 28),

                              // Member ID field
                              _buildLabel(
                                isEN ? 'Member ID' : 'အဖွဲ့ဝင် နံပါတ်',
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _memberNoController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'e.g. RC-001',
                                  prefixIcon: const Icon(
                                    Icons.badge_rounded,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.grey100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.grey300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.grey300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Member ID is required'
                                    : null,
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              _buildLabel(
                                isEN ? 'Password' : 'စကားဝှက်',
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_rounded,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 20,
                                      color: AppColors.grey500,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.grey100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.grey300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.grey300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Password is required'
                                    : null,
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: 28),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      auth.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusMd),
                                    ),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isEN ? 'Sign In' : 'ဝင်ရောက်ရန်',
                                          style: AppTextStyles.button.copyWith(
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Demo hint
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd),
                                  border: Border.all(
                                      color: AppColors.info.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 16, color: AppColors.info),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Demo: Use RC-001 to RC-005\nPassword: 1234',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.info,
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

                      const SizedBox(height: 24),

                      // Language toggle
                      Center(
                        child: TextButton.icon(
                          onPressed: auth.toggleLanguage,
                          icon: const Text('🌐',
                              style: TextStyle(fontSize: 14)),
                          label: Text(
                            isEN
                                ? 'မြန်မာဘာသာသို့ပြောင်းရန်'
                                : 'Switch to English',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.grey800,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
