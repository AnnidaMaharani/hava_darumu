import 'package:flutter/material.dart';
import 'package:hava_darumu/screens/HavaDetayEkran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriEkran extends StatefulWidget {
  const FavoriEkran({super.key});

  @override
  _FavoriEkranState createState() => _FavoriEkranState();
}

class _FavoriEkranState extends State<FavoriEkran> {
  List<String> favoriler = [];
  Map<String, dynamic> havaDurumlari = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriler();
  }

  Future<void> _loadFavoriler() async {
    final prefs = await SharedPreferences.getInstance();
    final storedFavoriler = prefs.getStringList('favoriler') ?? [];
    setState(() {
      favoriler = storedFavoriler;
    });
    _fetchWeatherForFavorites();
  }

  Future<void> _fetchWeatherForFavorites() async {
    const apiKey = 'dc81df4ae32d4c0c8ff65037250901';
    for (var city in favoriler) {
      final url = Uri.parse(
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          setState(() {
            havaDurumlari[city] = json.decode(response.body);
          });
        }
      } catch (e) {
        debugPrint('Hata: $e');
      }
    }
  }

  Future<void> _removeFavorite(String cityName) async {
    setState(() {
      favoriler.remove(cityName);
      havaDurumlari.remove(cityName);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoriler', favoriler); // Listeyi güncelle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Şehirler'),
      ),
      body: favoriler.isEmpty
          ? const Center(child: Text('Favori şehir listeniz boş.'))
          : ListView.builder(
              itemCount: favoriler.length,
              itemBuilder: (context, index) {
                final city = favoriler[index];
                final weather = havaDurumlari[city];
                return Card(
                  child: ListTile(
                    leading: weather != null
                        ? Image.network(
                            'https:${weather['current']['condition']['icon']}',
                            width: 50,
                            height: 50,
                          )
                        : const CircularProgressIndicator(),
                    title: Text(
                      city,
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: weather != null
                        ? Text(
                            '${weather['current']['temp_c']}°C - ${weather['current']['condition']['text']}',
                          )
                        : const Text('Hava durumu yükleniyor...'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeFavorite(city);
                      },
                    ),
                    onTap: () {
                      // Navigasyon ile detay ekranına geçiş
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HavaDetayEkran(sehir: city),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
