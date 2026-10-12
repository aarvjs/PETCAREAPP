import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import '../../core/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;

  bool _validatePhoneNumber(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(cleanValue);
  }

  void _onSendOtpPressed() async {
    setState(() {
      _errorMessage = null;
    });

    final phoneText = _phoneController.text.trim();
    if (!_validatePhoneNumber(phoneText)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number (e.g. 9876543210)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formattedPhone = AuthService.instance.formatPhoneNumber(phoneText);

    await AuthService.instance.sendOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushNamed(
          context,
          AppRoutes.otp,
          arguments: {
            'phoneNumber': formattedPhone,
            'verificationId': verificationId,
            'resendToken': resendToken,
          },
        );
      },
      onError: (String errorMessage) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      },
      onAutoVerified: (credential) async {
        if (!mounted) return;
        final user = AuthService.instance.currentUser;
        if (user != null) {
          try {
            final profile = await AuthService.instance.getUserProfile(user.uid);
            if (!mounted) return;
            if (profile != null && AuthService.instance.isPrivilegedRole(profile.role)) {
              await AuthService.instance.signOut();
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'This account is registered as Clinic Staff / Administrator (${profile.role}). Please sign in via the Admin Portal.';
              });
              return;
            }

            if (profile != null &&
                (profile.profileCompleted ||
                    profile.profileSkipped ||
                    (profile.name != null && profile.name!.trim().isNotEmpty))) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
            } else {
              await AuthService.instance.createOrEnsureMinProfile(user.uid, formattedPhone);
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profileSetup, (route) => false);
            }
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = AuthService.instance.getFriendlyErrorMessage(e);
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = ShopService.instance.currentBusiness;
    final shopName = business?.name ?? 'Healthy Paws Pet Clinic';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Shop Identity Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainText.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Shop Badge Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            color: AppColors.onPrimaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headings
                    const Text(
                      'Welcome Pet Parent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with your mobile number to browse pet essentials, book clinic visits, and manage orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Phone Input Card
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
                            'Mobile Number',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Country Code + 10 Digit Number Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border, width: 1),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 6),
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        color: AppColors.mainText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: const TextStyle(
                                    color: AppColors.mainText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter 10-digit number',
                                    counterText: '',
                                  ),
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() {
                                        _errorMessage = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
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

                          const SizedBox(height: 20),

                          // Send OTP Button
                          AppButton(
                            text: 'Send OTP',
                            isLoading: _isLoading,
                            onPressed: _onSendOtpPressed,
                            backgroundColor: AppColors.primary,
                            icon: Icons.arrow_forward_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Privacy & Trust Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Secure OTP verification via Firebase',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.termsNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11,
                        height: 1.4,
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
