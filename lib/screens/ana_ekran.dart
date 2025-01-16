import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HavaDurumuEkrani extends StatefulWidget {
  const HavaDurumuEkrani({super.key});

  @override
  _HavaDurumuEkraniDurum createState() => _HavaDurumuEkraniDurum();
}

class _HavaDurumuEkraniDurum extends State<HavaDurumuEkrani> {
  final TextEditingController _sehirController = TextEditingController();
  String _sehir = "Istanbul";
  Map<String, dynamic>? _havaDurumu;
  var konum_durumu = false;
  List<String> favoriler = []; // Favori şehirler listesi

  @override
  void initState() {
    super.initState();
    _loadFavoriler(); // Favorileri yükle
    _requestPermission();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _getCityName(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum hizmetlerini kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        konum_durumu = false;
      });
      return;
    }

    // İzin durumunu kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          konum_durumu = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        konum_durumu = false;
      });
      return;
    }
  }

  Future<void> _getCityName(double latitude, double longitude) async {
    const apiKey = 'dc81df4ae32d4c0c8ff65037250901';
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=5&aqi=no&alerts=no');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _havaDurumu = json.decode(response.body);
          _sehir = _havaDurumu!['location']['name'];
        });
      } else {
        throw Exception('Hava durumu bilgisi alınamadı.');
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _getHavaDurumu(String sehir) async {
    const apiKey = 'dc81df4ae32d4c0c8ff65037250901';
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$sehir&days=5&aqi=no&alerts=no');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _havaDurumu = json.decode(response.body);
        });
      } else {
        throw Exception('Hava durumu bilgisi alınamadı.');
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _addFavorite(String cityName) async {
    if (!favoriler.contains(cityName)) {
      setState(() {
        favoriler.add(cityName);
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('favoriler', favoriler);
    }
  }

  Future<void> _removeFavorite(String cityName) async {
    setState(() {
      favoriler.remove(cityName);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoriler', favoriler); // Listeyi güncelle
  }

  Future<void> _loadFavoriler() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriler = prefs.getStringList('favoriler') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sehirController,
                    decoration: const InputDecoration(
                      labelText: 'Şehir Adı',
                      hintText: 'Bir şehir giriniz',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sehir = _sehirController.text;
                      _getHavaDurumu(_sehir);
                    });
                  },
                  child: const Text('Ara'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _havaDurumu == null
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            _havaDurumu!['location']['name'],
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_havaDurumu!['current']['temp_c']}°C',
                            style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https:${_havaDurumu!['current']['condition']['icon']}',
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _havaDurumu!['current']['condition']['text'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          IconButton(
                            icon: Icon(
                              favoriler.contains(_sehir)
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: favoriler.contains(_sehir)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              if (favoriler.contains(_sehir)) {
                                _removeFavorite(_sehir);
                              } else {
                                _addFavorite(_sehir);
                              }
                            },
                          ),
                          const Text(
                            '5 Günlük Hava Tahmini',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ...(_havaDurumu!['forecast']['forecastday'] as List)
                              .map(
                                (forecast) => Card(
                                  child: ListTile(
                                    leading: Image.network(
                                      'https:${forecast['day']['condition']['icon']}',
                                    ),
                                    title: Text(
                                      forecast['date'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        '${forecast['day']['avgtemp_c']}°C - ${forecast['day']['condition']['text']}'),
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
