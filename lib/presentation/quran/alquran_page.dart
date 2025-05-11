import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/core/constants/colors.dart';
import 'package:flutter_alquran_jauhar_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_jauhar_app/data/models/bookmark_model.dart';
import 'package:flutter_alquran_jauhar_app/presentation/quran/ayat_page.dart';
import 'package:quran_flutter/quran_flutter.dart';

import '../../core/components/spaces.dart';
import '../../core/components/gradient_container.dart';
import '../../core/components/shadow_box.dart';
import '../../core/themes/text_styles.dart';

class AlquranPage extends StatefulWidget {
  const AlquranPage({super.key});

  @override
  State<AlquranPage> createState() => _AlquranPageState();
}

class _AlquranPageState extends State<AlquranPage> {
  List<Surah> surahs = [];
  BookmarkModel? bookmarkModel;
  final searchController = TextEditingController();
  bool isSearching = false;
  List<Surah> filteredSurahs = [];

  void loadData() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    if (bookmark != null) {
      setState(() {
        bookmarkModel = bookmark;
      });
    }
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSurahs = surahs;
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      filteredSurahs = surahs.where((surah) {
        return surah.nameEnglish.toLowerCase().contains(query.toLowerCase()) ||
            surah.number.toString().contains(query) ||
            surah.meaning.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    surahs = Quran.getSurahAsList();
    filteredSurahs = surahs;
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Al-Qur\'an',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                loadData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (bookmarkModel != null) _buildLastReadingCard(),
                  const SpaceHeight(24.0),
                  _buildSurahListHeader(),
                  const SpaceHeight(16.0),
                  _buildSurahList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.primary,
      child: ShadowBox(
        padding: EdgeInsets.zero,
        color: AppColors.white.withValues(alpha: 20.0),
        child: TextField(
          controller: searchController,
          onChanged: _filterSurahs,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Cari surah...',
            hintStyle:
                TextStyle(color: AppColors.white.withValues(alpha: 150.0)),
            prefixIcon: const Icon(Icons.search, color: AppColors.white),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.white),
                    onPressed: () {
                      searchController.clear();
                      _filterSurahs('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildLastReadingCard() {
    return GestureDetector(
      onTap: () async {
        if (bookmarkModel != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AyatPage.ofSurah(
                Quran.getSurah(bookmarkModel!.suratNumber),
                lastReading: true,
                bookmark: bookmarkModel,
              ),
            ),
          );
          loadData();
        }
      },
      child: GradientContainer(
        gradientType: GradientType.secondary,
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 50.0),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: const Icon(
                Icons.bookmark,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SpaceWidth(16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terakhir Dibaca',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 200.0),
                    ),
                  ),
                  const SpaceHeight(4.0),
                  Text(
                    '${bookmarkModel!.suratName} - Ayat ${bookmarkModel!.ayatNumber}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Text(
            'Daftar Surah',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          isSearching
              ? Text(
                  '${filteredSurahs.length} surah ditemukan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        return ShadowBox(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 4.0),
          borderRadius: 12.0,
          color: AppColors.primary.withValues(alpha: 50.0),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 50.0),
            width: 1.0,
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AyatPage.ofSurah(surah),
                ),
              );
              loadData();
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 50.0),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${surah.number}',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SpaceWidth(16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.nameEnglish,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            surah.meaning,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 180.0),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 30.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      '${surah.verseCount} Ayat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
    );
  }
}
