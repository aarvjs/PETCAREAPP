import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;

  String? _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onResendPressed() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await AuthService.instance.sendOtp(
      phoneNumber: widget.phoneNumber,
      resendToken: _resendToken,
      onCodeSent: (String newVerificationId, int? newResendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = newVerificationId;
          _resendToken = newResendToken;
          _isLoading = false;
        });

        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new OTP has been sent to your mobile number'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
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
        _handleVerificationSuccess();
      },
    );
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  void _onOtpChanged(int index, String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    // Handle paste of full 6 digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        } else {
          _controllers[i].clear();
        }
      }
      if (digits.length >= _otpLength) {
        _focusNodes[_otpLength - 1].unfocus();
        _onVerifyPressed();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onVerifyPressed() async {
    setState(() {
      _errorMessage = null;
    });

    final code = _otpCode;
    if (code.length < _otpLength) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the OTP code.';
      });
      return;
    }

    if (_verificationId == null || _verificationId!.isEmpty) {
      setState(() {
        _errorMessage = 'Verification session expired. Please tap Resend Code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.signInWithOtp(
        verificationId: _verificationId!,
        smsCode: code,
      );

      if (!mounted) return;
      await _handleVerificationSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleVerificationSuccess() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication session lost. Please try logging in again.';
      });
      return;
    }

    try {
      final profile = await AuthService.instance.getUserProfile(user.uid);

      if (profile != null && AuthService.instance.isPrivilegedRole(profile.role)) {
        await AuthService.instance.signOut();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'This account is registered as Clinic Staff / Administrator (${profile.role}). Please use the Admin Portal.';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Existing customer who already has a name or completed/skipped setup goes straight to Home
      if (profile != null &&
          (profile.profileCompleted ||
              profile.profileSkipped ||
              (profile.name != null && profile.name!.trim().isNotEmpty))) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
      } else {
        // New customer: show the clean, optional profile setup
        await AuthService.instance.createOrEnsureMinProfile(user.uid, widget.phoneNumber);
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

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.phoneNumber.isEmpty
        ? '+91 Mobile Number'
        : AuthService.instance.maskPhoneNumber(widget.phoneNumber);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.mainText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verification Shield Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Verify Phone Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Masked Phone Number & Change Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Code sent to $maskedPhone',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Card
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
                      children: [
                        // Six OTP Digits
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_otpLength, (index) {
                            return SizedBox(
                              width: 44,
                              height: 52,
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (val) => _onOtpChanged(index, val),
                                style: const TextStyle(
                                  color: AppColors.mainText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  fillColor: _controllers[index].text.isNotEmpty
                                      ? AppColors.primaryContainer.withValues(alpha: 0.3)
                                      : AppColors.inputBackground,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _controllers[index].text.isNotEmpty
                                          ? AppColors.primary
                                          : AppColors.inputBorder,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Error Banner if present
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
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

                        // Verify Button
                        AppButton(
                          text: 'Verify & Continue',
                          isLoading: _isLoading,
                          onPressed: _onVerifyPressed,
                          backgroundColor: AppColors.primary,
                          icon: Icons.check_circle_outline_rounded,
                        ),

                        const SizedBox(height: 16),

                        // Resend Countdown Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Didn\'t receive code? ',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                            _canResend
                                ? GestureDetector(
                                    onTap: _onResendPressed,
                                    child: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Resend in ${_secondsRemaining}s',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
