import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSkipping = false;
  String? _errorMessage;

  void _onSavePressed() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final enteredName = _nameController.text.trim();
    if (enteredName.isEmpty) {
      _onSkipPressed();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.updateProfile(
        uid: user.uid,
        name: enteredName,
        profileCompleted: true,
        profileSkipped: false,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
    } catch (e) {
      // Local fallback so customer is never blocked
      AuthService.instance.updateLocalProfile(
        name: enteredName,
        profileCompleted: true,
        profileSkipped: false,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
    }
  }

  void _onSkipPressed() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    setState(() {
      _isSkipping = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.skipProfile(user.uid);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isSkipping || _isLoading ? null : _onSkipPressed,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar / Welcome Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headings
                    const Text(
                      'Welcome to Healthy Paws',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'What should we call you? You can easily add more details like delivery addresses whenever you place an order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Minimal Profile Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mainText.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Name (Optional)',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Rahul Sharma',
                              prefixIcon: Icon(Icons.badge_outlined,
                                  size: 20, color: AppColors.secondaryText),
                            ),
                          ),

                          // Error text if any
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 16, color: AppColors.errorRed),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.errorRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Save and Continue
                          AppButton(
                            text: 'Continue to Store',
                            isLoading: _isLoading,
                            onPressed: _onSavePressed,
                            backgroundColor: AppColors.primary,
                            icon: Icons.arrow_forward_rounded,
                          ),

                          const SizedBox(height: 12),

                          // Clear Skip Option
                          Center(
                            child: TextButton(
                              onPressed: _isSkipping || _isLoading ? null : _onSkipPressed,
                              child: _isSkipping
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'I\'ll do this later',
                                      style: TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
