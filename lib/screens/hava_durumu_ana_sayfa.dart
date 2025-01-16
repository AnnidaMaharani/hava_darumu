import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:hava_darumu/screens/ana_ekran.dart';
import 'package:hava_darumu/screens/favori_ekran.dart';

class HavaDurumuAnaSayfa extends StatefulWidget {
  const HavaDurumuAnaSayfa({super.key});

  @override
  State<HavaDurumuAnaSayfa> createState() => _HavaDurumuAnaSayfaDurum();
}

class _HavaDurumuAnaSayfaDurum extends State<HavaDurumuAnaSayfa> {
  int _seciliIndex = 0;

  // Menü için ekranlar
  static List<Widget> _ekranlar = [
    HavaDurumuEkrani(),
    FavoriEkran(),
  ];

  void _menuDegistir(int index) {
    setState(() {
      _seciliIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu Uygulaması'),
      ),
      body: _ekranlar[_seciliIndex], // Seçili ekranı göster
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(
            icon: Icon(Icons.home),
          ),
          TabItem(
            icon: Icon(Icons.favorite),
          ),
        ],
        initialActiveIndex: _seciliIndex,
        onTap: _menuDegistir,
      ),
    );
  }
}
