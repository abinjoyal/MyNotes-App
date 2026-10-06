import 'package:flutter/material.dart';
import 'package:notes/core/services/storage_service.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_strings.dart';
import '../../app/layout/desktop_layout.dart';
import '../../app/layout/responsive_layout.dart';
import '../settings/controllers/settings_controller.dart';
import '../pin/presentation/screens/passcode_lock_screen.dart';
import '../setup/presentation/screens/storage_setup_wizard_screen.dart';
import '../../core/services/storage_location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await StorageService.instance.init();
    await SettingsController.instance.loadSettings();
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
    if (!mounted) return;

    if (!StorageLocationService.instance.isSetupCompleted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StorageSetupWizardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    final settings = SettingsController.instance;
    final Widget targetScreen = settings.enablePinLock
        ? PasscodeLockScreen(
            isSetupMode: false,
            onSuccess: (passcodeContext) {
              Navigator.of(passcodeContext).pushReplacement(
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const ResponsiveLayout(
                      mobile: DesktopLayout(),
                      desktop: DesktopLayout(),
                    );
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            },
          )
        : const ResponsiveLayout(
            mobile: DesktopLayout(),
            desktop: DesktopLayout(),
          );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.softGray,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryPurple, Color(0xFF8B85FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        size: 56,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture ideas, organize thoughts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPurple.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
