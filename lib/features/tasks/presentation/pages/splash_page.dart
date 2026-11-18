import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/core/theme/app_theme.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _bottomFadeAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // اهتزاز لمسي خفيف وأنيق عند بدء فتح التطبيق
    HapticFeedback.lightImpact();

    // 1. وحدة التحكم الرئيسية بالحركات المتسلسلة (Staggered Animations)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. وحدة تحكم بنبض الهالة الضوئية الدائري (Subtle Breathing Glow)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // حركة الشعار (ظهور تدريجي مع تمدد ارتدادي ممتع)
    _logoScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // حركة النصوص (انزلاق للأعلى مع تلاشي للظهور)
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeIn),
      ),
    );

    // حركة الشريط السفلي ورقم الإصدار
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    // بدء الحركات
    _mainController.forward();

    // الانتقال التلقائي السلس إلى الصفحة الرئيسية بعد اكتمال العرض
    Timer(const Duration(milliseconds: 2700), _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TasksPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // انتقال سلس وناعم عبر التلاشي (Smooth Fade Transition)
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.primaryColor;
    final secondary = AppTheme.secondaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // خلفية هادئة بتدرج شعاعي يعطي عمقاً بصرياً فخماً
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.1,
                  colors: isDark
                      ? [
                          primary.withOpacity(0.18),
                          secondary.withOpacity(0.06),
                          Colors.transparent,
                        ]
                      : [
                          primary.withOpacity(0.09),
                          secondary.withOpacity(0.03),
                          Colors.transparent,
                        ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // المحتوى المركزي (الشعار، العنوان، والوصف)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. الشعار مع هالات النبض الضوئية
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // هالة التوهج الخارجية الكبرى
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withOpacity(
                                  isDark ? 0.12 : 0.08,
                                ),
                              ),
                            ),
                          ),
                          // هالة التوهج المتوسطة
                          Transform.scale(
                            scale: (_pulseAnimation.value + 0.1) * 0.9,
                            child: Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: secondary.withOpacity(
                                  isDark ? 0.18 : 0.12,
                                ),
                              ),
                            ),
                          ),
                          // الأيقونة المركزية مع حركة الظهور والارتداد
                          FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      primary,
                                      AppTheme.primaryDarkColor,
                                      secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(
                                        isDark ? 0.45 : 0.35,
                                      ),
                                      blurRadius: 26,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      isDark ? 0.25 : 0.45,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // أيقونة إنجاز المهام المميزة
                                    const Icon(
                                      Icons.task_alt_rounded,
                                      color: Colors.white,
                                      size: 46,
                                    ),
                                    // وميض صغير في الزاوية يعطي طابع الحداثة
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // 2. اسم التطبيق والشعار النصي
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'مهامي اليومية',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'نظّم وقتك، أنجز مهامك، وحقّق أهدافك',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. الجزء السفلي (مؤشر تحميل أنيق ورقم الإصدار)
          Positioned(
            left: 0,
            right: 0,
            bottom: 38,
            child: FadeTransition(
              opacity: _bottomFadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط تقدم مصغر وأنيق بنهايات مستديرة
                  SizedBox(
                    width: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 3.5,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الإصدار 1.0.0',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

