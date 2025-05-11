import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../settings/settings_page.dart';

class MenuItemData {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const MenuItemData({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class MenuGrid extends StatelessWidget {
  final Function(String) onMenuSelected;

  MenuGrid({
    super.key,
    required this.onMenuSelected,
  });

  final List<MenuItemData> _menuItems = [
    const MenuItemData(
      id: 'alquran',
      title: 'Al-Quran',
      icon: Icons.menu_book_rounded,
      color: AppColors.secondary,
    ),
    const MenuItemData(
      id: 'qibla',
      title: 'Arah Kiblat',
      icon: Icons.explore_outlined,
      color: Colors.green,
    ),
    const MenuItemData(
      id: 'prayerTimes',
      title: 'Jadwal Sholat',
      icon: Icons.access_time_rounded,
      color: Colors.orange,
    ),
    const MenuItemData(
      id: 'settings',
      title: 'Pengaturan',
      icon: Icons.settings_outlined,
      color: Colors.blueGrey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return InkWell(
          onTap: () {
            if (item.id == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            } else {
              onMenuSelected(item.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 80),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.color.withValues(alpha: 50),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
