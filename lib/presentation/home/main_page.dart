import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/core/constants/colors.dart';
import 'package:flutter_alquran_jauhar_app/presentation/home/widget/nav_item.dart';
import 'package:flutter_alquran_jauhar_app/presentation/sholat/sholat_page.dart';

import '../quran/alquran_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SholatPage(),
    const AlquranPage(),
  ];

  // final alarmSettings = AlarmSettings(
  //   id: 42,
  //   dateTime: DateTime.now().add(const Duration(seconds: 10)),
  //   assetAudioPath: 'assets/audios/mecca.mp3',
  //   loopAudio: true,
  //   vibrate: true,
  //   warningNotificationOnKill: Platform.isIOS,
  //   androidFullScreenIntent: true,
  //   volumeSettings: VolumeSettings.fixed(volume: 0.8, volumeEnforced: true),
  //   notificationSettings: const NotificationSettings(
  //     title: 'Adzan Magbrib',
  //     body: 'Masuk Waktu Adzan Magbrib untuk Kab Sleman',
  //     stopButton: 'Tutup',
  //     icon: 'notification_icon',
  //   ),
  // );

  void _onItemTapped(int index) {
    setState(() {
      // Alarm.set(alarmSettings: alarmSettings).then((value) {
      //   print('Alarm set: $value');
      // });
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 16,
          top: 10,
        ),
        decoration: BoxDecoration(color: AppColors.primary, boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 30.0,
            spreadRadius: 0,
            color: AppColors.black.withAlpha(1),
          )
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
                iconPath: 'assets/icons/ramadan.png',
                label: 'Hari ini',
                isActive: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0);
                }),
            NavItem(
                iconPath: 'assets/icons/mosque.png',
                label: 'Sholat',
                isActive: _selectedIndex == 1,
                onTap: () {
                  _onItemTapped(1);
                }),
            NavItem(
                iconPath: 'assets/icons/quran.png',
                label: 'Al-Quran',
                isActive: _selectedIndex == 2,
                onTap: () {
                  _onItemTapped(2);
                }),
          ],
        ),
      ),
    );
  }
}
