import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/core/constants/colors.dart';
import 'package:flutter_alquran_jauhar_app/core/themes/text_styles.dart';
import 'package:flutter_alquran_jauhar_app/presentation/home/widget/nav_item.dart';
import 'package:flutter_alquran_jauhar_app/presentation/settings/settings_page.dart';
import 'package:flutter_alquran_jauhar_app/presentation/sholat/sholat_page.dart';

import '../quran/alquran_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  final List<Widget> _pages = [
    const HomePage(),
    const SholatPage(),
    const AlquranPage(),
    const SettingsPage(),
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _animationController?.reset();
    _animationController?.forward();

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 10.0,
              spreadRadius: 0,
              color: AppColors.black.withValues(alpha: 60),
            )
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.secondary.withValues(alpha: 50),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.mosque_rounded,
                  label: 'Sholat',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Al-Quran',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.secondary : AppColors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
