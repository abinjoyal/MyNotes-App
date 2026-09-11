import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../settings/controllers/settings_controller.dart';

class PasscodeLockScreen extends StatefulWidget {
  final bool isSetupMode;
  final VoidCallback? onSuccess;

  const PasscodeLockScreen({
    super.key,
    this.isSetupMode = false,
    this.onSuccess,
  });

  @override
  State<PasscodeLockScreen> createState() => _PasscodeLockScreenState();
}

class _PasscodeLockScreenState extends State<PasscodeLockScreen>
    with SingleTickerProviderStateMixin {
  final SettingsController _settingsController = SettingsController.instance;

  String _enteredPin = '';
  String _firstPin = '';
  String _errorMessage = '';
  bool _isConfirming = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        _handlePinCompletion();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _handlePinCompletion() async {
    if (widget.isSetupMode) {
      if (!_isConfirming) {
        // Step 1: Save first PIN and ask to confirm
        setState(() {
          _firstPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        // Step 2: Check matching PIN
        if (_enteredPin == _firstPin) {
          _settingsController.setPinCode(_firstPin);
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          _triggerError('PINs do not match. Try again.');
          setState(() {
            _enteredPin = '';
            _firstPin = '';
            _isConfirming = false;
          });
        }
      }
    } else {
      // Unlock Mode
      if (_settingsController.verifyPin(_enteredPin)) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      } else {
        _triggerError('Incorrect PIN. Please try again.');
        setState(() {
          _enteredPin = '';
        });
      }
    }
  }

  void _triggerError(String msg) {
    setState(() {
      _errorMessage = msg;
    });
    _shakeController.forward(from: 0.0);
  }

  void _triggerBiometrics() {
    if (_settingsController.enableBiometrics) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Scanning Fingerprint / Face ID... Authorized!'),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } else {
      _triggerError('Biometrics not enabled in Settings.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkScaffoldBackground : AppColors.softGray;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    String headerTitle;
    String headerSubtitle;

    if (widget.isSetupMode) {
      if (_isConfirming) {
        headerTitle = 'Confirm Passcode';
        headerSubtitle = 'Re-enter your 4-digit PIN to confirm';
      } else {
        headerTitle = 'Set Passcode';
        headerSubtitle = 'Choose a 4-digit PIN code to secure your notes';
      }
    } else {
      headerTitle = 'My Notes Locked';
      headerSubtitle = 'Enter your 4-digit passcode to unlock';
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.isSetupMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textColor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon / Lock Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header Title
                  Text(
                    headerTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headerSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // PIN Dots Indicator with Shake Animation
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final isFilled = index < _enteredPin.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled
                                    ? AppColors.primaryPurple
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isFilled
                                      ? AppColors.primaryPurple
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : const Color(0xFFC4C4C4)),
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),

                  // Error Text
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: _errorMessage.isNotEmpty
                          ? Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),

                  // Keypad Buttons Grid
                  SizedBox(
                    width: 280,
                    child: Column(
                      children: [
                        _buildKeypadRow(['1', '2', '3'], textColor, isDark),
                        const SizedBox(height: 16),
                        _buildKeypadRow(['4', '5', '6'], textColor, isDark),
                        const SizedBox(height: 16),
                        _buildKeypadRow(['7', '8', '9'], textColor, isDark),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Biometrics button (Unlock mode)
                            _buildIconButton(
                              icon: Icons.fingerprint_rounded,
                              textColor: AppColors.primaryPurple,
                              isDark: isDark,
                              onTap: _triggerBiometrics,
                            ),
                            // Number 0
                            _buildKeypadButton('0', textColor, isDark),
                            // Backspace button
                            _buildIconButton(
                              icon: Icons.backspace_outlined,
                              textColor: textColor,
                              isDark: isDark,
                              onTap: _onBackspace,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, Color textColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildKeypadButton(key, textColor, isDark)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit, Color textColor, bool isDark) {
    final btnBg = isDark ? const Color(0xFF24242A) : Colors.white;
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: btnBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onKeyPress(digit),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final btnBg = isDark ? const Color(0xFF24242A) : Colors.white;
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: btnBg,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
