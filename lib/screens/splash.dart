import 'package:flutter/material.dart';
import 'package:hava_darumu/screens/ana_ekran.dart';
import 'package:hava_darumu/screens/hava_durumu_ana_sayfa.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashEkrani extends StatefulWidget {
  const SplashEkrani({super.key});

  @override
  _SplashEkraniState createState() => _SplashEkraniState();
}

class _SplashEkraniState extends State<SplashEkrani> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HavaDurumuAnaSayfa()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/splash.json', // Lottie animasyon dosyanızın yolunu kontrol edin
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              "Hava Durumu Uygulaması",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hava durumunu öğrenmek için bekleyin...",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
