import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/core/constants/colors.dart';
import 'package:flutter_alquran_jauhar_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_jauhar_app/data/models/bookmark_model.dart';
import 'package:flutter_alquran_jauhar_app/presentation/quran/ayat_page.dart';
import 'package:quran_flutter/quran_flutter.dart';

import '../../core/components/spaces.dart';

class AlquranPage extends StatefulWidget {
  const AlquranPage({super.key});

  @override
  State<AlquranPage> createState() => _AlquranPageState();
}

class _AlquranPageState extends State<AlquranPage> {
  List<Surah> surahs = [];

  BookmarkModel? bookmarkModel;

  void loadData() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    if (bookmark != null) {
      setState(() {
        bookmarkModel = bookmark;
      });
    }
  }

  @override
  void initState() {
    surahs = Quran.getSurahAsList();
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Al-Qur\'an',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          bookmarkModel == null
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.book,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SpaceWidth(4.0),
                          Expanded(
                            child: Text(
                              '${bookmarkModel!.suratName} ${bookmarkModel!.suratNumber}:${bookmarkModel!.ayatNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
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
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Text(
                          'Lanjutkan',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          const SpaceHeight(24.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Text(
              'Daftar Surah',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SpaceHeight(16.0),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return InkWell(
                onTap: () async {
                  // after page loadData
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AyatPage.ofSurah(surah)),
                  );

                  loadData(); // Memanggil fungsi untuk memuat data terbaru
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 36.0,
                          child: Text(
                            '${surah.number}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SpaceWidth(24.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.nameEnglish,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              surah.meaning,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${surah.verseCount} Ayat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SpaceHeight(16.0),
          ),
        ],
      ),
    );
  }
}
